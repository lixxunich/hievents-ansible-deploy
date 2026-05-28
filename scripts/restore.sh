#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="/home/artem.kireev/course-project"
BACKUP_DIR="$PROJECT_DIR/backups"
APP_DIR="/opt/hi-events"
DB_NAME="hi_events"
DB_USER="hi_events_user"
DB_PASSWORD="StrongPassword123!"

ARCHIVE="${1:-}"
if [ -z "$ARCHIVE" ]; then
  echo "Usage: $0 <backup_archive.tar.gz>"
  exit 1
fi

if [ ! -f "$BACKUP_DIR/$ARCHIVE" ]; then
  echo "Backup archive not found: $BACKUP_DIR/$ARCHIVE"
  exit 1
fi

WORKDIR="$(mktemp -d)"
tar -xzf "$BACKUP_DIR/$ARCHIVE" -C "$WORKDIR"
RESTORE_DIR="$(find "$WORKDIR" -maxdepth 1 -type d -name 'backup_*' | head -n 1)"

sudo cp "$RESTORE_DIR/backend.env" "$APP_DIR/backend/.env"

sudo -u postgres psql -c "DROP DATABASE IF EXISTS $DB_NAME;"
sudo -u postgres psql -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;"
PGPASSWORD="$DB_PASSWORD" psql -h 127.0.0.1 -p 5432 -U "$DB_USER" -d "$DB_NAME" -f "$RESTORE_DIR/${DB_NAME}.sql"

rm -rf "$WORKDIR"
echo "Restore completed from: $ARCHIVE"
