#!/usr/bin/env bash

set -uo pipefail
umask 077

BACKUP_DIR=/var/backups/guestbook-db
CNF=/home/dbbackup/.backup.cnf
DB="${DB:-guestbook}"
KEEP_FILES="${KEEP_FILES:-7}"
LOG="$BACKUP_DIR/backup.log"

log() { echo "$(date '+%F %T') $*" >> "$LOG"; }

STAMP=$(date +%Y%m%d-%H%M%S)
FINAL="$BACKUP_DIR/${DB}-${STAMP}.sql.gz"
TMP="$FINAL.partial"

if mysqldump --defaults-extra-file="$CNF" --single-transaction --no-tablespaces "$DB" | gzip > "$TMP" \
   && gzip -t "$TMP" \
   && gunzip -c "$TMP" | tail -n 1 | grep -q "Dump completed"; then
  mv "$TMP" "$FINAL"
  log "OK    $(basename "$FINAL") $(du -h "$FINAL" | cut -f1)"
else
	rm -f "$TMP"
	log "FAIL  backup of $DB failed, partial file deleted"
	exit 1
fi

ls -1t "$BACKUP_DIR"/${DB}-*.sql.gz 2>/dev/null | tail -n +$((KEEP_FILES + 1)) \
  | while read -r f; do rm -f "$f" && log "PURGE $(basename "$f")"; done
