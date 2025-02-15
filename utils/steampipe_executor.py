import streamlit as st
import subprocess
import json
import logging
from .cache_manager import QueryCache

logger = logging.getLogger(__name__)

class SteampipeExecutor:
    @staticmethod
    def execute_query(sql_query):
        query_hash = QueryCache.get_query_hash(sql_query)
        cached_results = QueryCache.get_query_results(query_hash)
        
        if cached_results:
            return cached_results
            
        try:
            logger.info(f"Executing Steampipe query: {sql_query[:100]}...")
            result = subprocess.run(
                ['steampipe', 'query', sql_query, '--output', 'json'],
                capture_output=True,
                text=True
            )
            if result.returncode != 0:
                logger.error(f"Steampipe error: {result.stderr}")
                st.error(f"Query failed: {result.stderr}")
                return None
                
            results = json.loads(result.stdout)
            QueryCache.cache_query_results(query_hash, results)
            return results
        except Exception as e:
            logger.error(f"Query execution failed: {str(e)}")
            st.error(f"Query execution failed: {str(e)}")
            return None