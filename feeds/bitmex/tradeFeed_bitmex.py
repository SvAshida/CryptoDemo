# feeds/bitmex/quoteFeed_bitmex.py

import websocket
import json
import logging
from kafka import KafkaProducer
import datetime
import os
import pathlib

SCRIPT_DIR = pathlib.Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR.parent.parent
LOG_DIR = PROJECT_ROOT / "logs"
LOG_DIR.mkdir(exist_ok=True)

log_file = LOG_DIR / "trade_producer_bitmex.log"

logging.basicConfig(
    filename=str(log_file),
    level=logging.INFO,
    format='%(asctime)s %(levelname)s: %(message)s'
)

producer = KafkaProducer(
    bootstrap_servers='kafka:9092',
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)

symbols = ["XBTUSD", "ETHUSD", "SOLUSD"]

def on_open(ws):
    logging.info("🔌 WebSocket connected")
    for sym in symbols:
        ws.send(json.dumps({"op": "subscribe", "args": [f"trade:{sym}"]}))
        logging.info(f"📡 Subscribed to trade:{sym}")

def on_message(ws, message):
    try:
        msg = json.loads(message)
        if isinstance(msg, dict) and msg.get("table") == "trade" and "data" in msg:
            for trade in msg["data"]:
                data = {
                    "time": datetime.datetime.now(datetime.UTC).isoformat(timespec="microseconds").replace("+00:00", "Z"),
                    "sym": trade["symbol"].replace("XBT", "BTC"),
                    "tradeID": trade["trdMatchID"],
                    "amount": trade["size"],
                    "price": trade["price"],
                    "side": trade["side"].lower(),
                    "exchange": "bitmex"
                }
                producer.send("bitmex.trades", value=data)
                logging.info(f"📈 {data}")
    except Exception as e:
        logging.error(f"❌ Error: {e}")


def on_error(ws, error):
    logging.error(f"❗ WebSocket error: {error}")

def on_close(ws, code, msg):
    logging.warning("❎ WebSocket connection closed")

# --- Main ---
if __name__ == "__main__":
    ws = websocket.WebSocketApp(
        "wss://www.bitmex.com/realtime",
        on_open=on_open,
        on_message=on_message,
        on_error=on_error,
        on_close=on_close
    )
    ws.run_forever()
