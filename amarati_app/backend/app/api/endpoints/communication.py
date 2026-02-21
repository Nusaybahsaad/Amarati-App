from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional, List
import uuid
from datetime import datetime

router = APIRouter()

# ---- Schemas ----
class ChatSend(BaseModel):
    sender_id: str
    message: str
    message_type: str = "text"

class NotificationCreate(BaseModel):
    user_id: str
    title: str
    body: Optional[str] = None
    notification_type: str = "general"

class NotificationPreferences(BaseModel):
    maintenance_alerts: bool = True
    payment_alerts: bool = True
    chat_alerts: bool = True
    document_alerts: bool = True

class VisitCreate(BaseModel):
    request_id: str
    provider_id: str
    technician_name: Optional[str] = None
    proposed_time: Optional[str] = None

class VisitStatusUpdate(BaseModel):
    status: str  # on_the_way, arrived, working, completed
    notes: Optional[str] = None

class ChatbotQuery(BaseModel):
    user_id: str
    query: str
    language: str = "ar"

# ---- Mock Data ----
_chats: dict = {}  # building_id -> list of messages
_notifications: dict = {}  # user_id -> list of notifs
_preferences: dict = {}
_visits: dict = {}
_chatbot_history: List[dict] = []

# ---- Chat Endpoints ----
@router.post("/chat/{building_id}", response_model=dict)
async def send_message(building_id: str, msg: ChatSend):
    mid = str(uuid.uuid4())
    message = {
        "id": mid,
        "building_id": building_id,
        "sender_id": msg.sender_id,
        "message": msg.message,
        "message_type": msg.message_type,
        "created_at": datetime.utcnow().isoformat(),
    }
    if building_id not in _chats:
        _chats[building_id] = []
    _chats[building_id].append(message)
    return message

@router.get("/chat/{building_id}", response_model=List[dict])
async def get_chat_history(building_id: str):
    return _chats.get(building_id, [])

# ---- Notification Endpoints ----
@router.post("/notifications", response_model=dict)
async def create_notification(notif: NotificationCreate):
    nid = str(uuid.uuid4())
    notification = {
        "id": nid,
        "user_id": notif.user_id,
        "title": notif.title,
        "body": notif.body,
        "notification_type": notif.notification_type,
        "is_read": False,
        "created_at": datetime.utcnow().isoformat(),
    }
    if notif.user_id not in _notifications:
        _notifications[notif.user_id] = []
    _notifications[notif.user_id].append(notification)
    return notification

@router.get("/notifications/{user_id}", response_model=List[dict])
async def get_notifications(user_id: str, unread_only: bool = False):
    notifs = _notifications.get(user_id, [])
    if unread_only:
        notifs = [n for n in notifs if not n["is_read"]]
    return notifs

@router.put("/notifications/{notification_id}/read", response_model=dict)
async def mark_as_read(notification_id: str):
    for user_notifs in _notifications.values():
        for n in user_notifs:
            if n["id"] == notification_id:
                n["is_read"] = True
                return n
    raise HTTPException(status_code=404, detail="الإشعار غير موجود")

@router.put("/notifications/preferences/{user_id}", response_model=dict)
async def update_preferences(user_id: str, prefs: NotificationPreferences):
    _preferences[user_id] = prefs.dict()
    return {"user_id": user_id, **_preferences[user_id]}

# ---- Visit Management Endpoints ----
@router.post("/visits", response_model=dict)
async def create_visit(visit: VisitCreate):
    vid = str(uuid.uuid4())
    _visits[vid] = {
        "id": vid,
        "request_id": visit.request_id,
        "provider_id": visit.provider_id,
        "technician_name": visit.technician_name,
        "status": "scheduled",
        "proposed_time": visit.proposed_time,
        "confirmed_by_resident": False,
        "start_time": None,
        "end_time": None,
        "notes": None,
        "created_at": datetime.utcnow().isoformat(),
    }
    return _visits[vid]

@router.put("/visits/{visit_id}/status", response_model=dict)
async def update_visit_status(visit_id: str, update: VisitStatusUpdate):
    if visit_id not in _visits:
        raise HTTPException(status_code=404, detail="الزيارة غير موجودة")
    visit = _visits[visit_id]
    visit["status"] = update.status
    visit["notes"] = update.notes
    if update.status == "working":
        visit["start_time"] = datetime.utcnow().isoformat()
    elif update.status == "completed":
        visit["end_time"] = datetime.utcnow().isoformat()
    return visit

@router.put("/visits/{visit_id}/confirm", response_model=dict)
async def confirm_visit(visit_id: str):
    if visit_id not in _visits:
        raise HTTPException(status_code=404, detail="الزيارة غير موجودة")
    _visits[visit_id]["confirmed_by_resident"] = True
    return _visits[visit_id]

@router.get("/visits/request/{request_id}", response_model=List[dict])
async def get_visits_for_request(request_id: str):
    return [v for v in _visits.values() if v["request_id"] == request_id]

# ---- Chatbot Endpoints ----
@router.post("/chatbot", response_model=dict)
async def chatbot_query(query: ChatbotQuery):
    # Rule-based intent engine
    q = query.query.lower()
    if any(w in q for w in ["صيانة", "إصلاح", "maintenance", "repair"]):
        response = "يمكنك تقديم طلب صيانة من القائمة الرئيسية. هل تريد أن أساعدك في إنشاء طلب جديد؟"
        module = "maintenance"
    elif any(w in q for w in ["دفع", "فاتورة", "payment", "bill", "إيجار"]):
        response = "يمكنك الاطلاع على الفواتير والمدفوعات من قسم المدفوعات. هل تريد عرض الفواتير المستحقة؟"
        module = "payment"
    elif any(w in q for w in ["مستند", "عقد", "وثيقة", "document", "contract"]):
        response = "يمكنك رفع وإدارة المستندات من قسم الجواز الرقمي. هل تريد رفع مستند جديد؟"
        module = "document"
    elif any(w in q for w in ["مرحبا", "أهلا", "hello", "hi"]):
        response = "أهلاً بك في عمارتي! كيف يمكنني مساعدتك اليوم؟"
        module = None
    else:
        response = "عذراً، لم أفهم طلبك. يمكنني مساعدتك في الصيانة، المدفوعات، أو المستندات. كيف يمكنني المساعدة؟"
        module = None

    interaction = {
        "id": str(uuid.uuid4()),
        "user_id": query.user_id,
        "query": query.query,
        "response": response,
        "language": query.language,
        "module_accessed": module,
        "requires_confirmation": module is not None,
        "created_at": datetime.utcnow().isoformat(),
    }
    _chatbot_history.append(interaction)
    return interaction
