from fastapi import APIRouter, Depends
from typing import List
from pydantic import BaseModel
import hashlib
from datetime import datetime
from ..common.dependencies import get_current_user

router = APIRouter(tags=["blockchain"])

class Transaction(BaseModel):
    sender: str
    receiver: str
    item: str
    quantity: float
    timestamp: str = None

class Block(BaseModel):
    index: int
    timestamp: str
    transactions: List[Transaction]
    previous_hash: str
    hash: str

chain = []

def calculate_hash(index, timestamp, transactions, previous_hash):
    # Simple hash calculation
    value = f"{index}{timestamp}{str(transactions)}{previous_hash}"
    return hashlib.sha256(value.encode()).hexdigest()

def create_genesis_block():
    timestamp = datetime.now().isoformat()
    return {
        "index": 0,
        "timestamp": timestamp,
        "transactions": [],
        "previous_hash": "0",
        "hash": calculate_hash(0, timestamp, [], "0")
    }

# Initialize with genesis block
chain.append(create_genesis_block())

@router.get("/chain", response_model=List[Block])
async def get_chain():
    return chain

@router.post("/record", response_model=Block)
async def record_transaction(txn: Transaction, current_user: dict = Depends(get_current_user)):
    # Override sender with authenticated user
    txn.sender = current_user.get("email", "unknown_user")

    # Simulating mining/adding a block for a single transaction for traceability
    previous_block = chain[-1]
    new_index = previous_block["index"] + 1
    timestamp = datetime.now().isoformat()
    
    if not txn.timestamp:
        txn.timestamp = timestamp

    # In a real blockchain, transactions accumulate in a mempool. 
    # Here we just create a block per record for traceability demonstration.
    
    new_hash = calculate_hash(new_index, timestamp, [txn.dict()], previous_block["hash"])
    
    new_block = {
        "index": new_index,
        "timestamp": timestamp,
        "transactions": [txn.dict()],
        "previous_hash": previous_block["hash"],
        "hash": new_hash
    }
    chain.append(new_block)
    return new_block
