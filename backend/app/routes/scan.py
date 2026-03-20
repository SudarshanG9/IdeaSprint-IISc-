from fastapi import APIRouter, Request
from fastapi.responses import JSONResponse, RedirectResponse, HTMLResponse

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
        product = db.query(Product).filter(Product.id == product_id).first()

        if not product:
            return JSONResponse({"error": "Product not found"}, status_code=404)

        # check source
        if detect(request.headers):
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
            html_content = f"""
            <html>
                <head>
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>{product.name} - Details</title>
                    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;800&display=swap" rel="stylesheet">
                    <style>
                        body {{ font-family: 'Inter', sans-serif; background-color: #f6f8fb; margin: 0; padding: 1.5rem; color: #1a202c; }}
                        .card {{ background: white; max-width: 500px; margin: 0 auto; border-radius: 16px; padding: 2rem; box-shadow: 0 10px 15px -3px rgba(0,0,0,0.05); }}
                        .header {{ display: flex; align-items: start; justify-content: space-between; border-bottom: 2px solid #edf2f7; padding-bottom: 1.2rem; margin-bottom: 1.5rem; }}
                        h1 {{ margin: 0; color: #1a202c; font-size: 1.8rem; font-weight: 800; }}
                        .badge {{ background-color: #ebf4ff; padding: 6px 14px; border-radius: 9999px; font-size: 0.8rem; font-weight: 800; color: #3182ce; letter-spacing: 0.05em; text-transform: uppercase; margin-top: 0.5rem; display: inline-block; }}
                        .detail {{ margin: 1.5rem 0; }}
                        .label {{ font-size: 0.8rem; color: #718096; text-transform: uppercase; font-weight: 700; margin-bottom: 0.4rem; letter-spacing: 0.05em; }}
                        .value {{ font-size: 1.15rem; color: #2d3748; line-height: 1.6; }}
                        .desc-box {{ background: #fbfdff; border: 1px solid #e2e8f0; padding: 1rem; border-radius: 12px; margin-top: 0.5rem; }}
                    </style>
                </head>
                <body>
                    <div class="card">
                        <div class="header">
                            <div>
                                <h1>{product.name}</h1>
                                <div class="badge">{product.category}</div>
                            </div>
                        </div>
                        <div class="detail">
                            <div class="label">Price</div>
                            <div class="value" style="font-weight: 600; font-size: 1.4rem; color: #38a169;">₹{product.price}</div>
                        </div>
                        <div class="detail">
                            <div class="label">Expiry Date</div>
                            <div class="value">{product.expiry_date.strftime('%B %d, %Y')}</div>
                        </div>
                        <div class="detail">
                            <div class="label">Product Details</div>
                            <div class="value desc-box" style="white-space: pre-wrap; font-size: 1.05rem;">{product.description}</div>
                        </div>
                    </div>
                </body>
            </html>
            """
            return HTMLResponse(content=html_content)
    finally:
        db.close()