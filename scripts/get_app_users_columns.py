import os
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent / "python_backend"))
from dotenv import load_dotenv
load_dotenv("backend/.env")
from supabase import create_client

url = os.getenv("SUPABASE_URL", "")
svc = os.getenv("SUPABASE_SERVICE_ROLE_KEY", "")
client = create_client(url, svc)

try:
    res = client.table("v_users_with_roles").select("*").limit(1).execute()
    print("Columns in v_users_with_roles:", res.data[0].keys() if res.data else "No data but table exists")
    if res.data:
        print("Data:", res.data[0])
except Exception as e:
    print("Error:", e)

