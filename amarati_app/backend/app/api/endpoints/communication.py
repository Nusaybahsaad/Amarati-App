from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from pydantic import BaseModel
from typing import Optional, List
import uuid
from datetime import datetime

from app.core.database import get_db
from app.models.system import ChatMessage
from app.models.user import User
from app.services.auth_service import get_current_user

router = APIRouter()


# ---- Schemas ----
class ChatSend(BaseModel):
    message: str
    message_type: str = "text"


class ChatMessageResponse(BaseModel):
    id: str
    sender_id: str
    sender_name: str
    message: str
    message_type: str
    created_at: str


# ---- Chat Endpoints (Real DB) ----
@router.post("/chat", response_model=ChatMessageResponse)
async def send_message(
    data: ChatSend,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    if not current_user.building_id:
        raise HTTPException(status_code=400, detail="أنت غير منضم لأي مجموعة")

    msg = ChatMessage(
        id=str(uuid.uuid4()),
        building_id=current_user.building_id,
        sender_id=current_user.user_id,
        message=data.message,
        message_type=data.message_type,
    )
    db.add(msg)
    await db.commit()
    await db.refresh(msg)

    return ChatMessageResponse(
        id=msg.id,
        sender_id=msg.sender_id,
        sender_name=current_user.name,
        message=msg.message,
        message_type=msg.message_type,
        created_at=msg.created_at.isoformat() if msg.created_at else "",
    )


@router.get("/chat", response_model=List[ChatMessageResponse])
async def get_chat_history(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    if not current_user.building_id:
        return []

    result = await db.execute(
        select(ChatMessage)
        .where(ChatMessage.building_id == current_user.building_id)
        .order_by(ChatMessage.created_at.asc())
    )
    messages = result.scalars().all()

    # Get sender names
    sender_ids = list(set(m.sender_id for m in messages))
    names = {}
    if sender_ids:
        users_result = await db.execute(
            select(User).where(User.user_id.in_(sender_ids))
        )
        for u in users_result.scalars().all():
            names[u.user_id] = u.name

    return [
        ChatMessageResponse(
            id=m.id,
            sender_id=m.sender_id,
            sender_name=names.get(m.sender_id, ""),
            message=m.message,
            message_type=m.message_type,
            created_at=m.created_at.isoformat() if m.created_at else "",
        )
        for m in messages
    ]
