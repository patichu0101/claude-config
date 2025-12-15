# PROJECT MEMORY

## Project Overview

**Project Name:** {{PROJECT_NAME}}
**Framework:** {{FRAMEWORK}} {{FRAMEWORK_VERSION}}
**Language:** Python 3.11+
**Generated:** {{GENERATED_DATE}}

High-performance async Python API framework with automatic OpenAPI documentation and type safety via Pydantic.

---

## Tech Stack

### Backend
- **Framework**: {{FRAMEWORK}} {{FRAMEWORK_VERSION}}
- **Language**: Python 3.11+ (async/await support)
- **Validation**: Pydantic v2 (type-safe models)
- **Database**: [Specify: PostgreSQL + SQLAlchemy, MongoDB, etc.]
- **ORM**: SQLAlchemy 2.0 (async) / Tortoise ORM

### Development
- **Package Manager**: {{PACKAGE_MANAGER}}
- **Testing**: {{TEST_FRAMEWORK}} + httpx
- **Linting**: Ruff (formatter + linter)
- **Type Checking**: mypy (strict mode)
- **API Docs**: Auto-generated Swagger UI + ReDoc

### Key Dependencies
{{DEPENDENCIES_LIST}}

---

## Folder Structure

```
{{PROJECT_PATH}}/
├── app/
│   ├── api/
│   │   ├── v1/
│   │   │   ├── endpoints/
│   │   │   │   ├── users.py        # User endpoints
│   │   │   │   └── items.py        # Item endpoints
│   │   │   └── router.py           # API v1 router
│   │   └── dependencies.py         # Shared dependencies
│   ├── core/
│   │   ├── config.py               # Settings (Pydantic BaseSettings)
│   │   ├── security.py             # Auth utilities
│   │   └── database.py             # DB connection
│   ├── models/
│   │   ├── user.py                 # SQLAlchemy models
│   │   └── item.py
│   ├── schemas/
│   │   ├── user.py                 # Pydantic schemas
│   │   └── item.py
│   ├── services/
│   │   ├── user_service.py         # Business logic
│   │   └── item_service.py
│   └── main.py                     # FastAPI app entry point
├── tests/
│   ├── api/
│   │   └── test_users.py
│   └── conftest.py                 # Pytest fixtures
├── alembic/                        # Database migrations
├── pyproject.toml                  # Project config
└── .env.example                    # Environment template
```

---

## Coding Preferences

### API Endpoint Pattern

```python
# app/api/v1/endpoints/users.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.schemas.user import UserCreate, UserResponse
from app.services.user_service import UserService

router = APIRouter(prefix="/users", tags=["users"])

@router.post("/", response_model=UserResponse, status_code=201)
async def create_user(
    user_data: UserCreate,
    db: AsyncSession = Depends(get_db)
):
    """Create a new user."""
    service = UserService(db)
    user = await service.create_user(user_data)
    return user

@router.get("/{user_id}", response_model=UserResponse)
async def get_user(
    user_id: int,
    db: AsyncSession = Depends(get_db)
):
    """Get user by ID."""
    service = UserService(db)
    user = await service.get_user(user_id)

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    return user
```

### Pydantic Schemas (Type-Safe Models)

```python
# app/schemas/user.py
from pydantic import BaseModel, EmailStr, Field
from datetime import datetime

class UserBase(BaseModel):
    email: EmailStr
    username: str = Field(..., min_length=3, max_length=50)

class UserCreate(UserBase):
    password: str = Field(..., min_length=8)

class UserResponse(UserBase):
    id: int
    created_at: datetime
    is_active: bool

    class Config:
        from_attributes = True  # Pydantic v2 (was orm_mode in v1)
```

### Dependency Injection

```python
# app/api/dependencies.py
from fastapi import Depends, HTTPException, Header
from app.core.security import verify_token

async def get_current_user(authorization: str = Header(...)):
    """Dependency to get current authenticated user."""
    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid authorization header")

    token = authorization[7:]  # Remove "Bearer " prefix
    user = await verify_token(token)

    if not user:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    return user
```

### Async Database Operations

