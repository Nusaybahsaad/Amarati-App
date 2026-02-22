from pydantic import BaseModel, ConfigDict
from typing import Optional


class UserCreate(BaseModel):
    name: str
    phone: str
    email: Optional[str] = None
    password: str
    role: str = "tenant"


class LoginRequest(BaseModel):
    phone: str
    password: str


class UserResponse(BaseModel):
    user_id: str
    name: str
    phone: str
    email: Optional[str] = None
    role: str

    model_config = ConfigDict(from_attributes=True)


class Token(BaseModel):
    access_token: str
    token_type: str
    user: UserResponse


class UpdateRoleRequest(BaseModel):
    role: str
