import uuid
from datetime import datetime

from sqlalchemy import Enum, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.sql import func

from app.database import Base

conversation_channel_enum = Enum(
    "text", "voice", "mixed", name="conversation_channel", create_constraint=True
)


class Conversation(Base):
    __tablename__ = "conversations"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid()
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False
    )
    channel: Mapped[str] = mapped_column(conversation_channel_enum, nullable=False)
    started_at: Mapped[datetime] = mapped_column(server_default=func.now(), nullable=False)
    ended_at: Mapped[datetime | None] = mapped_column(nullable=True)
