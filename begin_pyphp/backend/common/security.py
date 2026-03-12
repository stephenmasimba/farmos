import os
import time
import jwt
from typing import Optional, Dict, Any

JWT_SECRET = os.getenv("JWT_SECRET", "change_me")
JWT_ALG = "HS256"
API_KEY = os.getenv("API_KEY", "local-dev-key")

def verify_api_key(key: Optional[str]) -> bool:
    return key is not None and key == API_KEY

def get_tenant_context(tenant_id: Optional[str]) -> str:
    return tenant_id or "default"

def jwt_encode(payload: Dict[str, Any], exp_seconds: int = 3600) -> str:
    to_encode = dict(payload)
    to_encode["exp"] = int(time.time()) + exp_seconds
    return jwt.encode(to_encode, JWT_SECRET, algorithm=JWT_ALG)

def jwt_decode(token: str) -> Optional[Dict[str, Any]]:
    try:
        return jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALG])
    except Exception:
        return None

