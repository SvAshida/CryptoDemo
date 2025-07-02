#!/usr/bin/env bash
#
PROJECT_ROOT=/home/senna/coding/crypto
FEEDS_DIR=${PROJECT_ROOT}/feeds
LOGS_DIR=${PROJECT_ROOT}/logs

nohup python "$FEEDS_DIR/bitfinex/quoteFeed_bitfinex.py" > "$LOGS_DIR/quote_producer_bitfinex.log" &
nohup python "$FEEDS_DIR/bitmex/quoteFeed_bitmex.py" > "$LOGS_DIR/quote_producer_bitfinex.log" &
nohup python "$FEEDS_DIR/bitfinex/tradeFeed_bitfinex.py" > "$LOGS_DIR/trade_producer_bitfinex.log" &
nohup python "$FEEDS_DIR/bitmex/tradeFeed_bitmex.py" > "$LOGS_DIR/trade_producer_bitfinex.log" &