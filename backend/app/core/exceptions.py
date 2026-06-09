"""
Custom application exceptions and global FastAPI exception handlers.
"""
from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse

class NotFoundException(Exception):
    def __init__(self, detail: str):
        self.detail = detail

class ForbiddenException(Exception):
    def __init__(self, detail: str):
        self.detail = detail

class ValidationException(Exception):
    def __init__(self, detail: str, field: str = None):
        self.detail = detail
        self.field = field

class SupabaseException(Exception):
    def __init__(self, detail: str, operation: str):
        self.detail = detail
        self.operation = operation

SupabaseError = SupabaseException


class FileProcessingException(Exception):
    def __init__(self, detail: str, filename: str):
        self.detail = detail
        self.filename = filename

class ExpertSystemException(Exception):
    def __init__(self, detail: str, student_id: str):
        self.detail = detail
        self.student_id = student_id

# Backward compatibility aliases
NotFoundError = NotFoundException
ValidationError = ValidationException
ForbiddenError = ForbiddenException
UnauthorizedError = ForbiddenException



def register_exception_handlers(app: FastAPI):
    """Registers global handlers for custom exceptions."""
    
    @app.exception_handler(NotFoundException)
    async def not_found_handler(request: Request, exc: NotFoundException):
        return JSONResponse(
            status_code=status.HTTP_404_NOT_FOUND,
            content={"success": False, "error": "Not Found", "detail": exc.detail}
        )

    @app.exception_handler(ForbiddenException)
    async def forbidden_handler(request: Request, exc: ForbiddenException):
        return JSONResponse(
            status_code=status.HTTP_403_FORBIDDEN,
            content={"success": False, "error": "Forbidden", "detail": exc.detail}
        )

    @app.exception_handler(ValidationException)
    async def validation_handler(request: Request, exc: ValidationException):
        return JSONResponse(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            content={"success": False, "error": "Validation Error", "detail": exc.detail, "field": exc.field}
        )

    @app.exception_handler(SupabaseException)
    async def supabase_handler(request: Request, exc: SupabaseException):
        return JSONResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            content={"success": False, "error": "Database Error", "detail": exc.detail, "operation": exc.operation}
        )

    @app.exception_handler(FileProcessingException)
    async def file_processing_handler(request: Request, exc: FileProcessingException):
        return JSONResponse(
            status_code=status.HTTP_400_BAD_REQUEST,
            content={"success": False, "error": "File Processing Error", "detail": exc.detail, "filename": exc.filename}
        )

    @app.exception_handler(ExpertSystemException)
    async def expert_system_handler(request: Request, exc: ExpertSystemException):
        return JSONResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            content={"success": False, "error": "Expert System Error", "detail": exc.detail, "student_id": exc.student_id}
        )

    @app.exception_handler(Exception)
    async def general_exception_handler(request: Request, exc: Exception):
        return JSONResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            content={"success": False, "error": "Internal Server Error", "detail": str(exc)}
        )
