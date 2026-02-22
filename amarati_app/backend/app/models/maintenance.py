from sqlalchemy import Column, String, DateTime, Boolean, ForeignKey, Integer, Text, Float
from datetime import datetime
import uuid
from app.core.database import Base

# NOTE: MaintenanceRequest is defined in maintenance_request.py (new schema)
# The following are supplementary tables for the maintenance module.


class MaintenanceVote(Base):
    __tablename__ = "maintenance_votes"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    request_id = Column(String(36), ForeignKey("maintenance_requests.request_id"), nullable=False)
    user_id = Column(String(36), ForeignKey("users.user_id"), nullable=False)
    vote = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)


class StatusLog(Base):
    __tablename__ = "status_logs"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    request_id = Column(String(36), ForeignKey("maintenance_requests.request_id"), nullable=False)
    old_status = Column(String(50), nullable=True)
    new_status = Column(String(50), nullable=False)
    changed_by = Column(String(36), ForeignKey("users.user_id"), nullable=False)
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)


class ProviderProfile(Base):
    __tablename__ = "provider_profiles"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), ForeignKey("users.user_id"), unique=True, nullable=False)
    company_name = Column(String(255), nullable=True)
    specialization = Column(String(255), nullable=True)
    rating = Column(Float, default=0.0)
    total_jobs = Column(Integer, default=0)
    avg_response_time_hours = Column(Float, nullable=True)
    price_range = Column(String(50), nullable=True)
    is_verified = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)


class Visit(Base):
    __tablename__ = "visits"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    request_id = Column(String(36), ForeignKey("maintenance_requests.request_id"), nullable=False)
    provider_id = Column(String(36), ForeignKey("users.user_id"), nullable=False)
    technician_name = Column(String(255), nullable=True)
    status = Column(String(50), default="scheduled")
    proposed_time = Column(DateTime, nullable=True)
    confirmed_by_resident = Column(Boolean, default=False)
    start_time = Column(DateTime, nullable=True)
    end_time = Column(DateTime, nullable=True)
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
