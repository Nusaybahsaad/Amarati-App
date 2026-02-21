from sqlalchemy import Column, String, DateTime, Boolean, ForeignKey, Integer, Text, Float, Enum
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid
import enum
from app.models.user import Base


class RequestType(str, enum.Enum):
    personal = "personal"
    community = "community"


class RequestStatus(str, enum.Enum):
    submitted = "submitted"
    under_review = "under_review"
    voting = "voting"
    approved = "approved"
    assigned = "assigned"
    in_progress = "in_progress"
    completed = "completed"
    cancelled = "cancelled"


class UrgencyLevel(str, enum.Enum):
    low = "low"
    normal = "normal"
    urgent = "urgent"


class MaintenanceRequest(Base):
    __tablename__ = "maintenance_requests"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    request_type = Column(Enum(RequestType), default=RequestType.personal)
    status = Column(Enum(RequestStatus), default=RequestStatus.submitted)
    urgency = Column(Enum(UrgencyLevel), default=UrgencyLevel.normal)
    unit_id = Column(String(36), ForeignKey("units.id"), nullable=True)
    building_id = Column(String(36), ForeignKey("buildings.id"), nullable=False)
    submitted_by = Column(String(36), ForeignKey("users.id"), nullable=False)
    assigned_provider_id = Column(String(36), ForeignKey("users.id"), nullable=True)
    preferred_date = Column(DateTime, nullable=True)
    preferred_time_slot = Column(String(50), nullable=True)
    media_urls = Column(Text, nullable=True)  # JSON array of image URLs
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    votes = relationship("MaintenanceVote", back_populates="request")
    status_logs = relationship("StatusLog", back_populates="request")
    visits = relationship("Visit", back_populates="request")


class MaintenanceVote(Base):
    __tablename__ = "maintenance_votes"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    request_id = Column(String(36), ForeignKey("maintenance_requests.id"), nullable=False)
    user_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    vote = Column(Boolean, default=True)  # True=approve, False=reject
    created_at = Column(DateTime, default=datetime.utcnow)

    request = relationship("MaintenanceRequest", back_populates="votes")


class StatusLog(Base):
    __tablename__ = "status_logs"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    request_id = Column(String(36), ForeignKey("maintenance_requests.id"), nullable=False)
    old_status = Column(String(50), nullable=True)
    new_status = Column(String(50), nullable=False)
    changed_by = Column(String(36), ForeignKey("users.id"), nullable=False)
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    request = relationship("MaintenanceRequest", back_populates="status_logs")


class ProviderProfile(Base):
    __tablename__ = "provider_profiles"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), ForeignKey("users.id"), unique=True, nullable=False)
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
    request_id = Column(String(36), ForeignKey("maintenance_requests.id"), nullable=False)
    provider_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    technician_name = Column(String(255), nullable=True)
    status = Column(String(50), default="scheduled")  # scheduled, on_the_way, arrived, working, completed
    proposed_time = Column(DateTime, nullable=True)
    confirmed_by_resident = Column(Boolean, default=False)
    start_time = Column(DateTime, nullable=True)
    end_time = Column(DateTime, nullable=True)
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    request = relationship("MaintenanceRequest", back_populates="visits")
