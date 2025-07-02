#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ENV_FILE=${PROJECT_ROOT}/docker/.env
SHARED_FILE=${PROJECT_ROOT}/docker/compose.yaml
BITMEX_FILE=${PROJECT_ROOT}/docker/compose-bitmex.yaml
BITFINEX_FILE=${PROJECT_ROOT}/docker/compose-bitfinex.yaml

MODE="${1:-all}"

echo "▶️ Starting in mode: $MODE"

case "$MODE" in
  all)
    docker compose --env-file "$ENV_FILE" -f "$SHARED_FILE" up -d --remove-orphans
    docker compose --env-file "$ENV_FILE" -f "$BITMEX_FILE" up -d
    docker compose --env-file "$ENV_FILE" -f "$BITFINEX_FILE" up -d
    ;;
  framework)
    docker compose --env-file "$ENV_FILE" -f "$SHARED_FILE" up -d --remove-orphans
    ;;
  bitmex)
    docker compose --env-file "$ENV_FILE" -f "$BITMEX_FILE" up -d
    ;;
  bitfinex)
    docker compose --env-file "$ENV_FILE" -f "$BITFINEX_FILE" up -d
    ;;
  *)
    echo "❌ Invalid option: $MODE"
    echo "Usage: $0 [all|framework|bitmex|bitfinex]"
    exit 1
    ;;
esac