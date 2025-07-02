import websocket
import json
import datetime
import threading
from kafka import KafkaProducer
import logging
import os
import pathlib

SCRIPT_DIR = pathlib.Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR.parent.parent
LOG_DIR = PROJECT_ROOT / "logs"
LOG_DIR.mkdir(exist_ok=True)

log_file = LOG_DIR / "quote_producer_bitmex.log"

logging.basicConfig(
    filename=str(log_file),
    level=logging.INFO,
    format='%(asctime)s %(levelname)s: %(message)s'
)


producer = KafkaProducer(
    bootstrap_servers='localhost:29092',
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)

def normalize_symbol(sym):
    replacements = {
        "XBT": "BTC"
    }
    for old, new in replacements.items():
        sym=sym.replace(old, new)
    return sym

def emit_tick(sym, side, price, size):
    action = "remove" if price == 0 or size == 0 else "update"
    message = {
        "time": datetime.datetime.now(datetime.UTC).isoformat(timespec="microseconds").replace("+00:00", "Z"),
        "sym": normalize_symbol(sym),
        "side": side,
        "price": float(price),
        "size": float(size),
        "action": action,
        "exchange": "bitmex"
    }
    producer.send("bitmex.quotes", value=message)

def on_message(ws, message):
    try:
        msg = json.loads(message)
    except Exception as e:
        logging.info("❌ JSON decode error:", e)
        return

    if msg.get("table") == "quote" and msg.get("action") == "insert":
        for entry in msg.get("data", []):
            sym = entry.get("symbol")
            if "bidPrice" in entry and "bidSize" in entry:
                emit_tick(sym, "bid", entry["bidPrice"], entry["bidSize"])
            if "askPrice" in entry and "askSize" in entry:
                emit_tick(sym, "ask", entry["askPrice"], entry["askSize"])

def on_open(ws):
    logging.info("🚀 Subscribing to BitMEX quote feed...")
    ws.send(json.dumps({
        "op": "subscribe",
        "args": ["quote:XBTUSD", "quote:ETHUSD", "quote:SOLUSD"]
    }))

def on_error(ws, error):
    logging.error("❌ WebSocket error:", error)

def on_close(ws, code, reason):
    logging.info(f"🔌 WebSocket closed: {code}, {reason}")

# Run
if __name__ == "__main__":
    ws = websocket.WebSocketApp(
        "wss://www.bitmex.com/realtime",
        on_open=on_open,
        on_message=on_message,
        on_error=on_error,
        on_close=on_close
    ).run_forever()
