from pathlib import Path
def load_control_pages():
    """Get list of available control pages"""
    controls_dir = Path(__file__).parent
    return sorted([p.stem for p in controls_dir.glob("*.py")
                  if not p.stem.startswith("_")])
