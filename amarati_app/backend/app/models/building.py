from sqlalchemy import Column, String, DateTime, Boolean, ForeignKey, Integer, Text
from datetime import datetime
import uuid
from app.core.database import Base

# NOTE: Unit is defined in unit.py (new schema)


class Building(Base):
    __tablename__ = "buildings"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    name = Column(String(255), nullable=False)
    address = Column(Text, nullable=True)
    city = Column(String(100), nullable=True)
    total_units = Column(Integer, default=0)
    owner_id = Column(String(36), ForeignKey("users.user_id"), nullable=False)
    invite_code = Column(String(20), unique=True, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)


class UnitInvite(Base):
    __tablename__ = "unit_invites"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    unit_id = Column(String(36), ForeignKey("units.unit_id"), nullable=False)
    invite_code = Column(String(20), unique=True, nullable=False)
    created_by = Column(String(36), ForeignKey("users.user_id"), nullable=False)
    used_by = Column(String(36), ForeignKey("users.user_id"), nullable=True)
    is_used = Column(Boolean, default=False)
    expires_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
