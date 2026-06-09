"""
FastAPI dependencies: JWT verification, role guards, and current user extraction.
"""
import logging
from typing import Callable, List, Union

from fastapi import Depends, Header, HTTPException, status

from app.core.security import verify_supabase_jwt, CurrentUser
from app.core.database import supabase_admin

logger = logging.getLogger(__name__)


async def get_current_user(authorization: str = Header(...)) -> CurrentUser:
    """
    Extracts and verifies the Supabase JWT from the Authorization header.
    Enriches the role from the app_users table if available.
    """
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing or invalid Authorization header. Must start with 'Bearer '",
        )

    token = authorization.split(" ", 1)[1]
    user = verify_supabase_jwt(token)

    # Enrich role from database (app_users table overrides JWT claim)
    try:
        profile = (
            supabase_admin.table("app_users")
            .select("system_role")
            .eq("id", user.id)
            .maybe_single()
            .execute()
        )
        if profile.data and profile.data.get("system_role"):
            user.system_role = profile.data["system_role"]
    except Exception:
        # Fallback to JWT-derived role if database profile unavailable
        pass

    return user


def require_role(*allowed_roles: str) -> Callable:
    """
    Factory that returns a dependency checking the user's role.

    Usage::

        @router.get("/admin-only")
        async def admin_endpoint(user = Depends(require_role("SYSTEM_MANAGEMENT", "DEVELOPER"))):
            ...
    """
    async def _checker(user: CurrentUser = Depends(get_current_user)) -> CurrentUser:
        if user.system_role not in allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Role '{user.system_role}' is not allowed. Required: {list(allowed_roles)}",
            )
        return user

    return _checker


# ── Shortcut dependencies ────────────────────────────────────────────────
# These are standalone Depends-compatible callables (not invocations of require_role).

async def require_admin(user: CurrentUser = Depends(get_current_user)) -> CurrentUser:
    """Allows only SYSTEM_MANAGEMENT and DEVELOPER roles."""
    if user.system_role not in ("SYSTEM_MANAGEMENT", "DEVELOPER"):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"Admin access required. Your role: '{user.system_role}'",
        )
    return user


async def require_advisor(user: CurrentUser = Depends(get_current_user)) -> CurrentUser:
    """Allows admin roles plus ACADEMIC_OPERATIONS and ACADEMIC_ADVISING."""
    allowed = ("SYSTEM_MANAGEMENT", "DEVELOPER", "ACADEMIC_OPERATIONS", "ACADEMIC_ADVISING")
    if user.system_role not in allowed:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"Advisor access required. Your role: '{user.system_role}'",
        )
    return user


# ── Backward-compatibility helper for existing routers ───────────────────

def check_role(user: Union[CurrentUser, dict], allowed_roles: List[str]) -> None:
    """
    Validates user role against a list of friendly role names.
    Supports both CurrentUser dataclass and legacy dict objects.
    """
    role_mapping = {
        "super_admin": "SYSTEM_MANAGEMENT",
        "college_admin": "DEVELOPER",
        "department_head": "ACADEMIC_OPERATIONS",
        "advisor": "ACADEMIC_ADVISING",
    }

    user_role = user.system_role if isinstance(user, CurrentUser) else user.get("role")
    mapped_allowed = [role_mapping.get(r, r) for r in allowed_roles]

    if user_role not in mapped_allowed:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"User role '{user_role}' is not authorized. Required one of: {allowed_roles}",
        )
