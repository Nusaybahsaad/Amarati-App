from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from pydantic import BaseModel
from typing import List, Optional, Dict
from datetime import datetime

from app.core.database import get_db
from app.models.notification import Notification
from app.models.user import User
from app.services.auth_service import get_current_user
from app.services.notification_service import notification_service

router = APIRouter()

# ---- Schemas ----
class NotificationResponse(BaseModel):
    notification_id: str
    title: str
    message: str
    type: str
    is_read: bool
    date: str
    related_entity_id: Optional[str] = None
    related_entity_type: Optional[str] = None

class NotificationPreferencesUpdate(BaseModel):
    push: Optional[bool] = None
    email: Optional[bool] = None
    in_app: Optional[bool] = None

# ---- Endpoints ----

@router.get("/", response_model=List[NotificationResponse])
async def get_my_notifications(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Fetch all notifications for the current user."""
    result = await db.execute(
        select(Notification)
        .where(Notification.user_id == current_user.user_id)
        .order_by(Notification.date.desc())
    )
    notifications = result.scalars().all()
    
    return [
        NotificationResponse(
            notification_id=n.notification_id,
            title=n.title,
            message=n.message,
            type=n.type,
            is_read=n.is_read,
            date=n.date.isoformat() if n.date else "",
            related_entity_id=n.related_entity_id,
            related_entity_type=n.related_entity_type,
        )
        for n in notifications
    ]

@router.put("/{notification_id}/read", response_model=NotificationResponse)
async def mark_notification_read(
    notification_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Mark a specific notification as read."""
    result = await db.execute(
        select(Notification)
        .where(
            (Notification.notification_id == notification_id) &
            (Notification.user_id == current_user.user_id)
        )
    )
    notification = result.scalar_one_or_none()
    
    if not notification:
        raise HTTPException(status_code=404, detail="الإشعار غير موجود")
        
    notification.is_read = True
    db.add(notification)
    await db.commit()
    await db.refresh(notification)
    
    return NotificationResponse(
        notification_id=notification.notification_id,
        title=notification.title,
        message=notification.message,
        type=notification.type,
        is_read=notification.is_read,
        date=notification.date.isoformat() if notification.date else "",
        related_entity_id=notification.related_entity_id,
        related_entity_type=notification.related_entity_type,
    )

@router.get("/preferences", response_model=Dict[str, bool])
async def get_my_preferences(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Get the current user's notification preferences."""
    prefs = await notification_service.get_user_preferences(db, current_user.user_id)
    return prefs

@router.put("/preferences", response_model=Dict[str, bool])
async def update_my_preferences(
    data: NotificationPreferencesUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Update the current user's notification preferences."""
    update_dict = {k: v for k, v in data.model_dump().items() if v is not None}
    
    prefs = await notification_service.update_user_preferences(
        db, 
        current_user.user_id, 
        update_dict
    )
    return prefs
