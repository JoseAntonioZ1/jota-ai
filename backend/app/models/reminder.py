import uuid
from datetime import datetime

from sqlalchemy import Enum, ForeignKey, String
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.sql import func

from app.database import Base

reminder_type_enum = Enum(
    "medication", "event", "activity", name="reminder_type", create_constraint=True
)
reminder_status_enum = Enum(
    "pending", "completed", "cancelled", name="reminder_status", create_constraint=True
)


class Reminder(Base):
    __tablename__ = "reminders"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid()
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False
    )
    description: Mapped[str] = mapped_column(String(280), nullable=False)
    reminder_type: Mapped[str] = mapped_column(reminder_type_enum, nullable=False)
    scheduled_at: Mapped[datetime] = mapped_column(nullable=False)
    status: Mapped[str] = mapped_column(reminder_status_enum, nullable=False, default="pending")
    notified_at: Mapped[datetime | None] = mapped_column(nullable=True)
    created_at: Mapped[datetime] = mapped_column(server_default=func.now(), nullable=False)
    updated_at: Mapped[datetime] = mapped_column(
        server_default=func.now(), onupdate=func.now(), nullable=False
    )
