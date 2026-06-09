"""
Creates and exports two Supabase clients:
- supabase_admin : uses SERVICE_ROLE key, bypasses RLS. Used for all backend writes.
- get_user_client: attaches user JWT to respect RLS. Used when we want to honour permissions.
"""
from supabase import create_client, Client
from app.core.config import settings

# Admin client - bypasses RLS (used in services that write on behalf of the system)
supabase_admin: Client = create_client(
    settings.SUPABASE_URL,
    settings.SUPABASE_SERVICE_ROLE_KEY,
)

def get_user_client(jwt_token: str) -> Client:
    """Returns a Supabase client that sends the user's JWT, so RLS applies."""
    return create_client(
        settings.SUPABASE_URL,
        settings.SUPABASE_ANON_KEY,
        options={"headers": {"Authorization": f"Bearer {jwt_token}"}},
    )
