#!/usr/bin/env python3
"""
Acadexa Platform - Database Connection Diagnostic & Fixer
=========================================================
Run this script to:
1. Check which tables have permission errors
2. Verify working tables and their row counts
3. Test backend import
"""

import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent / "python_backend"))

from dotenv import load_dotenv
load_dotenv("backend/.env")

print("=" * 60)
print("🎓  ACADEXA  –  Database Diagnostic Report")
print("=" * 60)

# ── 1. Environment ────────────────────────────────────────────
print("\n📋  1. Environment Variables")
url = os.getenv("SUPABASE_URL", "")
svc = os.getenv("SUPABASE_SERVICE_ROLE_KEY", "")
anon = os.getenv("SUPABASE_ANON_KEY", "")

print(f"   SUPABASE_URL              : {url or '❌ NOT SET'}")
print(f"   SUPABASE_SERVICE_ROLE_KEY : {'✅ ' + svc[:15] + '...' if svc else '❌ NOT SET'}")
print(f"   SUPABASE_ANON_KEY         : {'✅ ' + anon[:30] + '...' if anon else '❌ NOT SET'}")

if not url:
    print("\n❌  SUPABASE_URL is missing. Check python_backend/.env")
    sys.exit(1)

# ── 2. Connection ─────────────────────────────────────────────
print("\n🔌  2. Supabase Connection Test")
try:
    from supabase import create_client
    key = svc or anon
    client = create_client(url, key)
    print(f"   ✅ Client created (using {'service_role' if svc else 'anon'} key)")
except Exception as e:
    print(f"   ❌ Failed to create client: {e}")
    sys.exit(1)

# ── 3. Table Permission Audit ─────────────────────────────────
print("\n🗂️   3. Table Permission Audit")

ALL_TABLES = [
    "students", "student_semesters", "student_courses",
    "departments", "study_plans", "courses", "prerequisites",
    "elective_groups", "elective_group_courses",
    "plan_structure", "academic_load_rules", "graduation_requirements",
    "grading_scales", "grade_scale_items",
    "analysis_results", "analysis_issues", "analysis_recommendations",
    "import_jobs", "field_training_rules",
]

ok_tables = []
broken_tables = []

for table in ALL_TABLES:
    try:
        res = client.table(table).select("*", count="exact").limit(1).execute()
        ok_tables.append((table, res.count))
        print(f"   ✅  {table:<35} {res.count:>6} rows")
    except Exception as e:
        broken_tables.append(table)
        msg = str(e)
        if "permission denied" in msg.lower():
            print(f"   ❌  {table:<35}  PERMISSION DENIED")
        elif "does not exist" in msg.lower():
            print(f"   ⚠️   {table:<35}  TABLE NOT FOUND")
        else:
            print(f"   ❌  {table:<35}  {msg[:60]}")

# ── 4. Summary ────────────────────────────────────────────────
print(f"\n📊  4. Summary")
print(f"   Working tables : {len(ok_tables)} / {len(ALL_TABLES)}")
print(f"   Broken tables  : {len(broken_tables)}")
if broken_tables:
    print(f"\n⚠️   ACTION REQUIRED — Run the SQL fix script:")
    print(f"   File: scripts/fix_supabase_permissions.sql")
    print(f"   Where: Supabase Dashboard → SQL Editor")
    print(f"\n   Broken tables needing GRANT:")
    for t in broken_tables:
        print(f"      • {t}")

# ── 5. Backend Import Test ────────────────────────────────────
print(f"\n🚀  5. Backend Import Test")
try:
    sys.path.insert(0, str(Path(__file__).parent.parent / "backend"))
    from main import app
    route_count = len([r for r in app.routes if hasattr(r, "methods")])
    print(f"   ✅  FastAPI app imported OK — {route_count} routes registered")
except Exception as e:
    print(f"   ❌  Import failed: {e}")

print("\n" + "=" * 60)
print("📖  To start the backend: ")
print("   cd backend && source ../python_backend/venv/bin/activate && uvicorn main:app --reload")
print("=" * 60)
