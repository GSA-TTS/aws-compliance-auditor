
import streamlit as st
from pathlib import Path
import re

class ControlLoader:
    @st.cache_data
    def load_control_content(control_path):
        md_path = Path(control_path)
        if md_path.exists():
            return md_path.read_text()
        return ""

    @st.cache_data
    def load_control_query(control_id):
        sql_path = Path(f"dist/system-security-plans/lato/queries/{control_id}.sql")
        if sql_path.exists():
            return sql_path.read_text()
        return ""

    @staticmethod
    def get_control_families():
        control_path = Path("dist/system-security-plans/lato")
        return sorted([p.stem for p in control_path.glob("*.md")])