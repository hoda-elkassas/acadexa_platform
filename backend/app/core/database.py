"""
Creates and exports two Supabase clients and async helper database access functions.

The supabase-py client is synchronous under the hood (uses httpx sync),
so all helpers use asyncio.to_thread() to avoid blocking the FastAPI event loop.
"""
import asyncio
import logging
from typing import Any, Dict, List, Optional

from supabase import create_client, Client

from app.core.config import settings
from app.core.exceptions import SupabaseException

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Admin client (service_role) — bypasses RLS — used for all FastAPI writes
# ---------------------------------------------------------------------------
supabase_admin: Client = create_client(
    settings.SUPABASE_URL,
    settings.SUPABASE_SERVICE_ROLE_KEY,
)


def get_user_client(jwt_token: str) -> Client:
    """
    Returns a Supabase client scoped to the user's JWT so that RLS applies.
    Use this only when the operation must respect row-level security.
    """
    from supabase._sync.client import SyncClient
    from supabase.lib.client_options import ClientOptions

    opts = ClientOptions(
        headers={"Authorization": f"Bearer {jwt_token}"},
    )
    return SyncClient(
        supabase_url=settings.SUPABASE_URL,
        supabase_key=settings.SUPABASE_ANON_KEY,
        options=opts,
    )


# ---------------------------------------------------------------------------
# Async helper wrappers
# ---------------------------------------------------------------------------

async def execute_rpc(function_name: str, params: Optional[Dict[str, Any]] = None) -> Any:
    """Wraps supabase_admin.rpc() with error handling. Runs in a thread."""
    def _call() -> Any:
        res = supabase_admin.rpc(function_name, params or {}).execute()
        return res.data

    try:
        return await asyncio.to_thread(_call)
    except SupabaseException:
        raise
    except Exception as e:
        raise SupabaseException(
            detail=f"RPC '{function_name}' failed: {e}",
            operation=f"rpc_{function_name}",
        )


async def fetch_one(table: str, filters: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    """Fetches a single row matching *filters* from *table*."""
    def _call() -> Optional[Dict[str, Any]]:
        query = supabase_admin.table(table).select("*")
        for key, val in filters.items():
            query = query.eq(key, val)
        res = query.limit(1).execute()
        return res.data[0] if res.data else None

    try:
        return await asyncio.to_thread(_call)
    except SupabaseException:
        raise
    except Exception as e:
        raise SupabaseException(
            detail=f"fetch_one('{table}', {filters}) failed: {e}",
            operation=f"fetch_one_{table}",
        )


async def fetch_many(
    table: str,
    filters: Optional[Dict[str, Any]] = None,
    order_by: Optional[str] = None,
    limit: Optional[int] = None,
) -> List[Dict[str, Any]]:
    """Fetches multiple rows. *order_by* accepts ``"-col"`` for descending."""
    def _call() -> List[Dict[str, Any]]:
        query = supabase_admin.table(table).select("*")
        if filters:
            for key, val in filters.items():
                query = query.eq(key, val)
        if order_by:
            if order_by.startswith("-"):
                query = query.order(order_by[1:], desc=True)
            else:
                query = query.order(order_by, desc=False)
        if limit:
            query = query.limit(limit)
        res = query.execute()
        return res.data or []

    try:
        return await asyncio.to_thread(_call)
    except SupabaseException:
        raise
    except Exception as e:
        raise SupabaseException(
            detail=f"fetch_many('{table}') failed: {e}",
            operation=f"fetch_many_{table}",
        )


async def insert_one(table: str, data: Dict[str, Any]) -> Dict[str, Any]:
    """Inserts a single row into *table* and returns the created record."""
    def _call() -> Dict[str, Any]:
        res = supabase_admin.table(table).insert(data).execute()
        if not res.data:
            raise SupabaseException(
                detail=f"Insert into '{table}' returned no data.",
                operation=f"insert_one_{table}",
            )
        return res.data[0]

    try:
        return await asyncio.to_thread(_call)
    except SupabaseException:
        raise
    except Exception as e:
        raise SupabaseException(
            detail=f"insert_one('{table}') failed: {e}",
            operation=f"insert_one_{table}",
        )


async def insert_many(table: str, data_list: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Inserts multiple rows into *table*."""
    def _call() -> List[Dict[str, Any]]:
        if not data_list:
            return []
        res = supabase_admin.table(table).insert(data_list).execute()
        return res.data or []

    try:
        return await asyncio.to_thread(_call)
    except SupabaseException:
        raise
    except Exception as e:
        raise SupabaseException(
            detail=f"insert_many('{table}') failed: {e}",
            operation=f"insert_many_{table}",
        )


async def update_one(table: str, filters: Dict[str, Any], data: Dict[str, Any]) -> Dict[str, Any]:
    """Updates a single row matching *filters* in *table*."""
    def _call() -> Dict[str, Any]:
        query = supabase_admin.table(table).update(data)
        for key, val in filters.items():
            query = query.eq(key, val)
        res = query.execute()
        if not res.data:
            raise SupabaseException(
                detail=f"Update in '{table}' matching {filters} returned no data.",
                operation=f"update_one_{table}",
            )
        return res.data[0]

    try:
        return await asyncio.to_thread(_call)
    except SupabaseException:
        raise
    except Exception as e:
        raise SupabaseException(
            detail=f"update_one('{table}', {filters}) failed: {e}",
            operation=f"update_one_{table}",
        )


async def delete_one(table: str, filters: Dict[str, Any]) -> bool:
    """Deletes a single row matching *filters* in *table*."""
    def _call() -> bool:
        query = supabase_admin.table(table).delete()
        for key, val in filters.items():
            query = query.eq(key, val)
        res = query.execute()
        return len(res.data) > 0 if res.data else False

    try:
        return await asyncio.to_thread(_call)
    except SupabaseException:
        raise
    except Exception as e:
        raise SupabaseException(
            detail=f"delete_one('{table}', {filters}) failed: {e}",
            operation=f"delete_one_{table}",
        )
