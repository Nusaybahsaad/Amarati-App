from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings

from app.api.endpoints import auth, buildings, maintenance, payments, documents, communication

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="Backend API for Amarati Property Management System"
)

# CORS for Flutter dev
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---- Routers ----
app.include_router(auth.router, prefix=f"{settings.API_V1_STR}/auth", tags=["Authentication"])
app.include_router(buildings.router, prefix=f"{settings.API_V1_STR}/buildings", tags=["Buildings & Units"])
app.include_router(maintenance.router, prefix=f"{settings.API_V1_STR}/maintenance", tags=["Maintenance"])
app.include_router(payments.router, prefix=f"{settings.API_V1_STR}/payments", tags=["Payments"])
app.include_router(documents.router, prefix=f"{settings.API_V1_STR}/documents", tags=["Documents"])
app.include_router(communication.router, prefix=f"{settings.API_V1_STR}", tags=["Communication & Chat", "Notifications", "Visits", "Chatbot"])

@app.get("/")
def read_root():
    return {"message": "Welcome to the Amarati API!", "docs": "/docs"}
