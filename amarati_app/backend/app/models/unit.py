from sqlalchemy import Column, String, Integer, ForeignKey
from app.core.database import Base


class Unit(Base):
    __tablename__ = "units"

    unit_id = Column(String(36), primary_key=True)
    building = Column(String(255), nullable=False)
    floor = Column(Integer, nullable=False)
    user_id = Column(String(36), ForeignKey("users.user_id"), nullable=True)