```python
# app/services/user_service.py
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

class UserService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def create_user(self, user_data: UserCreate) -> User:
        user = User(**user_data.model_dump(exclude={"password"}))
        user.hashed_password = hash_password(user_data.password)

        self.db.add(user)
        await self.db.commit()
        await self.db.refresh(user)

        return user

    async def get_user(self, user_id: int) -> User | None:
        result = await self.db.execute(
            select(User).where(User.id == user_id)
        )
        return result.scalar_one_or_none()
```

---

## Common Commands

### Development
```bash
{{PACKAGE_MANAGER}} run uvicorn app.main:app --reload  # Start dev server
{{PACKAGE_MANAGER}} run dev                            # Alias for above
```

### Testing
```bash
{{PACKAGE_MANAGER}} run pytest                         # Run all tests
{{PACKAGE_MANAGER}} run pytest --cov                   # Run with coverage
{{PACKAGE_MANAGER}} run pytest -v                      # Verbose output
{{PACKAGE_MANAGER}} run pytest tests/api/test_users.py # Single file
```

### Code Quality
```bash
{{PACKAGE_MANAGER}} run ruff format .                  # Format code
{{PACKAGE_MANAGER}} run ruff check .                   # Lint code
{{PACKAGE_MANAGER}} run mypy app                       # Type checking
```

### Database Migrations
```bash
alembic revision --autogenerate -m "Add users table"   # Create migration
alembic upgrade head                                   # Apply migrations
alembic downgrade -1                                   # Rollback one migration
```

---

## Testing Guidelines

```python
# tests/api/test_users.py
import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_create_user(client: AsyncClient):
    """Test user creation endpoint."""
    response = await client.post(
        "/api/v1/users/",
        json={
            "email": "test@example.com",
            "username": "testuser",
            "password": "secretpassword"
        }
    )

    assert response.status_code == 201
    data = response.json()
    assert data["email"] == "test@example.com"
    assert data["username"] == "testuser"
    assert "id" in data
    assert "password" not in data  # Password should not be in response

@pytest.mark.asyncio
async def test_get_user_not_found(client: AsyncClient):
    """Test get user with non-existent ID."""
    response = await client.get("/api/v1/users/99999")

    assert response.status_code == 404
    assert response.json()["detail"] == "User not found"
```

---

## Important Quirks & Gotchas

### FastAPI Specific
- **Async everywhere**: Use `async def` for endpoints and database operations
- **Dependency injection**: Use `Depends()` for reusable logic (auth, DB, etc.)
- **Response models**: Always specify `response_model` for type safety
- **Path operations order**: More specific routes must come before generic ones
- **Background tasks**: Use `BackgroundTasks` for non-blocking operations

### Pydantic v2
- **`from_attributes`**: Replaces `orm_mode` from Pydantic v1
- **`model_dump()`**: Replaces `.dict()` from Pydantic v1
- **Validation**: Stricter by default, use `Field()` for constraints

### Database (SQLAlchemy 2.0)
- **Async sessions**: Use `AsyncSession` not regular `Session`
- **`select()` syntax**: New style: `select(User).where(User.id == 1)`
- **Eager loading**: Use `selectinload()` or `joinedload()` to avoid N+1 queries

### Environment Variables
- **Pydantic Settings**: Use `BaseSettings` class for type-safe config
- **`.env` file**: Load automatically with `python-dotenv`
- **Never commit secrets**: Add `.env` to `.gitignore`

---

## When Stuck

1. **Check API docs** - Visit `/docs` (Swagger UI) or `/redoc` for interactive docs
2. **Review logs** - Uvicorn logs show request/response details
3. **Database connection** - Verify DB credentials in `.env`
4. **Migration issues** - Check alembic migrations are up to date
5. **Type errors** - Run `mypy app` to catch type issues before runtime
6. **Open draft PR** - Share your approach for feedback

---

## Additional Resources

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Pydantic v2 Documentation](https://docs.pydantic.dev/latest/)
- [SQLAlchemy 2.0 Documentation](https://docs.sqlalchemy.org/en/20/)
- [Async Python Guide](https://realpython.com/async-io-python/)

---

*Auto-generated by CLAUDE.md Auto-Init System on {{GENERATED_DATE}}*
