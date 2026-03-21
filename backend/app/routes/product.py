from fastapi import APIRouter, HTTPException, Request
from app.db.database import SessionLocal
from app.models.product import Product
from app.schemas.product_schemas import ProductCreate
from app.services.qr import generate_qr


router = APIRouter()

@router.post("/product")
def create_product(product: ProductCreate, request: Request):
    db = SessionLocal()
    try:
        db_product = Product(**product.dict())
        
        # Intercept database creation to parse payload through Gemini LLM first
        from app.services.generator import generate_description
        primary, detailed = generate_description(db_product)
        
        # Override the old raw input with beautifully structured AI generations
        db_product.description = primary
        db_product.detailed_description = detailed

        db.add(db_product)
        db.commit()
        db.refresh(db_product)

        # Build absolute base URL from deployed ngrok securely 
        from app.config import BACKEND_URL
        request_base_url = BACKEND_URL
        
        file_path, qr_data = generate_qr(db_product.id, request_base_url)
        
        db_product.qr_url = f"/qr/{db_product.id}"
        db.commit()

        # Construct absolute URL for the QR image using the incoming request's base URL (bypassing ngrok HTML block)
        absolute_qr_url = f"{str(request.base_url).rstrip('/')}/qr/{db_product.id}"

        return {
            "product_id": db_product.id,
            "qr_url": absolute_qr_url,
            "scan_url": qr_data
        }
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        db.close()
