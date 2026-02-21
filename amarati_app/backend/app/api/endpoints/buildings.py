from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel
from typing import Optional, List
import uuid
import secrets

router = APIRouter()

# ---- Schemas ----
class BuildingCreate(BaseModel):
    name: str
    address: Optional[str] = None
    city: Optional[str] = None
    total_units: int = 0

class UnitCreate(BaseModel):
    number: str
    floor: Optional[int] = None

class UnitInviteResponse(BaseModel):
    invite_code: str
    unit_number: str
    building_name: str

class JoinUnitRequest(BaseModel):
    invite_code: str

class BuildingResponse(BaseModel):
    id: str
    name: str
    address: Optional[str] = None
    city: Optional[str] = None
    total_units: int
    invite_code: str
    units: List[dict] = []

class UnitResponse(BaseModel):
    id: str
    number: str
    floor: Optional[int] = None
    is_occupied: bool
    tenant_name: Optional[str] = None

# ---- Mock Data ----
_buildings = {}
_units = {}
_invites = {}

# ---- Endpoints ----
@router.post("/", response_model=dict)
async def create_building(building: BuildingCreate):
    bid = str(uuid.uuid4())
    invite_code = secrets.token_urlsafe(8)
    _buildings[bid] = {
        "id": bid,
        "name": building.name,
        "address": building.address,
        "city": building.city,
        "total_units": building.total_units,
        "invite_code": invite_code,
        "units": []
    }
    return _buildings[bid]

@router.get("/", response_model=List[dict])
async def list_buildings():
    return list(_buildings.values())

@router.get("/{building_id}", response_model=dict)
async def get_building(building_id: str):
    if building_id not in _buildings:
        raise HTTPException(status_code=404, detail="المبنى غير موجود")
    return _buildings[building_id]

@router.post("/{building_id}/units", response_model=dict)
async def add_unit(building_id: str, unit: UnitCreate):
    if building_id not in _buildings:
        raise HTTPException(status_code=404, detail="المبنى غير موجود")
    uid = str(uuid.uuid4())
    unit_data = {
        "id": uid,
        "number": unit.number,
        "floor": unit.floor,
        "building_id": building_id,
        "is_occupied": False,
        "tenant_name": None
    }
    _units[uid] = unit_data
    _buildings[building_id]["units"].append(unit_data)
    return unit_data

@router.post("/{building_id}/units/{unit_id}/invite", response_model=dict)
async def generate_invite_link(building_id: str, unit_id: str):
    if unit_id not in _units:
        raise HTTPException(status_code=404, detail="الوحدة غير موجودة")
    invite_code = secrets.token_urlsafe(10)
    _invites[invite_code] = {
        "invite_code": invite_code,
        "unit_id": unit_id,
        "building_id": building_id,
        "is_used": False,
    }
    return {"invite_code": invite_code, "link": f"amarati://join/{invite_code}"}

@router.post("/join", response_model=dict)
async def join_unit(request: JoinUnitRequest):
    if request.invite_code not in _invites:
        raise HTTPException(status_code=404, detail="رابط الدعوة غير صالح")
    invite = _invites[request.invite_code]
    if invite["is_used"]:
        raise HTTPException(status_code=400, detail="رابط الدعوة مستخدم مسبقاً")
    invite["is_used"] = True
    unit = _units.get(invite["unit_id"])
    if unit:
        unit["is_occupied"] = True
        unit["tenant_name"] = "مستأجر جديد"
    return {"message": "تم الانضمام بنجاح", "unit": unit}
