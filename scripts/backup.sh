#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="/home/artem.kireev/course-project"
BACKUP_DIR="$PROJECT_DIR/backups"
APP_DIR="/opt/hi-events"
DB_NAME="hi_events"
DB_USER="hi_events_user"
DATE="$(date +%Y-%m-%d_%H-%M-%S)"
TARGET="$BACKUP_DIR/backup_$DATE"

mkdir -p "$TARGET"

PGPASSWORD="StrongPassword123!" pg_dump -h 127.0.0.1 -p 5432 -U "$DB_USER" "$DB_NAME" > "$TARGET/${DB_NAME}.sql"
cp "$APP_DIR/backend/.env" "$TARGET/backend.env"

tar -czf "$BACKUP_DIR/backup_$DATE.tar.gz" -C "$BACKUP_DIR" "backup_$DATE"
rm -rf "$TARGET"

echo "Backup created: $BACKUP_DIR/backup_$DATE.tar.gz"
