from sqlalchemy import Column, Integer, String, Text, DateTime
from app.db.database import Base
from datetime import datetime, timezone


class Product(Base):
    __tablename__ = "products"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    category = Column(String)
    price = Column(Integer)
    expiry_date = Column(DateTime)
    region = Column(String, default='IN')
    language = Column(String, default="en")
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    description = Column(Text, nullable=False)