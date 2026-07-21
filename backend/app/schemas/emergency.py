import uuid

from pydantic import BaseModel

from app.schemas.contact import ContactResponse


class EmergencyContactUpdateRequest(BaseModel):
    contact_id: uuid.UUID


class EmergencyContactResponse(BaseModel):
    emergency_contact: ContactResponse
