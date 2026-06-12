import os
import sys
from pathlib import Path
from dotenv import load_dotenv
from supabase import create_client

# Load environment
load_dotenv("backend/.env")

url = os.getenv("SUPABASE_URL")
key = os.getenv("SUPABASE_SERVICE_ROLE_KEY")

if not url or not key:
    print("Error: SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY not set in backend/.env")
    sys.exit(1)

print(f"Connecting to Supabase at {url}...")
client = create_client(url, key)

# Define users to create
test_users = [
    {
        "email": "admin@acadexa.com",
        "password": "Password123",
        "email_confirm": True,
        "user_metadata": {
            "role": "admin",
            "full_name": "مدير النظام"
        }
    },
    {
        "email": "advisor@acadexa.com",
        "password": "Password123",
        "email_confirm": True,
        "user_metadata": {
            "role": "academic_advisor",
            "full_name": "المرشد الأكاديمي"
        }
    }
]

for user_data in test_users:
    email = user_data["email"]
    print(f"\nCreating/Checking user: {email}...")
    try:
        # Create user via admin API (bypasses email confirmation requirements)
        res = client.auth.admin.create_user(user_data)
        print(f"✅ User created successfully! ID: {res.user.id}")
    except Exception as e:
        error_msg = str(e)
        if "already exists" in error_msg.lower() or "already registered" in error_msg.lower():
            print(f"ℹ️ User {email} already exists.")
        else:
            print(f"❌ Failed to create user {email}: {e}")

print("\nDone provisioning users.")
