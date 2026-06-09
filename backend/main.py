"""
Entry point of the Academic Advisor FastAPI backend.
Registers all routers, configures CORS, and sets up global exception handling.
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.core.exceptions import register_exception_handlers
from app.routers import health, upload, analysis, reports, notifications, curriculum, students

app = FastAPI(
    title="Academic Advisor API",
    description="Expert system backend for academic advising",
    version="1.0.0",
    docs_url="/docs" if settings.ENVIRONMENT == "development" else None,
    redoc_url="/redoc" if settings.ENVIRONMENT == "development" else None,
)

# CORS
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
app.include_router(upload.router,          prefix="/api/v1/upload",        tags=["Upload"])
app.include_router(analysis.router,        prefix="/api/v1/analysis",      tags=["Analysis"])
app.include_router(reports.router,         prefix="/api/v1/reports",        tags=["Reports"])
app.include_router(notifications.router,   prefix="/api/v1/notifications",  tags=["Notifications"])
app.include_router(curriculum.router,      prefix="/api/v1/curriculum",     tags=["Curriculum"])
app.include_router(students.router,        prefix="/api/v1/students",       tags=["Students"])
