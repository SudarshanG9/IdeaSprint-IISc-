from fastapi import APIRouter, Depends, HTTPException
from app.db.database import SessionLocal
from app.models.product import Product


router = APIRouter()

@router.post("/product")
def create_product(data: dict):
    db = SessionLocal()
    product = Product(**data)
    db.add(product)
    db.commit()
    db.refresh(product)
    return {
        "message": "Product created successfully",
        "product_id": product.id
    }