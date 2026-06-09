"""
GET /health
Returns 200 OK with app version, DB latency, and Firebase status.
"""
from fastapi import APIRouter
import time
from app.core.database import supabase_admin
from app.services.notification_service import firebase_initialized

router = APIRouter()

@router.get("/health")
async def health_check():
    start_time = time.time()
    try:
        # DB ping and measure latency
        supabase_admin.table("departments").select("id").limit(1).execute()
        latency_ms = (time.time() - start_time) * 1000
        db_status = "connected"
    except Exception:
        latency_ms = -1
        db_status = "unreachable"

    return {
        "status": "ok",
        "version": "1.0.0",
        "database": {
            "status": db_status,
            "latency_ms": round(latency_ms, 2) if latency_ms >= 0 else None
        },
        "firebase": {
            "initialized": firebase_initialized,
            "mode": "active" if firebase_initialized else "mock"
        }
    }
