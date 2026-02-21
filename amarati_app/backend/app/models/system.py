from sqlalchemy import Column, String, DateTime, ForeignKey, Text, Enum, Boolean, Integer
from datetime import datetime
import uuid
import enum
from app.models.user import Base


class DocumentCategory(str, enum.Enum):
    contract = "contract"
    invoice = "invoice"
    warranty = "warranty"
    id_document = "id_document"
    receipt = "receipt"
    other = "other"


class Document(Base):
    __tablename__ = "documents"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    title = Column(String(255), nullable=False)
    category = Column(Enum(DocumentCategory), default=DocumentCategory.other)
    file_url = Column(Text, nullable=False)
    uploaded_by = Column(String(36), ForeignKey("users.id"), nullable=False)
    unit_id = Column(String(36), ForeignKey("units.id"), nullable=True)
    building_id = Column(String(36), ForeignKey("buildings.id"), nullable=True)
    expires_at = Column(DateTime, nullable=True)
    is_expired = Column(Boolean, default=False)
    version = Column(Integer, default=1)
    parent_document_id = Column(String(36), ForeignKey("documents.id"), nullable=True)
    visibility_role = Column(String(50), default="all")  # all, owner, tenant, supervisor
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class ChatMessage(Base):
    __tablename__ = "chat_messages"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    building_id = Column(String(36), ForeignKey("buildings.id"), nullable=False)
    sender_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    message = Column(Text, nullable=False)
    message_type = Column(String(50), default="text")  # text, image, announcement, vote
    created_at = Column(DateTime, default=datetime.utcnow)


class Notification(Base):
    __tablename__ = "notifications"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    title = Column(String(255), nullable=False)
    body = Column(Text, nullable=True)
    notification_type = Column(String(50), default="general")  # general, maintenance, payment, document, chat
    is_read = Column(Boolean, default=False)
    action_url = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)


class AuditLog(Base):
    __tablename__ = "audit_logs"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), ForeignKey("users.id"), nullable=True)
    action = Column(String(255), nullable=False)
    entity_type = Column(String(100), nullable=True)  # user, request, payment, document, chat
    entity_id = Column(String(36), nullable=True)
    details = Column(Text, nullable=True)
    ip_address = Column(String(50), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)


class ChatbotInteraction(Base):
    __tablename__ = "chatbot_interactions"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    query = Column(Text, nullable=False)
    response = Column(Text, nullable=False)
    language = Column(String(5), default="ar")  # ar, en
    module_accessed = Column(String(50), nullable=True)  # maintenance, payment, document
    requires_confirmation = Column(Boolean, default=False)
    confirmed = Column(Boolean, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
