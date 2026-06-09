"""
Tests for notification services.
"""
import pytest
from unittest.mock import patch, MagicMock
from app.services.notification_service import NotificationService

def test_notification_register_device():
    with patch("app.services.notification_service.supabase_admin") as mock_supabase:
        mock_supabase.table.return_value.update.return_value.eq.return_value.execute.return_value.data = [{"id": "student-1"}]
        
        ok = NotificationService.register_device("student-1", "token-xyz", "android")
        assert ok is True
        mock_supabase.table.assert_any_call("students")

def test_notification_send_mock_mode():
    # Test sending when Firebase is mock/inactive
    with patch("app.services.notification_service.supabase_admin") as mock_supabase:
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = [{"fcm_token": "token-xyz"}]
        mock_supabase.table.return_value.insert.return_value.execute.return_value.data = [{"id": "history-1"}]
        
        ok = NotificationService.send_to_user("student-1", "تنبيه أكاديمي", "لديك إنذار أكاديمي")
        assert ok is True
        
def test_notification_send_bulk_mock():
    with patch("app.services.notification_service.supabase_admin") as mock_supabase:
        mock_supabase.table.return_value.select.return_value.in_.return_value.execute.return_value.data = [
            {"id": "student-1", "fcm_token": "token-1"},
            {"id": "student-2", "fcm_token": "token-2"}
        ]
        mock_supabase.table.return_value.insert.return_value.execute.return_value.data = [{"id": "history-1"}]
        
        count = NotificationService.send_bulk(["student-1", "student-2"], "تنبيه", "محتوى")
        assert count == 2
