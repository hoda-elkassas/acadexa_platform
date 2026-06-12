import asyncio
import httpx
from typing import Any, Dict, List, Optional
from fastapi import APIRouter, Header, HTTPException, Request, Response
from pydantic import BaseModel

from app.core.config import settings
from app.core.database import supabase_admin, get_user_client

router = APIRouter(prefix="/db", tags=["Database Proxy"])

@router.api_route("/supabase/{service}/v1/{path:path}", methods=["GET", "POST", "PATCH", "PUT", "DELETE", "OPTIONS"])
async def proxy_supabase(
    service: str,
    path: str,
    request: Request,
):
    target_base = settings.SUPABASE_URL
    target_url = f"{target_base}/{service}/v1/{path}"
    
    query_params = request.query_params
    if query_params:
        target_url = f"{target_url}?{query_params}"

    headers = dict(request.headers)
    
    from urllib.parse import urlparse
    parsed_supabase_url = urlparse(settings.SUPABASE_URL)
    headers["host"] = parsed_supabase_url.netloc
    
    headers.pop("content-length", None)
    
    # Always supply the real Supabase api key to authenticate downstream
    headers["apikey"] = settings.SUPABASE_ANON_KEY
    
    body = await request.body()
    
    async with httpx.AsyncClient() as client:
        response = await client.request(
            method=request.method,
            url=target_url,
            headers=headers,
            content=body,
            timeout=30.0
        )
        
        res_headers = {}
        for k, v in response.headers.items():
            if k.lower() not in ["content-length", "transfer-encoding", "content-encoding"]:
                res_headers[k] = v
                
        return Response(
            content=response.content,
            status_code=response.status_code,
            headers=res_headers
        )

class FilterModel(BaseModel):
    type: str  # eq, neq, gt, gte, lt, lte, like, ilike, in, order
    column: str
    value: Any = None
    desc: Optional[bool] = False

class QueryPayload(BaseModel):
    table: str
    select: Optional[str] = "*"
    filters: Optional[List[FilterModel]] = []
    limit: Optional[int] = None

class InsertPayload(BaseModel):
    table: str
    data: Any  # Dict or List of Dicts

class UpdatePayload(BaseModel):
    table: str
    filters: Optional[List[FilterModel]] = []
    data: Dict[str, Any]

class DeletePayload(BaseModel):
    table: str
    filters: Optional[List[FilterModel]] = []


def get_scoped_client(authorization: Optional[str]):
    token = None
    if authorization and authorization.startswith("Bearer "):
        token = authorization.split(" ")[1]
    
    if token:
        try:
            return get_user_client(token)
        except Exception as e:
            # Fallback to admin if token loading fails
            pass
    return supabase_admin


def apply_filters(query, filters: Optional[List[FilterModel]]):
    if not filters:
        return query
    for f in filters:
        ftype = f.type
        col = f.column
        val = f.value
        if ftype == "eq":
            query = query.eq(col, val)
        elif ftype == "neq":
            query = query.neq(col, val)
        elif ftype == "gt":
            query = query.gt(col, val)
        elif ftype == "gte":
            query = query.gte(col, val)
        elif ftype == "lt":
            query = query.lt(col, val)
        elif ftype == "lte":
            query = query.lte(col, val)
        elif ftype == "like":
            query = query.like(col, val)
        elif ftype == "ilike":
            query = query.ilike(col, val)
        elif ftype == "in":
            query = query.in_(col, val)
        elif ftype == "order":
            query = query.order(col, desc=f.desc or False)
    return query


@router.post("/query")
async def query_table(
    payload: QueryPayload,
    authorization: Optional[str] = Header(None)
):
    try:
        client = get_scoped_client(authorization)
        query = client.table(payload.table).select(payload.select or "*")
        query = apply_filters(query, payload.filters)
        
        if payload.limit:
            query = query.limit(payload.limit)

        def _run():
            return query.execute()

        res = await asyncio.to_thread(_run)
        return res.data
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/insert")
async def insert_record(
    payload: InsertPayload,
    authorization: Optional[str] = Header(None)
):
    try:
        client = get_scoped_client(authorization)
        
        def _run():
            return client.table(payload.table).insert(payload.data).execute()

        res = await asyncio.to_thread(_run)
        return res.data
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/update")
async def update_record(
    payload: UpdatePayload,
    authorization: Optional[str] = Header(None)
):
    try:
        client = get_scoped_client(authorization)
        
        def _run():
            query = client.table(payload.table).update(payload.data)
            query = apply_filters(query, payload.filters)
            return query.execute()

        res = await asyncio.to_thread(_run)
        return res.data
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/delete")
async def delete_record(
    payload: DeletePayload,
    authorization: Optional[str] = Header(None)
):
    try:
        client = get_scoped_client(authorization)
        
        def _run():
            query = client.table(payload.table).delete()
            query = apply_filters(query, payload.filters)
            return query.execute()

        res = await asyncio.to_thread(_run)
        return res.data
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
