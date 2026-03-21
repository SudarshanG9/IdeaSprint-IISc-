from fastapi import APIRouter, Request, HTTPException
from fastapi.responses import FileResponse
import os

router = APIRouter()

@router.get("/qr/{product_id}")
def get_qr(product_id: int):
    file_path = f"storage/qr/{product_id}.png"
    
    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="QR code not generated yet")

    return FileResponse(
        file_path,
        media_type="image/png",
        filename=f"product_{product_id}_qr.png"
    )