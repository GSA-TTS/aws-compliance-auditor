import os
import streamlit as st
from typing import Dict, Any

def load_secrets() -> None:
    """Load secrets from environment if not already in streamlit secrets"""
    if 'postgres' not in st.secrets:
        st.secrets['postgres'] = {
            'host': os.getenv('POSTGRES_HOST', 'db'),
            'database': os.getenv('POSTGRES_DB', 'compliancedb'),
            'user': os.getenv('POSTGRES_USER', 'complianceuser'),
            'password': os.getenv('POSTGRES_PASSWORD', '')
        }
    
    if 'aws' not in st.secrets:
        st.secrets['aws'] = {
            'access_key_id': os.getenv('AWS_ACCESS_KEY_ID', ''),
            'secret_access_key': os.getenv('AWS_SECRET_ACCESS_KEY', ''),
            'region': os.getenv('AWS_REGION', 'us-east-1')
        }

def get_db_url() -> str:
    """Get database URL from secrets"""
    load_secrets()
    return (f"postgresql://{st.secrets['postgres']['user']}:"
            f"{st.secrets['postgres']['password']}@"
            f"{st.secrets['postgres']['host']}/"
            f"{st.secrets['postgres']['database']}")
