#!/usr/bin/env bash
set -uo pipefail

LOG_DIR="${LOG_DIR:-/var/www/guestbook/storage/logs}"
KEEP_DAYS="${KEEP_DAYS:-14}"
LIMIT_MB="${LIMIT_MB:-500}"
OUT="${CLEANUP_LOG:-/var/log/guestbook-cleanup.log}"

log() { echo "$(date '+%F %T') $*" >> "$OUT"; }

[ -d "$LOG_DIR" ] || { log "ERROR $LOG_DIR does not exist"; exit 1; }

TODAY="laravel-$(date +%F).log"
compressed=0
deleted=0

while IFS= read -r -d '' f; do
  if gzip -- "$f"; then
    log "COMPRESS $(basename "$f")"
    compressed=$((compressed + 1))
  else
    log "ERROR could not compress $(basename "$f")"
  fi
done < <(find "$LOG_DIR" -maxdepth 1 -type f -name 'laravel-*.log' ! -name "$TODAY" -mtime +0 -print0)

while IFS= read -r -d '' f; do
  if rm -- "$f"; then
    log "DELETE $(basename "$f")"
    deleted=$((deleted + 1))
  fi
done < <(find "$LOG_DIR" -maxdepth 1 -type f -name 'laravel-*.log.gz' -mtime +"$KEEP_DAYS" -print0)

size_mb=$(du -sm "$LOG_DIR" | cut -f1)
if [ "$size_mb" -gt "$LIMIT_MB" ]; then
  log "WARN logs folder is ${size_mb} MB, over the ${LIMIT_MB} MB limit"
fi

log "DONE compressed=$compressed deleted=$deleted size=${size_mb}MB"
