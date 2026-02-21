from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional, List
import uuid
from datetime import datetime

router = APIRouter()

# ---- Schemas ----
class DocumentCreate(BaseModel):
    title: str
    category: str = "other"  # contract, invoice, warranty, id_document, receipt, other
    file_url: str
    unit_id: Optional[str] = None
    building_id: Optional[str] = None
    expires_at: Optional[str] = None
    visibility_role: str = "all"  # all, owner, tenant, supervisor

class ChatMessageCreate(BaseModel):
    building_id: str
    sender_id: str
    message: str
    message_type: str = "text"

# ---- Mock Data ----
_documents: dict = {}
_chat_messages: List[dict] = []

# ---- Document Endpoints ----
@router.post("/", response_model=dict)
async def upload_document(doc: DocumentCreate):
    did = str(uuid.uuid4())
    _documents[did] = {
        "id": did,
        "title": doc.title,
        "category": doc.category,
        "file_url": doc.file_url,
        "unit_id": doc.unit_id,
        "building_id": doc.building_id,
        "expires_at": doc.expires_at,
        "is_expired": False,
        "visibility_role": doc.visibility_role,
        "version": 1,
        "created_at": datetime.utcnow().isoformat(),
    }
    return _documents[did]

@router.get("/", response_model=List[dict])
async def list_documents(building_id: Optional[str] = None, category: Optional[str] = None):
    docs = list(_documents.values())
    if building_id:
        docs = [d for d in docs if d["building_id"] == building_id]
    if category:
        docs = [d for d in docs if d["category"] == category]
    return docs

@router.get("/{document_id}", response_model=dict)
async def get_document(document_id: str):
    if document_id not in _documents:
        raise HTTPException(status_code=404, detail="المستند غير موجود")
    return _documents[document_id]

@router.put("/{document_id}/new-version", response_model=dict)
async def upload_new_version(document_id: str, doc: DocumentCreate):
    if document_id not in _documents:
        raise HTTPException(status_code=404, detail="المستند غير موجود")
    old_version = _documents[document_id]["version"]
    new_id = str(uuid.uuid4())
    _documents[new_id] = {
        "id": new_id,
        "title": doc.title,
        "category": doc.category,
        "file_url": doc.file_url,
        "unit_id": doc.unit_id,
        "building_id": doc.building_id,
        "expires_at": doc.expires_at,
        "is_expired": False,
        "visibility_role": doc.visibility_role,
        "version": old_version + 1,
        "parent_document_id": document_id,
        "created_at": datetime.utcnow().isoformat(),
    }
    return _documents[new_id]

@router.get("/expiring/soon", response_model=List[dict])
async def get_expiring_documents():
    return [d for d in _documents.values() if d.get("expires_at") and not d["is_expired"]]
