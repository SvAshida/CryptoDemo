import websocket
import json
import datetime
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

# List of symbols to subscribe to
symbols = ["tBTCUSD", "tETHUSD", "tSOLUSD","tXRPUSD"]
# Map Bitfinex channel IDs to symbols
channel_map = {}

def on_message(ws, message):
    msg = json.loads(message)
    if isinstance(msg, dict):
        if msg.get("event") == "subscribed" and msg.get("channel") == "book":
            chan_id = msg["chanId"]
            symbol = msg["symbol"]
            channel_map[chan_id] = symbol
            logging.info(f"✅ Subscribed: {symbol} (chanId={chan_id})")
        return

    if isinstance(msg, list):
        chan_id = msg[0]

        sym = channel_map.get(chan_id)
        if not sym or not isinstance(msg[1], list):
            return

        # Snapshot
        if isinstance(msg[1][0], list):
            for entry in msg[1]:
                emit_tick(sym, entry)
        # Update
        else:
            emit_tick(sym, msg[1])

def emit_tick(sym, entry):
    order_id, price, amount = entry
    side = "bid" if amount > 0 else "ask"
    action = "remove" if amount == 0 or price == 0 else "update"
    message = {
        "time": datetime.datetime.now(datetime.UTC).isoformat(timespec="microseconds").replace("+00:00", "Z"),
        "sym": sym[1:],  # Remove 't' prefix, e.g., BTCUSD
        "side": side,
        "price": price,
        "size": abs(amount),
        "action": action,
        "orderID": str(order_id),
        "exchange": "bitfinex"
    }
    producer.send("bitfinex.quotes", value=message)

def on_open(ws):
    for s in symbols:
        ws.send(json.dumps({
            "event": "subscribe",
            "channel": "book",
            "symbol": s,
            "prec": "R0",
            "freq": "F0"
        }))

def on_error(ws, error):
    logging.info("❌ Error:", error)

def on_close(ws, code, msg):
    logging.info("🔌 Closed:", code, msg)

if __name__ == "__main__":
    websocket.WebSocketApp(
        "wss://api-pub.bitfinex.com/ws/2",
        on_open=on_open,
        on_message=on_message,
        on_error=on_error,
        on_close=on_close
    ).run_forever()
