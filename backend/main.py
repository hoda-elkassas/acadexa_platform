"""
Entry point of the Academic Advisor FastAPI backend.
Registers all routers, configures CORS, sets up global exception handling, and verifies database connection.
"""
from contextlib import asynccontextmanager
import logging
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.core.exceptions import register_exception_handlers
from app.core.database import supabase_admin
from app.routers import health, upload, analysis, reports, notifications, curriculum, students

# Configure logging
logging.basicConfig(level=settings.LOG_LEVEL)
logger = logging.getLogger("main")

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: Verify Supabase connection
    logger.info("Verifying Supabase connection on startup...")
    try:
        # Perform a light query to verify connectivity and admin access
        res = supabase_admin.table("departments").select("id").limit(1).execute()
        logger.info(f"Supabase connection successful. Active database tables verified.")
    except Exception as e:
        logger.error(f"Critical error on startup: Supabase connection failed: {str(e)}")
        # We don't raise error to allow server boot and diagnostic health endpoints to return 500
    
    yield
    # Shutdown actions if any
    logger.info("Application shutting down...")

app = FastAPI(
    title="Academic Advisor API",
    description="Expert system backend for academic advising",
    version="1.0.0",
    docs_url="/docs" if not settings.is_production else None,
    redoc_url="/redoc" if not settings.is_production else None,
    lifespan=lifespan,
)

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Exception handlers
register_exception_handlers(app)

# Routers
app.include_router(health.router,          tags=["Health"])
app.include_router(upload.router,          prefix="/api/v1",        tags=["Upload"])
app.include_router(analysis.router,        prefix="/api/v1",        tags=["Analysis"])
app.include_router(reports.router,         prefix="/api/v1",        tags=["Reports"])
app.include_router(notifications.router,   prefix="/api/v1",        tags=["Notifications"])
app.include_router(curriculum.router,      prefix="/api/v1",        tags=["Curriculum"])
app.include_router(students.router,        prefix="/api/v1",        tags=["Students"])
