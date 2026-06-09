"""
Pydantic models for push notifications.
"""
from pydantic import BaseModel
from typing import Optional, List, Dict

class TokenRegisterRequest(BaseModel):
    student_id: str
    fcm_token: str

class NotificationSendRequest(BaseModel):
    student_id: str
    title: str
    body: str

class DeviceRegistrationRequest(BaseModel):
    user_id: str
    fcm_token: str
    platform: str

class NotificationCreate(BaseModel):
    title: str
    body: str
    target: str # all | department | specific
    target_ids: Optional[List[str]] = None
    data: Optional[Dict[str, str]] = None

class NotificationHistoryResponse(BaseModel):
    id: str
    user_id: str
    title: str
    body: str
    sent_at: str
    read: bool

class BulkNotificationRequest(BaseModel):
    user_ids: List[str]
    title: str
    body: str
    data: Optional[Dict[str, str]] = None

class DepartmentNotificationRequest(BaseModel):
    department_id: str
    title: str
    body: str
    data: Optional[Dict[str, str]] = None
