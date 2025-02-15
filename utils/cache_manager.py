
import json
import streamlit as st
from datetime import datetime, timedelta
import hashlib
from pathlib import Path

class QueryCache:
    @st.cache_data(ttl=3600)  # Cache for 1 hour
    def get_query_results(query_hash):
        cache_file = Path(f".cache/query_results_{query_hash}.json")
        if cache_file.exists():
            with cache_file.open() as f:
                data = json.load(f)
                if datetime.fromisoformat(data['timestamp']) > datetime.now() - timedelta(hours=1):
                    return data['results']
        return None

    @staticmethod
    def cache_query_results(query_hash, results):
        cache_file = Path(f".cache/query_results_{query_hash}.json")
        cache_file.parent.mkdir(exist_ok=True)
        with cache_file.open('w') as f:
            json.dump({
                'timestamp': datetime.now().isoformat(),
                'results': results
            }, f)

    @staticmethod
    def get_query_hash(query):
        return hashlib.md5(query.encode()).hexdigest()