
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

app.include_router(product.router)
app.include_router(scan.router)
app.include_router(qr.router)