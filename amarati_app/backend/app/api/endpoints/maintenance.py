from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import Optional, List
import uuid

from app.core.database import get_db
from app.models.maintenance_request import MaintenanceRequest
from app.models.user import User
from app.schemas.maintenance_schema import (
    MaintenanceRequestCreate,
    MaintenanceRequestResponse,
    MaintenanceStatusUpdate,
)
from app.services.auth_service import get_current_user

router = APIRouter()


# ---- Create a new maintenance request (tenant) ----
@router.post("/", response_model=MaintenanceRequestResponse, status_code=status.HTTP_201_CREATED)
async def create_request(
    data: MaintenanceRequestCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    req = MaintenanceRequest(
        request_id=str(uuid.uuid4()),
        description=data.description,
        category=data.category,
        status="pending",
        unit_number=data.unit_number,
        contact_name=data.contact_name or current_user.name,
        contact_phone=data.contact_phone or current_user.phone,
        user_id=current_user.user_id,
    )
    db.add(req)
    await db.commit()
    await db.refresh(req)
    return req


# ---- List all requests (for provider dashboard) ----
@router.get("/", response_model=List[MaintenanceRequestResponse])
async def list_requests(
    status_filter: Optional[str] = Query(None, alias="status"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    query = select(MaintenanceRequest).order_by(MaintenanceRequest.created_at.desc())
    if status_filter:
        query = query.where(MaintenanceRequest.status == status_filter)
    result = await db.execute(query)
    return result.scalars().all()


# ---- List current user's requests (for tenant) ----
@router.get("/my", response_model=List[MaintenanceRequestResponse])
async def list_my_requests(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(MaintenanceRequest)
        .where(MaintenanceRequest.user_id == current_user.user_id)
        .order_by(MaintenanceRequest.created_at.desc())
    )
    return result.scalars().all()


# ---- Get single request ----
@router.get("/{request_id}", response_model=MaintenanceRequestResponse)
async def get_request(
    request_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(MaintenanceRequest).where(MaintenanceRequest.request_id == request_id)
    )
    req = result.scalar_one_or_none()
    if not req:
        raise HTTPException(status_code=404, detail="الطلب غير موجود")
    return req


# ---- Update request status (provider accepts/rejects/completes) ----
@router.put("/{request_id}/status", response_model=MaintenanceRequestResponse)
async def update_status(
    request_id: str,
    update: MaintenanceStatusUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(MaintenanceRequest).where(MaintenanceRequest.request_id == request_id)
    )
    req = result.scalar_one_or_none()
    if not req:
        raise HTTPException(status_code=404, detail="الطلب غير موجود")

    valid_statuses = ["pending", "accepted", "rejected", "in_progress", "completed"]
    if update.status not in valid_statuses:
        raise HTTPException(
            status_code=400,
            detail=f"الحالة غير صالحة. الحالات المسموحة: {', '.join(valid_statuses)}"
        )

    req.status = update.status
    db.add(req)
    await db.commit()
    await db.refresh(req)
    return req
