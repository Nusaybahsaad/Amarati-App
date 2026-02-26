from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from pydantic import BaseModel
from typing import Optional, List
import uuid
import secrets

from app.core.database import get_db
from app.models.building import Building
from app.models.user import User
from app.services.auth_service import get_current_user

router = APIRouter()


# ---- Schemas ----
class BuildingCreate(BaseModel):
    name: str
    address: Optional[str] = None
    city: Optional[str] = None


class JoinBuildingRequest(BaseModel):
    invite_code: str


class BuildingResponse(BaseModel):
    id: str
    name: str
    address: Optional[str] = None
    city: Optional[str] = None
    invite_code: str
    member_count: int = 0

    class Config:
        from_attributes = True


class MemberResponse(BaseModel):
    user_id: str
    name: str
    role: str


# ---- Create a building group ----
@router.post("/", response_model=BuildingResponse, status_code=status.HTTP_201_CREATED)
async def create_building(
    data: BuildingCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    # Check if user already has a building
    if current_user.building_id:
        raise HTTPException(
            status_code=400,
            detail="أنت منضم لمجموعة بالفعل"
        )

    invite_code = secrets.token_urlsafe(6).upper()[:8]

    building = Building(
        id=str(uuid.uuid4()),
        name=data.name,
        address=data.address,
        city=data.city,
        owner_id=current_user.user_id,
        invite_code=invite_code,
    )
    db.add(building)

    # Auto-join the creator to the building
    current_user.building_id = building.id
    db.add(current_user)

    await db.commit()
    await db.refresh(building)

    return BuildingResponse(
        id=building.id,
        name=building.name,
        address=building.address,
        city=building.city,
        invite_code=building.invite_code,
        member_count=1,
    )


# ---- Join a building via invite code ----
@router.post("/join", response_model=dict)
async def join_building(
    data: JoinBuildingRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    if current_user.building_id:
        raise HTTPException(status_code=400, detail="أنت منضم لمجموعة بالفعل")

    result = await db.execute(
        select(Building).where(Building.invite_code == data.invite_code)
    )
    building = result.scalar_one_or_none()
    if not building:
        raise HTTPException(status_code=404, detail="كود الدعوة غير صالح")

    current_user.building_id = building.id
    db.add(current_user)
    await db.commit()

    return {
        "message": "تم الانضمام للمجموعة بنجاح ✅",
        "building_name": building.name,
        "building_id": building.id,
    }


# ---- Get current user's building ----
@router.get("/my", response_model=Optional[BuildingResponse])
async def get_my_building(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    if not current_user.building_id:
        return None

    result = await db.execute(
        select(Building).where(Building.id == current_user.building_id)
    )
    building = result.scalar_one_or_none()
    if not building:
        return None

    # Count members
    members_result = await db.execute(
        select(User).where(User.building_id == building.id)
    )
    member_count = len(members_result.scalars().all())

    return BuildingResponse(
        id=building.id,
        name=building.name,
        address=building.address,
        city=building.city,
        invite_code=building.invite_code,
        member_count=member_count,
    )


# ---- List building members ----
@router.get("/my/members", response_model=List[MemberResponse])
async def get_building_members(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    if not current_user.building_id:
        raise HTTPException(status_code=400, detail="أنت غير منضم لأي مجموعة")

    result = await db.execute(
        select(User).where(User.building_id == current_user.building_id)
    )
    members = result.scalars().all()

    return [
        MemberResponse(
            user_id=m.user_id,
            name=m.name,
            role=m.role.value if hasattr(m.role, 'value') else str(m.role),
        )
        for m in members
    ]
