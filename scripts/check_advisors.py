import os
from supabase import create_client, Client

url = "https://buuisbquunicouyxkpbf.supabase.co"
key = ""

if os.path.exists("/home/mostafa/Work/acadexa_platform/backend/.env"):
    with open("/home/mostafa/Work/acadexa_platform/backend/.env", "r") as f:
        for l in f:
            if l.startswith("SUPABASE_SERVICE_ROLE_KEY"):
                key = l.split("=")[1].strip().strip('"')

if not key:
    key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY", "")

supabase: Client = create_client(url, key)

try:
    res = supabase.table("academic_advisors").select("*").limit(5).execute()
    print("Advisors:", res.data)
except Exception as e:
    print("Error advisors:", e)

try:
    res = supabase.table("student_latest_analysis").select("*").limit(5).execute()
    print("Latest analysis:", res.data)
except Exception as e:
    print("Error analysis:", e)
