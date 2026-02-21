from sqlalchemy import Boolean, Column, String, DateTime, Enum, Text
from sqlalchemy.ext.declarative import declarative_base
from datetime import datetime
import uuid
import enum

Base = declarative_base()

class UserRole(str, enum.Enum):
    owner = "owner"
    tenant = "tenant"
    supervisor = "supervisor"
    provider = "provider"
    admin = "admin"

class User(Base):
    __tablename__ = "users"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    phone = Column(String(20), unique=True, index=True, nullable=False)
    email = Column(String(255), unique=True, index=True, nullable=True)
    full_name = Column(String(255), nullable=True)
    hashed_password = Column(String(255), nullable=True)
    role = Column(Enum(UserRole), default=UserRole.tenant)
    is_active = Column(Boolean, default=True)
    is_verified = Column(Boolean, default=False)
    avatar_url = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class OTPCode(Base):
    __tablename__ = "otp_codes"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    phone = Column(String(20), nullable=False, index=True)
    code = Column(String(10), nullable=False)
    purpose = Column(String(50), default="verification")
    is_used = Column(Boolean, default=False)
    expires_at = Column(DateTime, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
