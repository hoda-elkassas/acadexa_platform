import os
import shutil
import uuid
from pathlib import Path
from fastapi import UploadFile


ALLOWED_EXTENSIONS = {".xlsx", ".xls", ".pdf"}


def get_file_extension(filename: str) -> str:
    return os.path.splitext(filename)[1].lower()


def validate_file_type(filename: str, allowed: list[str] | None = None) -> bool:
    if allowed is None:
        allowed = ["xlsx", "xls", "pdf"]
    ext = get_file_extension(filename).lstrip(".")
    return ext in allowed


async def save_temp_file(upload_file: UploadFile, temp_dir: str = "./temp_uploads") -> str:
    os.makedirs(temp_dir, exist_ok=True)
    unique_name = f"{uuid.uuid4()}_{upload_file.filename}"
    temp_path = os.path.join(temp_dir, unique_name)
    with open(temp_path, "wb") as buffer:
        shutil.copyfileobj(upload_file.file, buffer)
    return temp_path


def delete_temp_file(path: str) -> None:
    if os.path.exists(path):
        os.remove(path)


def upload_to_supabase_storage(local_path: str, bucket: str, key: str) -> str | None:
    from app.core.database import supabase_admin
    try:
        with open(local_path, "rb") as f:
            res = supabase_admin.storage.from_(bucket).upload(key, f)
        return res
    except Exception:
        return None
