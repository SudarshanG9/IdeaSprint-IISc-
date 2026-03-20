from fastapi import APIRouter, Request
from fastapi.responses import JSONResponse, RedirectResponse

from app.utils.detector import detect
from app.db.database import SessionLocal
from app.models.product import Product
from app.config import FRONTEND_URL

router = APIRouter()

@router.get("/p/{product_id}")
async def handle_scan(product_id: int, request: Request):
    db = SessionLocal()
    try:
        # check source
        if detect(request.headers):

            product = db.query(Product).filter(Product.id == product_id).first()

            if not product:
                return JSONResponse({"error": "Product not found"}, status_code=404)

            return JSONResponse({
                "mode": "audio",
                "product_id": product.id,
                "name": product.name,
                "status": "ready for audio pipeline"
            })

        else:
            return RedirectResponse(
                url=f"{FRONTEND_URL}/product/{product_id}"
            )
    finally:
        db.close()