from fastapi import APIRouter, HTTPException
from app.db.database import SessionLocal
from app.models.product import Product
from app.schemas.product_schemas import ProductCreate


router = APIRouter()

@router.post("/product")
def create_product(product: ProductCreate):
    db = SessionLocal()
    try:
        db_product = Product(**product.dict())
        db.add(db_product)
        db.commit()
        db.refresh(db_product)
        return {
            "message": "Product created successfully",
            "product_id": db_product.id
        }
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        db.close()
