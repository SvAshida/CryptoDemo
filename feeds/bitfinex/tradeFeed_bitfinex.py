import websocket
import json
from kafka import KafkaProducer
import datetime
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

symbols = ["tBTCUSD", "tETHUSD", "tSOLUSD"]
chan_map = {}

def on_open(ws):
    for sym in symbols:
        ws.send(json.dumps({
            "event": "subscribe",
            "channel": "trades",
            "symbol": sym
        }))

def on_message(ws, message):
    try:
        msg = json.loads(message)
        if isinstance(msg, dict) and msg.get("event") == "subscribed":
            chan_map[msg["chanId"]] = msg["symbol"]
            logging.info(f"✅ Subscribed to {msg.get("symbol")} on channel {msg.get("chanId")}")
        elif isinstance(msg, list) and msg[1] == "te":  # trade execution
            chan_id, _, trade = msg
            sym = chan_map.get(chan_id, "UNKNOWN")
            data = {
                "time": datetime.datetime.now(datetime.UTC).isoformat(timespec="microseconds").replace("+00:00", "Z"),
                "sym": sym.replace("t", ""),  # remove 't'
                "tradeID": trade[0],
                "amount": abs(trade[2]),
                "price": trade[3],
                "side": "buy" if trade[2] > 0 else "sell",
                "exchange": "bitfinex"
            }
            producer.send("bitfinex.trades", value=data)
    except Exception as e:
        logging.info(f"Error: {e}")

def on_error(ws, error):
    logging.info(f"WebSocket error: {error}")

def on_close(ws, close_status_code, close_msg):
    logging.info("WebSocket closed.")

if __name__ == "__main__":
    websocket.WebSocketApp(
        "wss://api-pub.bitfinex.com/ws/2",
        on_open=on_open,
        on_message=on_message,
        on_error=on_error,
        on_close=on_close
    ).run_forever()
