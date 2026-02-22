from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.schemas.user_schema import UserCreate, LoginRequest, UserResponse, Token, UpdateRoleRequest
from app.services.auth_service import (
    register_user,
    authenticate_user,
    create_access_token,
    get_current_user,
)
from app.models.user import User

router = APIRouter()


@router.post("/register", response_model=Token)
async def register(data: UserCreate, db: AsyncSession = Depends(get_db)):
    user = await register_user(
        name=data.name,
        phone=data.phone,
        password=data.password,
        email=data.email,
        role=data.role,
        db=db,
    )
    token = create_access_token(user.user_id, user.role.value if hasattr(user.role, 'value') else user.role)
    return Token(
        access_token=token,
        token_type="bearer",
        user=UserResponse.model_validate(user),
    )


@router.post("/login", response_model=Token)
async def login(data: LoginRequest, db: AsyncSession = Depends(get_db)):
    user = await authenticate_user(data.phone, data.password, db)
    token = create_access_token(user.user_id, user.role.value if hasattr(user.role, 'value') else user.role)
    return Token(
        access_token=token,
        token_type="bearer",
        user=UserResponse.model_validate(user),
    )


@router.get("/me", response_model=UserResponse)
async def get_me(current_user: User = Depends(get_current_user)):
    return UserResponse.model_validate(current_user)


@router.put("/me/role", response_model=UserResponse)
async def update_role(
    data: UpdateRoleRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    current_user.role = data.role
    db.add(current_user)
    await db.commit()
    await db.refresh(current_user)
    return UserResponse.model_validate(current_user)
