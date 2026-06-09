import os
import sys
from pathlib import Path
from dotenv import load_dotenv
load_dotenv("python_backend/.env")
from supabase import create_client

url = os.getenv("SUPABASE_URL", "")
svc = os.getenv("SUPABASE_SERVICE_ROLE_KEY", "")
client = create_client(url, svc)

try:
    res = client.table("system_roles").select("*").execute()
    print("System Roles:", res.data)
except Exception as e:
    print("Error:", e)
