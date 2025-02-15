#!/usr/bin/env python3
import os
from pathlib import Path
import shutil
import logging
import psutil
import time
from datetime import datetime
from typing import List, Dict
import concurrent.futures
from tqdm import tqdm

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class ResourceMonitor:
    def __init__(self, cpu_threshold=80, memory_threshold=80):
        self.cpu_threshold = cpu_threshold
        self.memory_threshold = memory_threshold
    
    def should_pause(self) -> bool:
        cpu_percent = psutil.cpu_percent(interval=1)
        memory_percent = psutil.virtual_memory().percent
        
        if cpu_percent > self.cpu_threshold or memory_percent > self.memory_threshold:
            logger.warning(f"Resource threshold exceeded: CPU {cpu_percent}%, Memory {memory_percent}%")
            return True
        return False
    
    def wait_until_resources_available(self):
        while self.should_pause():
            logger.info("Waiting for resources to become available...")
            time.sleep(5)

def process_control_batch(files_batch: List[Dict], base_path: Path, pages_path: Path):
    """Process a batch of control files"""
    monitor = ResourceMonitor()
    
    for file_info in files_batch:
        monitor.wait_until_resources_available()
        
        try:
            control_id = file_info['control_id']
            md_content = file_info['md_path'].read_text()
            sql_content = file_info['sql_path'].read_text() if file_info['sql_path'].exists() else None
            
            page_content = f'''# Generated {datetime.now().isoformat()}
import streamlit as st
from utils.steampipe_executor import SteampipeExecutor

def show():
    """Display control {control_id}"""
    st.header(f"Control: {control_id}")
    
    st.markdown("""{md_content}""")
    
    with st.expander("View Compliance Query"):
        st.code("""{sql_content or '-- No query available'}""", language="sql")
        
        if {bool(sql_content)}:
            if st.button("🔍 Run Check", key=f"run_{control_id}"):
                with st.spinner("Running..."):
                    results = SteampipeExecutor.execute_query("""{sql_content}""")
                    if results:
                        st.json(results)

if __name__ == "__main__":
    st.set_page_config(page_title="{control_id}", layout="wide")
    show()
'''
            (pages_path / f"{control_id}.py").write_text(page_content)
            
        except Exception as e:
            logger.error(f"Error processing {control_id}: {e}")

def main():
    """Generate Streamlit pages with resource monitoring and batching"""
    base_path = Path("dist/system-security-plans/lato")
    pages_path = Path("pages/controls")
    
    if pages_path.exists():
        shutil.rmtree(pages_path)
    pages_path.mkdir(parents=True)
    
    # Initialize control files list
    control_files = []
    for md_file in sorted(base_path.glob("*.md")):
        control_id = md_file.stem
        control_files.append({
            'control_id': control_id,
            'md_path': md_file,
            'sql_path': base_path / "queries" / f"{control_id}.sql"
        })
    
    # Create batches
    BATCH_SIZE = 5
    batches = [control_files[i:i + BATCH_SIZE] 
               for i in range(0, len(control_files), BATCH_SIZE)]
    
    # Process batches with progress bar
    with tqdm(total=len(control_files), desc="Generating pages") as pbar:
        for batch in batches:
            process_control_batch(batch, base_path, pages_path)
            pbar.update(len(batch))
            time.sleep(1)  # Small pause between batches
    
    # Create __init__.py
    init_content = '''from pathlib import Path
def load_control_pages():
    """Get list of available control pages"""
    controls_dir = Path(__file__).parent
    return sorted([p.stem for p in controls_dir.glob("*.py")
                  if not p.stem.startswith("_")])
'''
    (pages_path / "__init__.py").write_text(init_content)
    
    logger.info("Page generation complete!")

if __name__ == "__main__":
    main()