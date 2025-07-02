#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ENV_FILE=${PROJECT_ROOT}/docker/.env
SHARED_FILE=${PROJECT_ROOT}/docker/compose.yaml
BITMEX_FILE=${PROJECT_ROOT}/docker/compose-bitmex.yaml
BITFINEX_FILE=${PROJECT_ROOT}/docker/compose-bitfinex.yaml

MODE="${1:-all}"

echo "Stopping in mode: $MODE"

case "$MODE" in
  all)
    docker compose -f "$SHARED_FILE" down -v
    docker compose -f "$BITMEX_FILE" down -v
    docker compose -f "$BITFINEX_FILE" down -v
    ;;
  framework)
    docker compose -f "$SHARED_FILE" down -v
    ;;
  bitmex)
    docker compose -f "$BITMEX_FILE" down -v
    ;;
  bitfinex)
    docker compose -f "$BITFINEX_FILE" down -v
    ;;
  *)
    echo "❌ Invalid option: $MODE"
    echo "Usage: $0 [all|framework|bitmex|bitfinex]"
    exit 1
    ;;
esac