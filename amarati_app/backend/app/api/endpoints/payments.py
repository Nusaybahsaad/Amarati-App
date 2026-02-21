from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional, List
import uuid
from datetime import datetime

router = APIRouter()

# ---- Schemas ----
class PaymentCreate(BaseModel):
    amount: float
    payment_type: str = "rent"  # rent, maintenance, shared_expense, other
    payer_id: str
    receiver_id: Optional[str] = None
    unit_id: Optional[str] = None
    building_id: Optional[str] = None
    maintenance_request_id: Optional[str] = None
    description: Optional[str] = None
    due_date: Optional[str] = None

class ReceiptUpload(BaseModel):
    receipt_url: str

# ---- Mock Data ----
_payments: dict = {}

# ---- Endpoints ----
@router.post("/", response_model=dict)
async def create_payment(payment: PaymentCreate):
    pid = str(uuid.uuid4())
    _payments[pid] = {
        "id": pid,
        "amount": payment.amount,
        "payment_type": payment.payment_type,
        "status": "pending",
        "payer_id": payment.payer_id,
        "receiver_id": payment.receiver_id,
        "unit_id": payment.unit_id,
        "building_id": payment.building_id,
        "maintenance_request_id": payment.maintenance_request_id,
        "description": payment.description,
        "receipt_url": None,
        "due_date": payment.due_date,
        "paid_at": None,
        "created_at": datetime.utcnow().isoformat(),
    }
    return _payments[pid]

@router.get("/", response_model=List[dict])
async def list_payments(payer_id: Optional[str] = None, status: Optional[str] = None):
    payments = list(_payments.values())
    if payer_id:
        payments = [p for p in payments if p["payer_id"] == payer_id]
    if status:
        payments = [p for p in payments if p["status"] == status]
    return payments

@router.get("/{payment_id}", response_model=dict)
async def get_payment(payment_id: str):
    if payment_id not in _payments:
        raise HTTPException(status_code=404, detail="الدفعة غير موجودة")
    return _payments[payment_id]

@router.put("/{payment_id}/pay", response_model=dict)
async def mark_as_paid(payment_id: str):
    if payment_id not in _payments:
        raise HTTPException(status_code=404, detail="الدفعة غير موجودة")
    _payments[payment_id]["status"] = "completed"
    _payments[payment_id]["paid_at"] = datetime.utcnow().isoformat()
    return _payments[payment_id]

@router.post("/{payment_id}/receipt", response_model=dict)
async def upload_receipt(payment_id: str, receipt: ReceiptUpload):
    if payment_id not in _payments:
        raise HTTPException(status_code=404, detail="الدفعة غير موجودة")
    _payments[payment_id]["receipt_url"] = receipt.receipt_url
    return _payments[payment_id]

@router.get("/summary/provider/{provider_id}", response_model=dict)
async def provider_payment_summary(provider_id: str):
    all_payments = [p for p in _payments.values() if p["receiver_id"] == provider_id]
    return {
        "total": sum(p["amount"] for p in all_payments),
        "pending": sum(p["amount"] for p in all_payments if p["status"] == "pending"),
        "completed": sum(p["amount"] for p in all_payments if p["status"] == "completed"),
        "count": len(all_payments),
    }
