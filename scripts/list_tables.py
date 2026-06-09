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

print("Checking user_profiles:")
try:
    res = client.table("user_profiles").select("*").limit(1).execute()
    print("Success user_profiles:", res.data)
except Exception as e:
    print("Error user_profiles:", e)

print("\nChecking app_users:")
try:
    res = client.table("app_users").select("*").limit(1).execute()
    print("Success app_users:", res.data)
except Exception as e:
    print("Error app_users:", e)
