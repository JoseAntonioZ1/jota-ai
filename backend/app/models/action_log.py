import uuid
from datetime import datetime

from sqlalchemy import Enum, ForeignKey, String
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.sql import func

from app.database import Base

action_type_enum = Enum(
    "reminder_created",
    "reminder_updated",
    "reminder_deleted",
    "reminder_notified",
    "contact_created",
    "contact_updated",
    "contact_deleted",
    "contact_called",
    "emergency_called",
    name="action_type",
    create_constraint=True,
)


class ActionLog(Base):
    __tablename__ = "action_logs"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid()
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False
    )
    action_type: Mapped[str] = mapped_column(action_type_enum, nullable=False)
    reference_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    description: Mapped[str] = mapped_column(String(280), nullable=False)
    created_at: Mapped[datetime] = mapped_column(server_default=func.now(), nullable=False)
