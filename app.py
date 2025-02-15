import streamlit as st
import boto3
import pandas as pd
from botocore.exceptions import ClientError
import time
import logging
import importlib
from pages.controls import load_control_pages

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

st.set_page_config(
    page_title="AWS Compliance Auditor",
    page_icon="🔒",
    layout="wide"
)

def init_session_state():
    if 'authenticated' not in st.session_state:
        st.session_state.authenticated = False
    if 'aws_client' not in st.session_state:
        st.session_state.aws_client = None

def create_aws_client(access_key, secret_key, region):
    try:
        with st.spinner('Connecting to AWS...'):
            session = boto3.Session(
                aws_access_key_id=access_key,
                aws_secret_access_key=secret_key,
                region_name=region
            )
            # Create both clients we need
            identity_client = session.client('identitystore')
            sso_client = session.client('sso-admin')
            
            # Test the connection
            sso_client.list_instances()
            logger.info("Successfully connected to AWS SSO")
            
            return identity_client
    except ClientError as e:
        error_code = e.response['Error']['Code']
        error_msg = e.response['Error']['Message']
        logger.error(f"AWS Error: {error_code} - {error_msg}")
        st.error(f"AWS Connection Error: {error_msg}")
        return None
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}")
        st.error(f"Connection Failed: {str(e)}")
        return None

def check_sso_permissions(client):
    try:
        with st.spinner('Verifying permissions...'):
            # First get SSO instance ID
            sso_client = boto3.client('sso-admin')
            instances = sso_client.list_instances()
            
            if not instances.get('Instances'):
                st.warning("No SSO instances found in this region")
                return False
                
            identity_store_id = instances['Instances'][0]['IdentityStoreId']
            st.session_state.identity_store_id = identity_store_id
            
            # Test Identity Store permissions
            client.list_groups(
                IdentityStoreId=identity_store_id,
                MaxResults=1
            )
            logger.info("Successfully verified permissions")
            return True
            
    except ClientError as e:
        error_code = e.response['Error']['Code']
        error_msg = e.response['Error']['Message']
        logger.error(f"Permission check failed: {error_code} - {error_msg}")
        st.error(f"Permission Error: {error_msg}")
        return False

def authenticate():
    st.sidebar.title("AWS Authentication")
    
    st.sidebar.warning("""
    ⚠️ **Security Notice**
    
    Required permissions:
    """)
    
    # Add copyable JSON policy block
    policy_json = """{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "securityhub:*",
                "config:*",
                "cloudtrail:*",
                "identitystore:*",
                "ds:*"
            ],
            "Resource": "*"
        }
    ]
}"""
    
    st.sidebar.code(policy_json, language="json")
    
    st.sidebar.markdown("[View AWS IAM Documentation](https://docs.aws.amazon.com/singlesignon/latest/userguide/iam-auth-access.html)")
    
    with st.sidebar.form("aws_auth"):
        access_key = st.text_input("AWS Access Key ID", type="password")
        secret_key = st.text_input("AWS Secret Access Key", type="password")
        region = st.selectbox("AWS Region", [
            "us-east-1",
            "us-east-2",
            "us-west-1",
            "us-west-2"
        ])
        submitted = st.form_submit_button("Connect")
        
        if submitted:
            with st.spinner('Authenticating...'):
                client = create_aws_client(access_key, secret_key, region)
                if client and check_sso_permissions(client):
                    st.session_state.aws_client = client
                    st.session_state.authenticated = True
                    st.success("Successfully connected to AWS!")
                    time.sleep(1)
                    st.rerun()
                else:
                    st.error("Authentication failed. Please check credentials and permissions.")

def list_permission_sets():
    try:
        # Update to use Identity Store API
        identity_store_id = st.session_state.get('identity_store_id')
        if not identity_store_id:
            # Get Identity Store ID
            sso_admin = boto3.client('sso-admin')
            instances = sso_admin.list_instances()
            if instances['Instances']:
                identity_store_id = instances['Instances'][0]['IdentityStoreId']
                st.session_state.identity_store_id = identity_store_id
            else:
                st.warning("No Identity Store instances found")
                return pd.DataFrame()
        
        # List groups instead of permission sets
        groups = st.session_state.aws_client.list_groups(
            IdentityStoreId=identity_store_id
        )
        
        details = []
        for group in groups['Groups']:
            details.append({
                'Name': group['DisplayName'],
                'GroupId': group['GroupId'],
                'Description': group.get('Description', '')
            })
            
        return pd.DataFrame(details)
    except ClientError as e:
        st.error(f"AWS API Error: {str(e)}")
        return pd.DataFrame()

def main():
    init_session_state()
    
    st.title("AWS Compliance Dashboard")
    
    if not st.session_state.authenticated:
        authenticate()
    else:
        # Load control pages
        control_pages = load_control_pages()
        
        # Group controls by family
        families = {}
        for control in control_pages:
            family = control.split('-')[0].upper()
            if family not in families:
                families[family] = []
            families[family].append(control)
        
        # Summary statistics
        col1, col2, col3 = st.columns(3)
        with col1:
            st.metric("Total Controls", len(control_pages))
        with col2:
            st.metric("Control Families", len(families))
        
        # Create tabs for each family
        family_tabs = st.tabs(list(sorted(families.keys())))
        
        for tab, family in zip(family_tabs, sorted(families.keys())):
            with tab:
                st.subheader(f"{family} Controls")
                control_tabs = st.tabs(sorted(families[family]))
                
                for control_tab, control_id in zip(control_tabs, sorted(families[family])):
                    with control_tab:
                        try:
                            module = importlib.import_module(f"pages.controls.{control_id}")
                            module.show()
                        except Exception as e:
                            st.error(f"Error loading control {control_id}: {str(e)}")
        
        # Control tabs
        st.sidebar.title("Controls")
        if st.sidebar.button("Clear Cache"):
            st.cache_data.clear()
            st.success("Cache cleared!")

if __name__ == "__main__":
    main()
