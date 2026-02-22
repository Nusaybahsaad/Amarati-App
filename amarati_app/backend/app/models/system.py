from sqlalchemy import Column, String, DateTime, ForeignKey, Text, Enum, Boolean, Integer
from datetime import datetime
import uuid
import enum
from app.core.database import Base

# NOTE: Document is defined in document.py and Notification in notification.py (new schema)


class DocumentCategory(str, enum.Enum):
    contract = "contract"
    invoice = "invoice"
    warranty = "warranty"
    id_document = "id_document"
    receipt = "receipt"
    other = "other"


class ChatMessage(Base):
    __tablename__ = "chat_messages"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    building_id = Column(String(36), ForeignKey("buildings.id"), nullable=False)
    sender_id = Column(String(36), ForeignKey("users.user_id"), nullable=False)
    message = Column(Text, nullable=False)
    message_type = Column(String(50), default="text")
    created_at = Column(DateTime, default=datetime.utcnow)


class AuditLog(Base):
    __tablename__ = "audit_logs"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), ForeignKey("users.user_id"), nullable=True)
    action = Column(String(255), nullable=False)
    entity_type = Column(String(100), nullable=True)
    entity_id = Column(String(36), nullable=True)
    details = Column(Text, nullable=True)
    ip_address = Column(String(50), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)


class ChatbotInteraction(Base):
    __tablename__ = "chatbot_interactions"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), ForeignKey("users.user_id"), nullable=False)
    query = Column(Text, nullable=False)
    response = Column(Text, nullable=False)
    language = Column(String(5), default="ar")
    module_accessed = Column(String(50), nullable=True)
    requires_confirmation = Column(Boolean, default=False)
    confirmed = Column(Boolean, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
