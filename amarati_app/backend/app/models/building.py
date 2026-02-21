from sqlalchemy import Column, String, DateTime, Boolean, ForeignKey, Integer, Text
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid
from app.models.user import Base


class Building(Base):
    __tablename__ = "buildings"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    name = Column(String(255), nullable=False)
    address = Column(Text, nullable=True)
    city = Column(String(100), nullable=True)
    total_units = Column(Integer, default=0)
    owner_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    invite_code = Column(String(20), unique=True, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    units = relationship("Unit", back_populates="building")


class Unit(Base):
    __tablename__ = "units"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    number = Column(String(50), nullable=False)
    floor = Column(Integer, nullable=True)
    building_id = Column(String(36), ForeignKey("buildings.id"), nullable=False)
    tenant_id = Column(String(36), ForeignKey("users.id"), nullable=True)
    is_occupied = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    building = relationship("Building", back_populates="units")


class UnitInvite(Base):
    __tablename__ = "unit_invites"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    unit_id = Column(String(36), ForeignKey("units.id"), nullable=False)
    invite_code = Column(String(20), unique=True, nullable=False)
    created_by = Column(String(36), ForeignKey("users.id"), nullable=False)
    used_by = Column(String(36), ForeignKey("users.id"), nullable=True)
    is_used = Column(Boolean, default=False)
    expires_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
