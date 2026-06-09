"""
Notification Service: Handles registration of FCM push tokens, direct notifications, department broadcasts, and chunked bulk messages.
"""
from typing import Dict, Any, List, Optional
import os
import logging
from app.core.database import supabase_admin
from app.core.exceptions import SupabaseError

# Initialize Firebase Admin gracefully
import firebase_admin
from firebase_admin import credentials, messaging

logger = logging.getLogger(__name__)

firebase_initialized = False
try:
    firebase_admin.get_app()
    firebase_initialized = True
except ValueError:
    cred_path = os.getenv("FIREBASE_CREDENTIALS_PATH")
    if cred_path and os.path.exists(cred_path):
        try:
            cred = credentials.Certificate(cred_path)
            firebase_admin.initialize_app(cred)
            firebase_initialized = True
            logger.info("Firebase Admin successfully initialized from environment credentials.")
        except Exception as e:
            logger.warning(f"Failed to initialize Firebase with credentials at {cred_path}: {e}")
    else:
        logger.warning("FCM credentials path (FIREBASE_CREDENTIALS_PATH) not set or not found. Operating in Mock mode.")

class NotificationService:
    @staticmethod
    def register_device(student_id: str, fcm_token: str, platform: Optional[str] = "android") -> bool:
        """
        Saves student FCM token for push notifications.
        """
        try:
            # Upsert token or update student profile
            res = supabase_admin.table("students").update({
                "fcm_token": fcm_token,
                "device_platform": platform
            }).eq("id", student_id).execute()
            
            # Also save to dedicated devices table if exists, otherwise fallback is handled
            try:
                supabase_admin.table("student_devices").upsert({
                    "student_id": student_id,
                    "fcm_token": fcm_token,
                    "platform": platform
                }).execute()
            except Exception:
                pass
                
            return len(res.data) > 0
        except Exception as e:
            raise SupabaseError(f"Failed to register push token: {str(e)}")

    @staticmethod
    def register_token(student_id: str, fcm_token: str) -> bool:
        return NotificationService.register_device(student_id, fcm_token)

    @staticmethod
    def _save_to_history(student_id: str, title: str, body: str, sent_by: str = "system", status: str = "sent"):
        try:
            supabase_admin.table("notification_history").insert({
                "student_id": student_id,
                "title": title,
                "body": body,
                "sent_by": sent_by,
                "status": status
            }).execute()
        except Exception:
            # Fallback to audit log if table does not exist
            try:
                supabase_admin.table("audit_logs").insert({
                    "action": "SEND_NOTIFICATION",
                    "details": {
                        "student_id": student_id,
                        "title": title,
                        "body": body,
                        "sent_by": sent_by,
                        "status": status
                    }
                }).execute()
            except Exception:
                pass

    @staticmethod
    def send_to_user(student_id: str, title: str, body: str, data: Optional[Dict[str, str]] = None, sent_by: str = "system") -> bool:
        """
        Sends push notification to a specific student.
        """
        student_res = supabase_admin.table("students").select("fcm_token").eq("id", student_id).execute()
        token = student_res.data[0].get("fcm_token") if student_res.data else None

        if not token:
            logger.info(f"[Mock Mode] No token registered for student {student_id}. Message logged: '{title}': '{body}'")
            NotificationService._save_to_history(student_id, title, body, sent_by, "no_token")
            return True

        if not firebase_initialized:
            logger.info(f"[Mock Mode] Firebase not initialized. Sending to student {student_id} token {token}. Title: '{title}', Body: '{body}'")
            NotificationService._save_to_history(student_id, title, body, sent_by, "sent_mock")
            return True

        try:
            message = messaging.Message(
                notification=messaging.Notification(title=title, body=body),
                data=data or {},
                token=token
            )
            messaging.send(message)
            NotificationService._save_to_history(student_id, title, body, sent_by, "sent")
            return True
        except Exception as e:
            logger.error(f"FCM Send error to student {student_id}: {e}")
            NotificationService._save_to_history(student_id, title, body, sent_by, "failed")
            return False

    @staticmethod
    def send_notification(student_id: str, title: str, body: str) -> bool:
        return NotificationService.send_to_user(student_id, title, body)

    @staticmethod
    def send_to_department(department_id: str, title: str, body: str, data: Optional[Dict[str, str]] = None, sent_by: str = "system") -> int:
        """
        Broadcasts message to all students in a department.
        """
        students_res = supabase_admin.table("students").select("id").eq("department_id", department_id).execute()
        students = students_res.data or []
        
        sent_count = 0
        for s in students:
            if NotificationService.send_to_user(s["id"], title, body, data, sent_by):
                sent_count += 1
        return sent_count

    @staticmethod
    def broadcast_department(department_id: str, title: str, body: str) -> int:
        return NotificationService.send_to_department(department_id, title, body)

    @staticmethod
    def send_bulk(student_ids: List[str], title: str, body: str, data: Optional[Dict[str, str]] = None, sent_by: str = "system") -> int:
        """
        Sends notifications to multiple students in chunks of max 500 tokens.
        """
        # Fetch tokens
        students_res = supabase_admin.table("students").select("id, fcm_token").in_("id", student_ids).execute()
        tokens_map = {s["id"]: s.get("fcm_token") for s in (students_res.data or []) if s.get("fcm_token")}

        if not tokens_map:
            logger.info(f"[Mock Mode] No tokens found for bulk students. Logged bulk broadcast.")
            for s_id in student_ids:
                NotificationService._save_to_history(s_id, title, body, sent_by, "no_token")
            return 0

        sent_count = 0
        tokens = list(tokens_map.values())
        student_ids_with_tokens = list(tokens_map.keys())

        if not firebase_initialized:
            logger.info(f"[Mock Mode] Bulk messaging simulation for {len(tokens)} students.")
            for s_id in student_ids:
                status = "sent_mock" if s_id in tokens_map else "no_token"
                NotificationService._save_to_history(s_id, title, body, sent_by, status)
                if s_id in tokens_map:
                    sent_count += 1
            return sent_count

        # Send in batches of 500
        for i in range(0, len(tokens), 500):
            token_chunk = tokens[i:i+500]
            student_chunk = student_ids_with_tokens[i:i+500]
            try:
                message = messaging.MulticastMessage(
                    notification=messaging.Notification(title=title, body=body),
                    data=data or {},
                    tokens=token_chunk
                )
                response = messaging.send_each_for_multicast(message)
                
                # Check responses to update stats/history
                for idx, resp in enumerate(response.responses):
                    s_id = student_chunk[idx]
                    if resp.success:
                        sent_count += 1
                        NotificationService._save_to_history(s_id, title, body, sent_by, "sent")
                    else:
                        NotificationService._save_to_history(s_id, title, body, sent_by, "failed")
            except Exception as e:
                logger.error(f"FCM Bulk Multicast error: {e}")
                for s_id in student_chunk:
                    NotificationService._save_to_history(s_id, title, body, sent_by, "failed")

        # For students with no tokens:
        for s_id in student_ids:
            if s_id not in tokens_map:
                NotificationService._save_to_history(s_id, title, body, sent_by, "no_token")

        return sent_count
