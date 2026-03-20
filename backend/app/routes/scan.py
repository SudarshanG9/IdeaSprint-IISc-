from fastapi import APIRouter, Request
from fastapi.responses import JSONResponse, RedirectResponse

from app.utils.detector import detect
from app.db.database import SessionLocal
from app.models.product import Product
from app.config import FRONTEND_URL
from app.services.pipeline import process_product

router = APIRouter()

@router.get("/p/{product_id}")
async def handle_scan(product_id: int, request: Request, lang: str = None):
    db = SessionLocal()
    try:
        # check source
        if detect(request.headers):

            product = db.query(Product).filter(Product.id == product_id).first()

            if not product:
                return JSONResponse({"error": "Product not found"}, status_code=404)

            # Use requested language or fallback to product's language
            request_lang = lang if lang else product.language

            # Always run the pipeline to get the translated text and audio for the requested language
            # (Note: Supabase and disk caching will prevent duplicate audio generation)
            result = process_product(product, db, request_lang)
            db.refresh(product)

            return JSONResponse({
                "mode": "audio",
                "product_id": product.id,
                "name": product.name,
                "status": "ready",
                "audio_url": result["audio"],
                "description": result["text"]
            })

        else:
            return RedirectResponse(
                url=f"{FRONTEND_URL}/product/{product_id}"
            )
    finally:
        db.close()