"""
Notifications Router: Handles Firebase Cloud Messaging (FCM) registration and advisor push alerts.
"""
from fastapi import APIRouter, Depends, HTTPException
from typing import Dict, Any
from app.core.dependencies import get_current_user, check_role
from app.services.notification_service import NotificationService
from app.models.notification import (
    TokenRegisterRequest,
    NotificationSendRequest,
    DepartmentNotificationRequest,
    BulkNotificationRequest
)

router = APIRouter(prefix="/notifications", tags=["Notifications"])

@router.post("/register", response_model=Dict[str, Any])
async def register_fcm_token(
    req: TokenRegisterRequest,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Registers an FCM token for a student to receive notifications.
    """
    try:
        ok = NotificationService.register_device(
            student_id=req.student_id,
            fcm_token=req.fcm_token
        )
        if not ok:
            raise HTTPException(status_code=400, detail="Failed to register push token")
        return {"status": "success", "message": "Token registered successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/send", response_model=Dict[str, Any])
async def send_alert_notification(
    req: NotificationSendRequest,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Sends academic advice or alerts directly to a student.
    """
    check_role(current_user, ["advisor", "college_admin", "department_head", "super_admin"])
    try:
        sent_by = current_user.get("email") or "advisor"
        ok = NotificationService.send_to_user(
            student_id=req.student_id,
            title=req.title,
            body=req.body,
            sent_by=sent_by
        )
        if not ok:
            raise HTTPException(status_code=500, detail="Failed to dispatch notification")
        return {"status": "success", "message": "Notification dispatched successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/broadcast-department", response_model=Dict[str, Any])
async def broadcast_department_notification(
    req: DepartmentNotificationRequest,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Broadcasts message to all students in a specific department.
    """
    check_role(current_user, ["advisor", "college_admin", "department_head", "super_admin"])
    try:
        sent_by = current_user.get("email") or "advisor"
        count = NotificationService.send_to_department(
            department_id=req.department_id,
            title=req.title,
            body=req.body,
            data=req.data,
            sent_by=sent_by
        )
        return {
            "status": "success",
            "message": f"Broadcast complete. Dispatched to {count} devices."
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/send-bulk", response_model=Dict[str, Any])
async def send_bulk_notification(
    req: BulkNotificationRequest,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Sends bulk push notifications to multiple student accounts.
    """
    check_role(current_user, ["advisor", "college_admin", "department_head", "super_admin"])
    try:
        sent_by = current_user.get("email") or "advisor"
        count = NotificationService.send_bulk(
            student_ids=req.user_ids,
            title=req.title,
            body=req.body,
            data=req.data,
            sent_by=sent_by
        )
        return {
            "status": "success",
            "message": f"Bulk notification complete. Dispatched to {count} devices."
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
