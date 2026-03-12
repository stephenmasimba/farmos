from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from .auth import get_current_user

router = APIRouter(tags=["payments"])

class PaymentIntent(BaseModel):
    amount: float
    currency: str
    description: str

@router.get("/methods")
async def get_payment_methods(current_user: dict = Depends(get_current_user)):
    return [
        {"id": "pm_card_visa", "type": "card", "brand": "visa", "last4": "4242"},
        {"id": "pm_card_mastercard", "type": "card", "brand": "mastercard", "last4": "5555"}
    ]

@router.post("/process")
async def process_payment(payment_data: dict, current_user: dict = Depends(get_current_user)):
    if current_user["role"] not in ["admin", "manager"]:
        raise HTTPException(status_code=403, detail="Not authorized")
    return {"status": "success", "transaction_id": "txn_1234567890"}

@router.post("/create-intent")
async def create_payment_intent(intent: PaymentIntent, current_user: dict = Depends(get_current_user)):
    if current_user["role"] not in ["admin", "manager"]:
        raise HTTPException(status_code=403, detail="Not authorized")
    return {"client_secret": "pi_1234567890_secret_0987654321"}
