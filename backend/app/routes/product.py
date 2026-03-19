from fastapi import APIRouter, Depends, HTTPException
from app.db.database import SessionLocal
from app.models.product import Product
from app.schemas.product_schemas import ProductCreate


router = APIRouter()

@router.post("/product")
def create_product(product: ProductCreate):
    try:
        db = SessionLocal()
        product = Product(**product.dict())
        db.add(product)
        db.commit()
        db.refresh(product)
        return {
            "message": "Product created successfully",
            "product_id": product.id
        }
    except Exception as e:
        return {
            "message": "Product creation failed",
            "error": str(e)
        }
    finally:
        db.close()
