import qrcode
import os

def generate_qr(product_id: int, base_url: str):
    os.makedirs("storage/qr", exist_ok=True)
    
    # Direct the QR code back to our backend API domain
    qr_data = f"{base_url}/p/{product_id}"
    file_path = f"storage/qr/{product_id}.png"

    # Save aggressively to overwrite any bad previously cached QR images
    qr = qrcode.make(qr_data)
    qr.save(file_path)

    return file_path, qr_data