
from fastapi import FastAPI
from app.routes import product, scan

app = FastAPI()

app.include_router(product.router)
app.include_router(scan.router)