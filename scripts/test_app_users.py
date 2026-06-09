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

targets = [
    "app_users",
    "v_users_with_roles",
    "student_full_summary",
    "student_latest_analysis"
]

for target in targets:
    try:
        res = client.table(target).select("*").limit(1).execute()
        print(f"✅ {target} exists! Data:", res.data)
    except Exception as e:
        print(f"❌ {target} error:", e)
