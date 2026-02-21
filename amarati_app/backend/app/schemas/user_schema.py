from pydantic import BaseModel, ConfigDict
from typing import Optional
from app.models.user import UserRole

# Shared properties
class UserBase(BaseModel):
    phone: str
    email: Optional[str] = None
    full_name: Optional[str] = None

class UserCreate(UserBase):
    pass

class UserUpdate(UserBase):
    phone: Optional[str] = None

class OTPRequest(BaseModel):
    phone: str
    purpose: str = "login" # "login" or "verification"

class OTPVerify(BaseModel):
    phone: str
    code: str

# Properties to return to client
class UserResponse(UserBase):
    id: str
    role: UserRole
    is_active: bool
    is_verified: bool
    avatar_url: Optional[str] = None
    
    model_config = ConfigDict(from_attributes=True)

class Token(BaseModel):
    access_token: str
    token_type: str
    user: UserResponse
