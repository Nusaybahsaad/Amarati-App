from sqlalchemy import Column, String, Text, DateTime, ForeignKey
from datetime import datetime
from app.core.database import Base


class Notification(Base):
    __tablename__ = "notifications"

    notification_id = Column(String(36), primary_key=True)
    message = Column(Text, nullable=False)
    type = Column(String(50), nullable=False)
    date = Column(DateTime, default=datetime.utcnow)
    user_id = Column(String(36), ForeignKey("users.user_id"), nullable=False)
