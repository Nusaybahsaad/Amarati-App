from sqlalchemy import Column, String, Date, Text, ForeignKey
from app.core.database import Base


class PredictiveMaintenance(Base):
    __tablename__ = "predictive_maintenance"

    pm_id = Column(String(36), primary_key=True)
    last_inspection = Column(Date, nullable=True)
    next_inspection = Column(Date, nullable=True)
    risk_level = Column(String(50), nullable=True)
    notes = Column(Text, nullable=True)
    unit_id = Column(String(36), ForeignKey("units.unit_id"), nullable=False)
