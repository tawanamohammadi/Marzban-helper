from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .app.core.database import engine, Base
from .app.api import auth, reseller, admin_panel

# Create Database Tables
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Marzban Auxiliary Panel",
    description="Backend API for Marzban Auxiliary Panel (Resellers & Visual Config)",
    version="1.0.0",
)

# CORS Middleware (Allow Frontend)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], 
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include Routers
app.include_router(auth.router, prefix="/api/auth", tags=["Authentication"])
app.include_router(reseller.router, prefix="/api/reseller", tags=["Reseller"])
app.include_router(admin_panel.router, prefix="/api/admin", tags=["Admin Panel"])

@app.get("/")
def read_root():
    return {"message": "Marzban Auxiliary Panel Backend is Running!"}
