from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from datetime import datetime

router = APIRouter()

class Notification(BaseModel):
    id: int
    type: str # info, success, warning, error
    message: str
    read: bool
    timestamp: str

# Mock Data
notifications_db = [
    {"id": 1, "type": "info", "message": "System maintenance scheduled for tonight.", "read": False, "timestamp": "2023-10-27T09:00:00Z"},
    {"id": 2, "type": "warning", "message": "Low feed stock for Batch A.", "read": True, "timestamp": "2023-10-26T15:00:00Z"},
]

@router.get("/")
async def get_notifications():
    return notifications_db

@router.post("/")
async def create_notification(notification: Notification):
    new_notif = notification.dict()
    new_notif["id"] = len(notifications_db) + 1
    new_notif["read"] = False
    new_notif["timestamp"] = datetime.utcnow().isoformat()
    notifications_db.append(new_notif)
    return new_notif

@router.put("/{id}/read")
async def mark_as_read(id: int):
    for n in notifications_db:
        if n["id"] == id:
            n["read"] = True
            return n
    raise HTTPException(status_code=404, detail="Notification not found")

@router.put("/read-all")
async def mark_all_as_read():
    for n in notifications_db:
        n["read"] = True
    return {"message": "All notifications marked as read"}
