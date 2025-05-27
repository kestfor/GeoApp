# --- Request Models ---
from typing import List, Optional, Dict

from pydantic import BaseModel, Field


class SendToTokenRequest(BaseModel):
    token: str = Field(..., description="Registration token of the target device")
    title: str = Field(..., description="Notification title")
    description: Optional[str] = Field(None, description="Notification body")
    image_url: Optional[str] = Field(None, description="Image URL")


class SendMulticastRequest(BaseModel):
    tokens: List[str] = Field(..., description="List of registration tokens (max 500)")
    title: str = Field(..., description="Notification title")
    description: Optional[str] = Field(None, description="Notification body")
    image_url: Optional[str] = Field(None, description="Image URL")


class TopicSubscriptionRequest(BaseModel):
    tokens: List[str] = Field(..., description="List of registration tokens (max 1000)")
    topic: str = Field(..., description="FCM topic name")


# --- Response Models ---

class SendResponse(BaseModel):
    message_id: str = Field(..., description="FCM message identifier")


class MulticastResponse(BaseModel):
    success_count: int = Field(..., description="Number of tokens that received the message successfully")
    failure_count: int = Field(..., description="Number of tokens that failed to receive the message")
    failed_tokens: Optional[List[str]] = Field(None, description="List of tokens that failed (if any)")


class TopicManagementResponseModel(BaseModel):
    success_count: int = Field(..., description="Number of tokens successfully subscribed/unsubscribed")
    failure_count: int = Field(..., description="Number of tokens that failed the operation")
    errors: Optional[List[Dict[str, str]]] = Field(None, description="Error details per token, if any")

# --- Endpoints ---
