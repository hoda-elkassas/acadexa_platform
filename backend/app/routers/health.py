"""
GET /health
Returns 200 OK with app version and DB connectivity status.
Used by Docker healthcheck and load balancers.
"""
from fastapi import APIRouter
from app.core.database import supabase_admin

router = APIRouter()

@router.get("/health")
async def health_check():
    try:
        # Quick DB ping
        supabase_admin.table("departments").select("id").limit(1).execute()
        db_status = "connected"
    except Exception:
        db_status = "unreachable"

    return {
        "status": "ok",
        "version": "1.0.0",
        "database": db_status,
    }
