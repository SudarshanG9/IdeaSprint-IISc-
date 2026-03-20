from fastapi import APIRouter, Request
from fastapi.responses import FileResponse
from app.services.qr import generate_qr

router = APIRouter()

@router.get("/qr/{product_id}")
def get_qr(product_id: int, request: Request):
    # Unpack the tuple properly
    request_base_url = str(request.base_url).rstrip('/')
    file_path, _ = generate_qr(product_id, request_base_url)

    return FileResponse(
        file_path,
        media_type="image/png",
        filename=f"product_{product_id}_qr.png"
    )