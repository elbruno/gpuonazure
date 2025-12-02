#!/bin/bash
# Orchestrates environment setup, tool installation, and verification.
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() { echo "[bootstrap] $*"; }

START_TIME=$(date +%s)
log "Bootstrap starting"

# 1. Environment normalization
if [ -f "$SCRIPT_DIR/env-setup.sh" ]; then
  log "Running env-setup.sh"
  bash "$SCRIPT_DIR/env-setup.sh"
else
  log "env-setup.sh missing (unexpected)" >&2
fi

# 2. Tool installation (idempotent) - run only if key tools missing
need_install=false
command -v java >/dev/null 2>&1 || need_install=true
command -v dotnet >/dev/null 2>&1 || need_install=true
command -v aspire >/dev/null 2>&1 || need_install=true

if $need_install; then
  if [ -f "$SCRIPT_DIR/post-install.sh" ]; then
    log "Running post-install.sh (tools not fully present)"
    bash "$SCRIPT_DIR/post-install.sh"
  else
    log "post-install.sh missing (unexpected)" >&2
  fi
else
  log "Core tools already present; skipping post-install"
fi

# 3. Verification
if [ -f "$SCRIPT_DIR/verify-tools.sh" ]; then
  log "Running verify-tools.sh"
  bash "$SCRIPT_DIR/verify-tools.sh"
else
  log "verify-tools.sh missing (unexpected)" >&2
fi

END_TIME=$(date +%s)
log "Bootstrap complete in $((END_TIME-START_TIME))s"
