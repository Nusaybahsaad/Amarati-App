from sqlalchemy import Column, String, DateTime, ForeignKey, Float, Text, Enum, Boolean
from datetime import datetime
import uuid
import enum
from app.core.database import Base

# NOTE: Bill is now defined in bill.py (new schema)


class PaymentStatus(str, enum.Enum):
    pending = "pending"
    completed = "completed"
    failed = "failed"
    refunded = "refunded"


class PaymentType(str, enum.Enum):
    rent = "rent"
    maintenance = "maintenance"
    shared_expense = "shared_expense"
    other = "other"


class Payment(Base):
    __tablename__ = "payments"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    amount = Column(Float, nullable=False)
    payment_type = Column(Enum(PaymentType), default=PaymentType.rent)
    status = Column(Enum(PaymentStatus), default=PaymentStatus.pending)
    payer_id = Column(String(36), ForeignKey("users.user_id"), nullable=False)
    receiver_id = Column(String(36), ForeignKey("users.user_id"), nullable=True)
    unit_id = Column(String(36), ForeignKey("units.unit_id"), nullable=True)
    building_id = Column(String(36), ForeignKey("buildings.id"), nullable=True)
    maintenance_request_id = Column(String(36), ForeignKey("maintenance_requests.request_id"), nullable=True)
    description = Column(Text, nullable=True)
    receipt_url = Column(Text, nullable=True)
    due_date = Column(DateTime, nullable=True)
    paid_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)


class BillingReminder(Base):
    __tablename__ = "billing_reminders"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    payment_id = Column(String(36), ForeignKey("payments.id"), nullable=False)
    user_id = Column(String(36), ForeignKey("users.user_id"), nullable=False)
    message = Column(Text, nullable=True)
    is_sent = Column(Boolean, default=False)
    sent_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
