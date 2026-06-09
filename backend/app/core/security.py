"""
Security module: Supabase JWT decoding and verification.
"""
from dataclasses import dataclass
from typing import Any
from jose import jwt, JWTError
from fastapi import HTTPException, status
from app.core.config import settings

@dataclass
class CurrentUser:
    id: str
    email: str
    system_role: str

    def __getitem__(self, item: str) -> Any:
        """Enables dictionary-like subscripting for backward compatibility with routers."""
        if item in ("id", "user_id"):
            return self.id
        elif item == "email":
            return self.email
        elif item in ("role", "system_role"):
            return self.system_role
        raise KeyError(item)

    def get(self, key: str, default: Any = None) -> Any:
        """Enables dictionary-like .get() access for backward compatibility with routers."""
        try:
            return self[key]
        except KeyError:
            return default
            
    def keys(self):
        return ["id", "user_id", "email", "role", "system_role"]

def verify_supabase_jwt(token: str) -> CurrentUser:
    """
    Decodes and validates a Supabase JWT token.
    Raises HTTPException 401 if invalid or expired.
    """
    try:
        # Supabase JWT signature uses HS256 and SUPABASE_JWT_SECRET
        payload = jwt.decode(
            token,
            settings.SUPABASE_JWT_SECRET,
            algorithms=["HS256"],
            options={"verify_aud": False} # Supabase aud can be 'authenticated' or 'anon'
        )
        
        user_id: str = payload.get("sub")
        email: str = payload.get("email", "")
        
        # In Supabase, custom role claims can be in payload['app_metadata']['role'] 
        # or we fetch/fallback to default system role.
        app_metadata = payload.get("app_metadata", {})
        role: str = app_metadata.get("role") or payload.get("role", "authenticated")
        
        if not user_id:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token claims: missing 'sub'"
            )
            
        return CurrentUser(
            id=user_id,
            email=email,
            system_role=role
        )
    except jwt.ExpiredSignatureError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Session has expired. Please login again."
        )
    except JWTError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid authentication token: {str(e)}"
        )
