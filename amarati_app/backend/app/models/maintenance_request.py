from sqlalchemy import Column, String, Text, DateTime, ForeignKey
from datetime import datetime
import uuid
from app.core.database import Base


class MaintenanceRequest(Base):
    __tablename__ = "maintenance_requests"

    request_id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    description = Column(Text, nullable=False)
    category = Column(String(100), nullable=False)
    status = Column(String(50), nullable=False, default="pending")
    unit_number = Column(String(50), nullable=True, default="")
    contact_name = Column(String(255), nullable=True, default="")
    contact_phone = Column(String(50), nullable=True, default="")
    created_at = Column(DateTime, default=datetime.utcnow)
    unit_id = Column(String(36), ForeignKey("units.unit_id"), nullable=True)
    user_id = Column(String(36), ForeignKey("users.user_id"), nullable=False)
