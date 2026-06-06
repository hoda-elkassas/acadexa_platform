"""
Role-based access control for the Acadexa FastAPI backend.

Usage in routes:
    from core.security.roles import require_role, AppRole, get_current_user

    @router.get("/students/")
    async def get_students(user=Depends(require_role(AppRole.admin, AppRole.academic_advisor))):
        ...

    # Optional auth (any logged-in user):
    @router.get("/curriculum/plans")
    async def get_plans(user=Depends(get_current_user)):
        ...
"""

import os
import logging
from enum import Enum
from typing import Optional

import httpx
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

from core.db.supabase_client import SupabaseClient

logger = logging.getLogger("acadexa.roles")

# ── Bearer token extractor ──────────────────────────────────────────────────
_bearer = HTTPBearer(auto_error=False)


# ── Role enum ───────────────────────────────────────────────────────────────
class AppRole(str, Enum):
    admin            = "admin"
    academic_advisor = "academic_advisor"
    dashboard_viewer = "dashboard_viewer"
    user             = "user"

    @classmethod
    def has_write_access(cls, role: "AppRole") -> bool:
        return role in (cls.admin, cls.academic_advisor)

    @classmethod
    def can_see_all_students(cls, role: "AppRole") -> bool:
        return role in (cls.admin, cls.academic_advisor, cls.dashboard_viewer)


# ── Validate token & fetch user profile ─────────────────────────────────────
async def _resolve_user(token: str) -> dict:
    """
    1. Validate Bearer token via Supabase Auth API  → get user_id
    2. Fetch role from user_profiles using service_role client
    Returns: { user_id, email, role: AppRole, student_id }
    """
    supabase_url = os.getenv("SUPABASE_URL", "").rstrip("/")
    anon_key     = os.getenv("SUPABASE_ANON_KEY", "")

    # Step 1 — verify token
    async with httpx.AsyncClient(timeout=10.0) as http:
        resp = await http.get(
            f"{supabase_url}/auth/v1/user",
            headers={
                "Authorization": f"Bearer {token}",
                "apikey": anon_key,
            },
        )

    if resp.status_code != 200:
        logger.warning("Token validation failed: %s", resp.text)
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="رمز المصادقة غير صالح أو منتهي الصلاحية",
        )

    auth_user = resp.json()
    user_id   = auth_user.get("id")

    # Step 2 — fetch role from user_profiles (service_role bypasses RLS)
    supabase = SupabaseClient.get_client()
    if supabase is None:
        raise HTTPException(status_code=503, detail="قاعدة البيانات غير متاحة")

    profile_res = (
        supabase.table("user_profiles")
        .select("role, student_id, full_name, department_id")
        .eq("id", user_id)
        .execute()
    )

    if not profile_res.data:
        logger.warning("No user_profiles record for user_id=%s", user_id)
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="لم يتم العثور على ملف تعريف المستخدم",
        )

    profile = profile_res.data[0]

    try:
        role = AppRole(profile["role"])
    except ValueError:
        role = AppRole.user

    return {
        "user_id":       user_id,
        "email":         auth_user.get("email"),
        "role":          role,
        "student_id":    profile.get("student_id"),
        "full_name":     profile.get("full_name"),
        "department_id": profile.get("department_id"),
    }


# ── FastAPI dependencies ─────────────────────────────────────────────────────

async def get_current_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(_bearer),
) -> Optional[dict]:
    """
    Optional auth dependency.
    Returns user dict if token provided and valid, else None.
    Use for endpoints that behave differently for authenticated users.
    """
    if credentials is None:
        return None
    return await _resolve_user(credentials.credentials)


async def require_auth(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(_bearer),
) -> dict:
    """
    Strict auth dependency — any valid logged-in user.
    Raises 401 if not authenticated.
    """
    if credentials is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="يجب تسجيل الدخول أولاً",
        )
    return await _resolve_user(credentials.credentials)


def require_role(*roles: AppRole):
    """
    Role-gated dependency factory.

    Example:
        @router.post("/upload-to-db")
        async def upload(user=Depends(require_role(AppRole.admin, AppRole.academic_advisor))):
            ...
    """
    async def _check(
        credentials: Optional[HTTPAuthorizationCredentials] = Depends(_bearer),
    ) -> dict:
        if credentials is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="يجب تسجيل الدخول أولاً",
            )
        user = await _resolve_user(credentials.credentials)
        if user["role"] not in roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"ليس لديك صلاحية. الأدوار المسموحة: {[r.value for r in roles]}",
            )
        return user

    return _check
