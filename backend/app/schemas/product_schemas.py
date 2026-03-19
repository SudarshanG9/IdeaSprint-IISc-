from pydantic import BaseModel
from datetime import datetime

class ProductCreate(BaseModel):
    name: str
    category: str
    price: int
    expiry_date: datetime
    region: str = "IN"
    language: str = "en"
    description: str