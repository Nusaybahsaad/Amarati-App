from pydantic import BaseModel, ConfigDict
from typing import Optional
from datetime import datetime


class MaintenanceRequestCreate(BaseModel):
    description: str
    category: str  # كهرباء، سباكة، تكييف، نظافة، etc.
    unit_number: str = ""
    contact_name: str = ""
    contact_phone: str = ""


class MaintenanceRequestResponse(BaseModel):
    request_id: str
    description: str
    category: str
    status: str
    unit_number: str | None = None
    contact_name: str | None = None
    contact_phone: str | None = None
    user_id: str
    created_at: datetime | None = None

    model_config = ConfigDict(from_attributes=True)


class MaintenanceStatusUpdate(BaseModel):
    status: str  # accepted, rejected, in_progress, completed
    notes: Optional[str] = None
