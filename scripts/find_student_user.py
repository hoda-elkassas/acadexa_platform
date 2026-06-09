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
    res = client.table("v_users_with_roles").select("*").execute()
    print("All users in v_users_with_roles:")
    for user in res.data:
        print(user)
except Exception as e:
    print("Error:", e)
