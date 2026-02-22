from sqlalchemy import Column, String, Float, Date, ForeignKey
from app.core.database import Base


class Bill(Base):
    __tablename__ = "bills"

    bill_id = Column(String(36), primary_key=True)
    amount = Column(Float, nullable=False)
    due_date = Column(Date, nullable=False)
    status = Column(String(50), nullable=False, default="pending")
    user_id = Column(String(36), ForeignKey("users.user_id"), nullable=False)
    unit_id = Column(String(36), ForeignKey("units.unit_id"), nullable=False)
