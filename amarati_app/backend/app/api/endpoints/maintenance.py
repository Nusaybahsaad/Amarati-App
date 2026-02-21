from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel
from typing import Optional, List
import uuid
from datetime import datetime

router = APIRouter()

# ---- Schemas ----
class MaintenanceCreate(BaseModel):
    title: str
    description: Optional[str] = None
    request_type: str = "personal"  # personal, community
    urgency: str = "normal"  # low, normal, urgent
    building_id: str
    unit_id: Optional[str] = None
    preferred_date: Optional[str] = None
    preferred_time_slot: Optional[str] = None

class VoteCreate(BaseModel):
    vote: bool = True

class StatusUpdate(BaseModel):
    status: str
    notes: Optional[str] = None

class AssignProvider(BaseModel):
    provider_id: str

# ---- Mock Data ----
_requests: dict = {}
_votes: dict = {}
_providers = [
    {"id": "p1", "company_name": "شركة الأمان للصيانة", "specialization": "سباكة", "rating": 4.8, "total_jobs": 45, "avg_response_time_hours": 2.5, "price_range": "متوسط", "is_verified": True},
    {"id": "p2", "company_name": "مؤسسة النجم للتكييف", "specialization": "تكييف", "rating": 4.5, "total_jobs": 32, "avg_response_time_hours": 3.0, "price_range": "مرتفع", "is_verified": True},
    {"id": "p3", "company_name": "شركة البناء الحديث", "specialization": "كهرباء", "rating": 4.2, "total_jobs": 28, "avg_response_time_hours": 1.5, "price_range": "منخفض", "is_verified": True},
    {"id": "p4", "company_name": "خدمات الريان", "specialization": "نظافة", "rating": 4.0, "total_jobs": 15, "avg_response_time_hours": 4.0, "price_range": "منخفض", "is_verified": False},
]

# ---- Endpoints ----
@router.post("/", response_model=dict)
async def create_request(req: MaintenanceCreate):
    rid = str(uuid.uuid4())
    _requests[rid] = {
        "id": rid,
        "title": req.title,
        "description": req.description,
        "request_type": req.request_type,
        "status": "submitted",
        "urgency": req.urgency,
        "building_id": req.building_id,
        "unit_id": req.unit_id,
        "preferred_date": req.preferred_date,
        "preferred_time_slot": req.preferred_time_slot,
        "assigned_provider": None,
        "votes_for": 0,
        "votes_against": 0,
        "status_history": [{"status": "submitted", "time": datetime.utcnow().isoformat(), "notes": "تم تقديم الطلب"}],
        "created_at": datetime.utcnow().isoformat(),
    }
    return _requests[rid]

@router.get("/", response_model=List[dict])
async def list_requests():
    return list(_requests.values())

@router.get("/{request_id}", response_model=dict)
async def get_request(request_id: str):
    if request_id not in _requests:
        raise HTTPException(status_code=404, detail="الطلب غير موجود")
    return _requests[request_id]

@router.put("/{request_id}/status", response_model=dict)
async def update_status(request_id: str, update: StatusUpdate):
    if request_id not in _requests:
        raise HTTPException(status_code=404, detail="الطلب غير موجود")
    req = _requests[request_id]
    old_status = req["status"]
    req["status"] = update.status
    req["status_history"].append({
        "status": update.status,
        "time": datetime.utcnow().isoformat(),
        "notes": update.notes or f"تم تغيير الحالة من {old_status} إلى {update.status}"
    })
    return req

@router.post("/{request_id}/assign", response_model=dict)
async def assign_provider(request_id: str, assign: AssignProvider):
    if request_id not in _requests:
        raise HTTPException(status_code=404, detail="الطلب غير موجود")
    req = _requests[request_id]
    provider = next((p for p in _providers if p["id"] == assign.provider_id), None)
    if not provider:
        raise HTTPException(status_code=404, detail="مزود الخدمة غير موجود")
    req["assigned_provider"] = provider
    req["status"] = "assigned"
    req["status_history"].append({
        "status": "assigned",
        "time": datetime.utcnow().isoformat(),
        "notes": f"تم إسناد المهمة إلى {provider['company_name']}"
    })
    return req

@router.post("/{request_id}/vote", response_model=dict)
async def vote_on_request(request_id: str, vote: VoteCreate):
    if request_id not in _requests:
        raise HTTPException(status_code=404, detail="الطلب غير موجود")
    req = _requests[request_id]
    if vote.vote:
        req["votes_for"] += 1
    else:
        req["votes_against"] += 1
    return {"votes_for": req["votes_for"], "votes_against": req["votes_against"]}

# ---- Provider Marketplace ----
@router.get("/providers/marketplace", response_model=List[dict])
async def list_providers(sort_by: str = "rating"):
    sorted_providers = sorted(_providers, key=lambda p: p.get(sort_by, 0), reverse=True)
    return sorted_providers

@router.get("/providers/{provider_id}", response_model=dict)
async def get_provider(provider_id: str):
    provider = next((p for p in _providers if p["id"] == provider_id), None)
    if not provider:
        raise HTTPException(status_code=404, detail="مزود الخدمة غير موجود")
    return provider
