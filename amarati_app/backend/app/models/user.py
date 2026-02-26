from sqlalchemy import Column, String, Enum, ForeignKey, JSON
from app.core.database import Base


class UserRole(str, enum.Enum):
    owner = "owner"
    tenant = "tenant"
    supervisor = "supervisor"
    provider = "provider"
    admin = "admin"


class User(Base):
    __tablename__ = "users"

    user_id = Column(String(36), primary_key=True)
    name = Column(String(255), nullable=False)
    phone = Column(String(20), unique=True, index=True, nullable=False)
    email = Column(String(255), unique=True, index=True, nullable=True)
    password = Column(String(255), nullable=False)
    role = Column(Enum(UserRole), default=UserRole.tenant, nullable=False)
    building_id = Column(String(36), ForeignKey("buildings.id"), nullable=True)
    notification_preferences = Column(JSON, nullable=True)

