import uuid
from typing import Optional, Dict
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.models.notification import Notification
from app.models.user import User


class NotificationService:
    @staticmethod
    async def get_user_preferences(db: AsyncSession, user_id: str) -> Dict[str, bool]:
        """
        Retrieves user notification preferences.
        Defaults to True for all important channels if not set.
        """
        result = await db.execute(select(User).where(User.user_id == user_id))
        user = result.scalar_one_or_none()
        
        if not user:
            return {"push": True, "email": True, "in_app": True}
            
        prefs = user.notification_preferences or {}
        
        return {
            "push": prefs.get("push", True),
            "email": prefs.get("email", True),
            "in_app": prefs.get("in_app", True)
        }

    @staticmethod
    async def update_user_preferences(db: AsyncSession, user_id: str, new_prefs: Dict[str, bool]) -> Dict[str, bool]:
        """
        Updates the user's notification preferences.
        """
        result = await db.execute(select(User).where(User.user_id == user_id))
        user = result.scalar_one_or_none()
        
        if not user:
            return new_prefs
            
        current_prefs = user.notification_preferences or {}
        current_prefs.update(new_prefs)
        
        user.notification_preferences = current_prefs
        db.add(user)
        await db.commit()
        await db.refresh(user)
        
        return current_prefs

    @staticmethod
    async def dispatch_notification(
        db: AsyncSession,
        user_id: str,
        title: str,
        message: str,
        notification_type: str,
        related_entity_id: Optional[str] = None,
        related_entity_type: Optional[str] = None
    ) -> Notification:
        """
        Dispatches a notification.
        1. Checks preferences.
        2. Simulates sending Push/Email if opted in.
        3. Logs the notification in the database (acting as the in-app notification).
        """
        prefs = await NotificationService.get_user_preferences(db, user_id)
        
        # 1. Simulate Push Notification
        if prefs.get("push"):
            print(f"[PUSH NOTIFICATION to {user_id}]: {title} - {message}")
            
        # 2. Simulate Email Notification
        if prefs.get("email"):
            print(f"[EMAIL NOTIFICATION to {user_id}]: {title} - {message}")
            
        # 3. Always log in database (in_app & audit log)
        db_notification = Notification(
            notification_id=str(uuid.uuid4()),
            user_id=user_id,
            title=title,
            message=message,
            type=notification_type,
            is_read=False,
            related_entity_id=related_entity_id,
            related_entity_type=related_entity_type
        )
        
        db.add(db_notification)
        await db.commit()
        await db.refresh(db_notification)
        
        return db_notification

notification_service = NotificationService()
