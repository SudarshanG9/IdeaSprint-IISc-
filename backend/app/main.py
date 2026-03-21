
from fastapi import FastAPI
from app.routes import product, scan, qr
from app.db.database import Base, engine

Base.metadata.create_all(bind=engine)

from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Adjust in production to explicitly allow frontend IPs
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {"status": "AccessQR FastAPI Backend is Live & Tunneling Successfully!"}

@app.get("/favicon.ico", status_code=204)
def favicon():
    return None

app.include_router(product.router)
app.include_router(scan.router)
app.include_router(qr.router)