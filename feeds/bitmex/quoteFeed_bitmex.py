import websocket
import json
import datetime
import threading
from kafka import KafkaProducer
import os
import pathlib
import logging
import sys

SCRIPT_DIR = pathlib.Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR.parent.parent


logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s %(levelname)s: %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout)  # <--- important
    ]
)

producer = KafkaProducer(
    bootstrap_servers='kafka:9092',
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)

def normalize_symbol(sym):
    replacements = {
        "XBT": "BTC"
    }
    for old, new in replacements.items():
        sym=sym.replace(old, new)
    return sym

def emit_tick(sym, side, price, size, orderID, action):
    action = "remove" if action == "delete" else "update"
    message = {
        "time": datetime.datetime.now(datetime.UTC).isoformat(timespec="microseconds").replace("+00:00", "Z"),
        "sym": normalize_symbol(sym),
        "side": side,
        "price": float(price),
        "size": float(size),
        "action": action,
        "orderID": str(orderID),
        "exchange": "bitmex"
    }
    producer.send("bitmex.quotes", value=message)

def on_message(ws, message):
    try:
        msg = json.loads(message)
    except Exception as e:
        logging.info("❌ JSON decode error:", e)
        return
    if msg.get("table") == "orderBookL2_25" and msg.get("table") != "partial":
        action = msg.get("action")
        for entry in msg.get("data", []):
            size = entry.get("size",0)
            sym = entry.get("symbol")
            orderID = entry.get("id")
            if entry["side"] == "Buy":
                emit_tick(sym, "bid", entry["price"], size, orderID, action)
            if entry["side"] == "Sell":
                emit_tick(sym, "ask", entry["price"], size, orderID, action)

def on_open(ws):
    logging.info(f"🚀 Subscribing to BitMEX quote feed...")
    ws.send(json.dumps({
        "op": "subscribe",
        "args": ["orderBookL2_25:XBTUSD", "orderBookL2_25:ETHUSD", "orderBookL2_25:SOLUSD"]
    }))

def on_error(ws, error):
    logging.info("❌ WebSocket error:", error)

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
