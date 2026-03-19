
from fastapi import FastAPI
from app.routes import product, scan
from app.db.database import Base, engine

Base.metadata.create_all(bind=engine)

app = FastAPI()

app.include_router(product.router)
app.include_router(scan.router)