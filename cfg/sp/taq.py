from kxi import sp # type: ignore
import pykx as kx
import numpy as np
import pandas as pd 
import datetime

tp_hostport = ':tp:5010'
binance_trade_topic = 'binance.trades'
binance_quote_topic = 'binance.quotes'
kfk_broker  = 'kafka:9092'

def transform_dict_to_table(d):     ## transform dictionary to table object
    return kx.q.enlist(d)

def safe_float(val):
    try:
        return float(str(val).rstrip('f'))  # strip trailing 'f' if present
    except Exception:
        return 0.0  # or use None or kx.q("0n") if you prefer null handling
    
def keep_every_nth(n): ##only keep every 10th record
    count = {"i": 0}
    def filter_fn(row):
        count["i"] += 1
        return count["i"] % n == 0
    return filter_fn

def transform_trade_table_types(tab):
    tab["time"] = [
        kx.TimestampAtom(datetime.datetime.fromisoformat(str(t).replace("Z", "+00:00")))
        if not isinstance(t, kx.TimestampAtom) else t
        for t in tab["time"]
    ]
    tab["sym"] = kx.SymbolVector([str(s) for s in tab["sym"]])
    tab["price"] = kx.FloatVector([safe_float(str(p)) for p in tab["price"]])
    tab["size"] = kx.FloatVector([safe_float(str(s)) for s in tab["size"]])
    tab["tradeID"] = kx.LongVector([int(t) for t in tab["tradeID"]])
    
    return tab

def transform_quote_table_types(tab):
    tab["time"] = [
        kx.TimestampAtom(datetime.datetime.fromisoformat(str(t).replace("Z", "+00:00")))
        if not isinstance(t, kx.TimestampAtom) else t
        for t in tab["time"]
    ]
    tab["sym"] = kx.SymbolVector([str(s) for s in tab["sym"]])
    tab["bid"] = kx.FloatVector([safe_float(b) for b in tab["bid"]])
    tab["bidSize"] = kx.FloatVector([safe_float(bq) for bq in tab["bidSize"]])
    tab["ask"] = kx.FloatVector([safe_float(a) for a in tab["ask"]])
    tab["askSize"] = kx.FloatVector([safe_float(aq) for aq in tab["askSize"]])
    
    return tab

trade_source = (sp.read.from_kafka(topic=binance_trade_topic, brokers=kfk_broker)
    | sp.decode.json()
    | sp.filter(keep_every_nth(10), name="filter every 10th trade")
    | sp.map(transform_dict_to_table, name='transform trade')
    | sp.map(transform_trade_table_types))

trade_pipeline = (trade_source
    | sp.map(lambda x: ('trade', x), name="debug: Trade batch print")
    | sp.write.to_process(handle=tp_hostport, mode='function', target='.u.upd', spread=True))

quote_source = (sp.read.from_kafka(topic=binance_quote_topic, brokers=kfk_broker)
    | sp.decode.json()
    | sp.filter(keep_every_nth(20), name="filter every 10th quote")
    | sp.map(transform_dict_to_table, name='transform quote')
    | sp.map(transform_quote_table_types)
    | sp.map(lambda x: (print("📦 Typed Row:", x) or x), name="debug: typed row"))

quote_pipeline = (quote_source
    | sp.map(lambda x: ('quote', x), name="debug: Quote batch print")
    | sp.write.to_process(handle=tp_hostport, mode='function', target='.u.upd', spread=True))

sp.run(trade_pipeline,quote_pipeline)