from fastapi import APIRouter, HTTPException, status
from app.schemas.user_schema import OTPRequest, OTPVerify, UserResponse, Token
import uuid

router = APIRouter()

@router.post("/request-otp", response_model=dict)
async def request_otp(request: OTPRequest):
    # Simulate saving OTP to database
    # In a real app, this would integrate with an SMS gateway (e.g., Twilio, Unifonic)
    return {"message": "OTP sent successfully", "phone": request.phone}

@router.post("/verify-otp", response_model=Token)
async def verify_otp(request: OTPVerify):
    # Simulate DB check
    if request.code != "1234": # Hardcoded for dev
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="رمز التحقق غير صحيح" # Invalid OTP in Arabic
        )
    
    # Simulate user retrieval or creation
    mock_user = UserResponse(
        id=str(uuid.uuid4()),
        phone=request.phone,
        role="tenant",
        is_active=True,
        is_verified=True
    )
    
    return Token(
        access_token="mock_jwt_token_for_dev",
        token_type="bearer",
        user=mock_user
    )
