from sqlalchemy import Column, String, DateTime, ForeignKey
from datetime import datetime
from app.core.database import Base


class Document(Base):
    __tablename__ = "documents"

    document_id = Column(String(36), primary_key=True)
    doc_type = Column(String(100), nullable=False)
    upload_date = Column(DateTime, default=datetime.utcnow)
    file_path = Column(String(500), nullable=False)
    unit_id = Column(String(36), ForeignKey("units.unit_id"), nullable=True)
    user_id = Column(String(36), ForeignKey("users.user_id"), nullable=True)
    bill_id = Column(String(36), ForeignKey("bills.bill_id"), nullable=True)
