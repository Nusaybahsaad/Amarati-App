from sqlalchemy import Column, String, Text, DateTime, ForeignKey, Boolean
from datetime import datetime
from app.core.database import Base


class Notification(Base):
    __tablename__ = "notifications"

    notification_id = Column(String(36), primary_key=True)
    title = Column(String(255), nullable=False)
    message = Column(Text, nullable=False)
    type = Column(String(50), nullable=False)
    is_read = Column(Boolean, default=False)
    related_entity_id = Column(String(36), nullable=True)
    related_entity_type = Column(String(50), nullable=True)
    date = Column(DateTime, default=datetime.utcnow)
    user_id = Column(String(36), ForeignKey("users.user_id"), nullable=False)
