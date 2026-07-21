"""esquema inicial: users, contacts, reminders, conversations, conversation_messages, action_logs

Revision ID: 0001
Revises:
Create Date: 2026-07-20

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision: str = "0001"
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "users",
        sa.Column(
            "id",
            postgresql.UUID(as_uuid=True),
            primary_key=True,
            server_default=sa.text("gen_random_uuid()"),
        ),
        sa.Column("device_token_hash", sa.String(128), nullable=False, unique=True),
        sa.Column("name", sa.String(100), nullable=False),
        sa.Column("emergency_contact_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("onboarding_completed_at", sa.TIMESTAMP(), nullable=True),
        sa.Column(
            "created_at", sa.TIMESTAMP(), nullable=False, server_default=sa.text("now()")
        ),
    )

    op.create_table(
        "contacts",
        sa.Column(
            "id",
            postgresql.UUID(as_uuid=True),
            primary_key=True,
            server_default=sa.text("gen_random_uuid()"),
        ),
        sa.Column(
            "user_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("users.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("name", sa.String(100), nullable=False),
        sa.Column("phone_number", sa.String(20), nullable=False),
        sa.Column("photo_url", sa.Text(), nullable=True),
        sa.Column(
            "created_at", sa.TIMESTAMP(), nullable=False, server_default=sa.text("now()")
        ),
        sa.Column(
            "updated_at", sa.TIMESTAMP(), nullable=False, server_default=sa.text("now()")
        ),
    )
    op.create_index("idx_contacts_user_id", "contacts", ["user_id"])

    op.create_foreign_key(
        "fk_users_emergency_contact_id",
        "users",
        "contacts",
        ["emergency_contact_id"],
        ["id"],
        ondelete="SET NULL",
    )

    reminder_type = postgresql.ENUM(
        "medication", "event", "activity", name="reminder_type"
    )
    reminder_status = postgresql.ENUM(
        "pending", "completed", "cancelled", name="reminder_status"
    )

    op.create_table(
        "reminders",
        sa.Column(
            "id",
            postgresql.UUID(as_uuid=True),
            primary_key=True,
            server_default=sa.text("gen_random_uuid()"),
        ),
        sa.Column(
            "user_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("users.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("description", sa.String(280), nullable=False),
        sa.Column("reminder_type", reminder_type, nullable=False),
        sa.Column("scheduled_at", sa.TIMESTAMP(), nullable=False),
        sa.Column(
            "status", reminder_status, nullable=False, server_default="pending"
        ),
        sa.Column("notified_at", sa.TIMESTAMP(), nullable=True),
        sa.Column(
            "created_at", sa.TIMESTAMP(), nullable=False, server_default=sa.text("now()")
        ),
        sa.Column(
            "updated_at", sa.TIMESTAMP(), nullable=False, server_default=sa.text("now()")
        ),
    )
    op.create_index(
        "idx_reminders_user_scheduled", "reminders", ["user_id", "scheduled_at"]
    )

    conversation_channel = postgresql.ENUM(
        "text", "voice", "mixed", name="conversation_channel"
    )

    op.create_table(
        "conversations",
        sa.Column(
            "id",
            postgresql.UUID(as_uuid=True),
            primary_key=True,
            server_default=sa.text("gen_random_uuid()"),
        ),
        sa.Column(
            "user_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("users.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("channel", conversation_channel, nullable=False),
        sa.Column(
            "started_at", sa.TIMESTAMP(), nullable=False, server_default=sa.text("now()")
        ),
        sa.Column("ended_at", sa.TIMESTAMP(), nullable=True),
    )
    op.create_index(
        "idx_conversations_user_started", "conversations", ["user_id", "started_at"]
    )

    message_role = postgresql.ENUM("user", "assistant", name="message_role")

    op.create_table(
        "conversation_messages",
        sa.Column(
            "id",
            postgresql.UUID(as_uuid=True),
            primary_key=True,
            server_default=sa.text("gen_random_uuid()"),
        ),
        sa.Column(
            "conversation_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("conversations.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("role", message_role, nullable=False),
        sa.Column("content", sa.Text(), nullable=False),
        sa.Column("intent", sa.String(30), nullable=True),
        sa.Column("entities", postgresql.JSONB(), nullable=True),
        sa.Column(
            "created_at", sa.TIMESTAMP(), nullable=False, server_default=sa.text("now()")
        ),
    )
    op.create_index(
        "idx_messages_conversation_created",
        "conversation_messages",
        ["conversation_id", "created_at"],
    )

    action_type = postgresql.ENUM(
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
    )

    op.create_table(
        "action_logs",
        sa.Column(
            "id",
            postgresql.UUID(as_uuid=True),
            primary_key=True,
            server_default=sa.text("gen_random_uuid()"),
        ),
        sa.Column(
            "user_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("users.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("action_type", action_type, nullable=False),
        sa.Column("reference_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("description", sa.String(280), nullable=False),
        sa.Column(
            "created_at", sa.TIMESTAMP(), nullable=False, server_default=sa.text("now()")
        ),
    )
    op.create_index("idx_action_logs_user_created", "action_logs", ["user_id", "created_at"])


def downgrade() -> None:
    op.drop_table("action_logs")
    op.execute("DROP TYPE IF EXISTS action_type")

    op.drop_table("conversation_messages")
    op.execute("DROP TYPE IF EXISTS message_role")

    op.drop_table("conversations")
    op.execute("DROP TYPE IF EXISTS conversation_channel")

    op.drop_table("reminders")
    op.execute("DROP TYPE IF EXISTS reminder_status")
    op.execute("DROP TYPE IF EXISTS reminder_type")

    op.drop_constraint("fk_users_emergency_contact_id", "users", type_="foreignkey")
    op.drop_table("contacts")
    op.drop_table("users")
