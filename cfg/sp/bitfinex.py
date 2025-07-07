from kxi import sp # type: ignore
import pykx as kx
import numpy as np
import pandas as pd 
import datetime

bitfinex_quote_topic = 'bitfinex.quotes'
bitfinex_trade_topic = 'bitfinex.trades'
kfk_broker  = 'kafka:9092'

def logging_func(data):
    print(data)
    return data

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

def transform_quote_table_types(tab):
    tab["time"] = [
        kx.TimestampAtom(datetime.datetime.fromisoformat(str(t).replace("Z", "+00:00")))
        if not isinstance(t, kx.TimestampAtom) else t
        for t in tab["time"]
    ]
    tab["sym"] = kx.SymbolVector([str(s) for s in tab["sym"]])
    tab["side"] = kx.SymbolVector([str(s) for s in tab["side"]])
    tab["price"] = kx.FloatVector([safe_float(str(p)) for p in tab["price"]])
    tab["size"] = kx.FloatVector([safe_float(str(s)) for s in tab["size"]])
    tab["action"] = kx.SymbolVector([str(s) for s in tab["action"]])
    tab["exchange"] = kx.SymbolVector([str(s) for s in tab["exchange"]])

    return tab

def transform_trade_table_types(tab):
    tab["time"] = [
        kx.TimestampAtom(datetime.datetime.fromisoformat(str(t).replace("Z", "+00:00")))
        if not isinstance(t, kx.TimestampAtom) else t
        for t in tab["time"]
    ]
    tab["sym"] = kx.SymbolVector([str(s) for s in tab["sym"]])
    tab["tradeID"] = kx.q.string(tab["tradeID"])
    tab["amount"] = kx.FloatVector([
        a * p for a, p in zip(tab["amount"], tab["price"])
        ])
    tab["price"] = kx.FloatVector([safe_float(str(p)) for p in tab["price"]])
    tab["side"] = kx.SymbolVector([str(s) for s in tab["side"]])
    tab["exchange"] = kx.SymbolVector([str(s) for s in tab["exchange"]])

    return tab

quote_source = (sp.read.from_kafka(topic=bitfinex_quote_topic, brokers=kfk_broker)
    | sp.decode.json()
    | sp.map(transform_dict_to_table, name='transform quote')
    | sp.map(transform_quote_table_types)
    #| sp.map(lambda x: (print("📦 Typed Row:", x) or x), name="debug: typed row")
    )

quote_pipeline = (quote_source
    #| sp.map(lambda x: ('quote', x), name="debug: Quote batch print")
    #| sp.write.to_process(handle=tp_hostport, mode='function', target='.u.upd', spread=True))
    | sp.write.to_stream('quote')
    )

trade_source = (sp.read.from_kafka(topic=bitfinex_trade_topic, brokers=kfk_broker)
    | sp.decode.json()
    | sp.map(transform_dict_to_table, name='transform trade')
    | sp.map(transform_trade_table_types)
    #| sp.map(lambda x: (print("📦 Typed Row:", x) or x), name="debug: typed row")
    )

trade_pipeline = (trade_source
    #| sp.map(lambda x: ('quote', x), name="debug: Quote batch print")
    #| sp.write.to_process(handle=tp_hostport, mode='function', target='.u.upd', spread=True))
    | sp.map(logging_func)
    | sp.write.to_stream('trade')
    )

sp.run(quote_pipeline,trade_pipeline)