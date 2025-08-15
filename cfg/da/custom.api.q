// Sample DA custom file.

// Can load other files within this file. Note that the current directory
// is the directory of this file (in this example: /opt/kx/custom).
/ \l subFolder/otherFile1.q
/ \l subFolder/otherFile2.q



.join.simple:{[startTS;endTS;sym]
    show "Starting .custom.simple from ",string .da.i.dapType;
    wc:enlist(in;`sym;enlist sym);
    res:.kxi.selectTable[`trade;(startTS;endTS);wc;0b;.kxasm.colNames[`trade];()];
    res2:.kxi.selectTable[`quote;(startTS;endTS);wc;0b;.kxasm.colNames[`quote];()];
    aj[`time;res;res2];
    res:update dap:.da.i.dapType from res;
    
    show 5 sublist res;
    res
    }


.da.registerAPI[`.join.simple;
    .sapi.metaDescription["Simple Asof Join on Quote and Trade"],
    .sapi.metaParam[`name`type`isReq`description!(`startTS;-12h;1b;"start time")],
    .sapi.metaParam[`name`type`isReq`description!(`endTS;-12h;1b;"end time")],
    .sapi.metaParam[`name`type`isReq`description!(`sym;desc -11 11h;1b;"sym")],
    .sapi.metaReturn[`type`description!(98h;"Joined table of Quote and Trade")],
    .sapi.metaMisc[enlist[`safe]!enlist 1b]
    ]

.call.tableCountByDap:{[table;startTS;endTS;sym]
    show "Starting .call.tableCountByDap from ",string .da.i.dapType;
    wc:$[null sym;();enlist(in;`sym;enlist sym)];
    args:$[.da.i.dapType=`HDB;
        `table`startTS`endTS`filter`groupBy`agg!((table);startTS;endTS;wc;(`date`exchange`sym)!`date`exchange`sym;(enlist`x)!enlist(count;`i));
        `table`startTS`endTS`filter`groupBy`agg!((table);startTS;endTS;wc;(`exchange`sym)!`exchange`sym;(enlist`x)!enlist(count;`i))
        ];
    res:.kxi.selectTable args;
    res:update dap:.da.i.dapType from res;
    if[not `HDB in first res`dap;
        res:update date:.z.d from res];
    4! `exchange`sym`dap`date`x xcols 0! res
    }


.da.registerAPI[`.call.tableCountByDap;
    .sapi.metaDescription["Get table count by DAP"],
    .sapi.metaParam[`name`type`isReq`description!(`table;-11h;1b;"Table Name")],
    .sapi.metaParam[`name`type`isReq`description!(`startTS;-12h;1b;"start time")],
    .sapi.metaParam[`name`type`isReq`description!(`endTS;-12h;1b;"end time")],
    .sapi.metaParam[`name`type`isReq`description!(`sym;desc -11 11h;1b;"sym")],
    .sapi.metaReturn[`type`description!(98h;"Result of the call")],
    .sapi.metaMisc[enlist[`safe]!enlist 1b]
    ]


.crypto.getSpread:{[table;startTS;endTS;sym]
    show "Starting .call.brokenCall from ",string .da.i.dapType;
    wc:{((in;`sym;enlist x);(in;`side;enlist y);(in;`action;enlist`update))}[sym;]each (`ask`bid);
    bidArgs:`table`startTS`endTS`filter`groupBy`agg!((table);startTS;endTS;last wc;(enlist`bucketTime)!enlist(xbar;0D00:01:00;`time);(`avgBid`sym)!((avg;`price);(first;`sym)));
    askArgs:`table`startTS`endTS`filter`groupBy`agg!((table);startTS;endTS;first wc;(enlist`bucketTime)!enlist(xbar;0D00:01:00;`time);(`avgAsk`sym)!((avg;`price);(first;`sym)));
    res1:.kxi.selectTable bidArgs;
    res2:.kxi.selectTable askArgs;
    select bucketTime, spread:avgAsk-avgBid from aj[`sym`bucketTime;res1;res2]
    }


.da.registerAPI[`.crypto.getSpread;
    .sapi.metaDescription["Get table count by DAP"],
    .sapi.metaParam[`name`type`isReq`description!(`table;-11h;1b;"Table Name")],
    .sapi.metaParam[`name`type`isReq`description!(`startTS;-12h;1b;"start time")],
    .sapi.metaParam[`name`type`isReq`description!(`endTS;-12h;1b;"end time")],
    .sapi.metaParam[`name`type`isReq`description!(`sym;desc -11 11h;1b;"sym")],
    .sapi.metaReturn[`type`description!(98h;"Result of the call")],
    .sapi.metaMisc[enlist[`safe]!enlist 1b]
    ]

.crypto.orderbook:{[table;startTS;endTS;sym;depth]
    show "Starting .crypto.orderbook from ",string .da.i.dapType;
    if[depth < 5; depth:5];
    wc:enlist(in;`sym;enlist sym);
    args:`table`startTS`endTS`filter!((table);startTS;endTS;wc);
    res:.kxi.selectTable args;
    res1Count:count res1:update x:i from ungroup select sym,bids,bidsizes from enlist last res;
    res2Count:count res2:update x:i from ungroup select sym,asks,asksizes from enlist last res;
    res:$[res2Count>res1Count;
        res2 lj `x xkey res1;
        res1 lj `x xkey res2];
    res:update time:.z.p from min[(count res;depth)]#res;
    res
    }


.da.registerAPI[`.crypto.orderbook;
    .sapi.metaDescription["Return last book level"],
    .sapi.metaParam[`name`type`isReq`description!(`table;-11h;1b;"Table Name")],
    .sapi.metaParam[`name`type`isReq`description!(`startTS;-12h;1b;"start time")],
    .sapi.metaParam[`name`type`isReq`description!(`endTS;-12h;1b;"end time")],
    .sapi.metaParam[`name`type`isReq`description!(`sym;desc -11 11h;1b;"sym")],
    .sapi.metaParam[`name`type`isReq`description!(`depth;-7h;1b;"depth to view")],
    .sapi.metaReturn[`type`description!(98h;"Result of the call")],
    .sapi.metaMisc[enlist[`safe]!enlist 1b]
    ]

.crypto.midPriceAgg:{[table;startTS;endTS;sym]
    show "Starting .crypto.midPriceAgg from ",string .da.i.dapType;
    wc:{((in;`sym;enlist x);(in;`side;enlist y);(in;`action;enlist`update))}[sym;]each (`ask`bid);
    bidArgs:`table`startTS`endTS`filter`groupBy`agg!((table);startTS;endTS;last wc;(enlist`bucketTime)!enlist(xbar;0D00:01:00;`time);(`avgBid`sym)!((avg;`price);(first;`sym)));
    askArgs:`table`startTS`endTS`filter`groupBy`agg!((table);startTS;endTS;first wc;(enlist`bucketTime)!enlist(xbar;0D00:01:00;`time);(`avgAsk`sym)!((avg;`price);(first;`sym)));
    res1:.kxi.selectTable bidArgs;
    res2:.kxi.selectTable askArgs;
    select bucketTime, midPrice:avg(avgAsk;avgBid) from aj[`sym`bucketTime;res1;res2]
    }


.da.registerAPI[`.crypto.midPriceAgg;
    .sapi.metaDescription["Get bucketed mid price by minute"],
    .sapi.metaParam[`name`type`isReq`description!(`table;-11h;1b;"Table Name")],
    .sapi.metaParam[`name`type`isReq`description!(`startTS;-12h;1b;"start time")],
    .sapi.metaParam[`name`type`isReq`description!(`endTS;-12h;1b;"end time")],
    .sapi.metaParam[`name`type`isReq`description!(`sym;desc -11 11h;1b;"sym")],
    .sapi.metaReturn[`type`description!(98h;"Result of the call")],
    .sapi.metaMisc[enlist[`safe]!enlist 1b]
    ]

.crypto.vwapCalc:{[table;startTS;endTS;sym]
    show "Starting .crypto.vwapCalc from ",string .da.i.dapType;
    vwap_depth::{$[any z<=s:sums x;(deltas z & s) wavg y;0nf]};
    show vwap_depth;
    wc:enlist(in;`sym;enlist sym);
    aggClause:(!) . flip(
        (`time;(first;`time));
        (`vwap_bid_1;(avg;((';`vwap_depth);`bidsizes;`bids;1)));
        (`vwap_bid_100;(avg;((';`vwap_depth);`bidsizes;`bids;100)));
        (`vwap_bid_10000;(avg;((';`vwap_depth);`bidsizes;`bids;10000)));
        (`vwap_bid_1000000;(avg;((';`vwap_depth);`bidsizes;`bids;1000000)));
        (`vwap_ask_1;(avg;((';`vwap_depth);`asksizes;`asks;1)));
        (`vwap_ask_100;(avg;((';`vwap_depth);`asksizes;`asks;100)));
        (`vwap_ask_10000;(avg;((';`vwap_depth);`asksizes;`asks;10000)));
        (`vwap_ask_1000000;(avg;((';`vwap_depth);`asksizes;`asks;1000000)))
        );
    args:`table`startTS`endTS`filter`groupBy`agg!((table);startTS;endTS;wc;(enlist`bucketTime)!enlist(xbar;0D00:00:01;`time);aggClause);
    show args;
    //args:`table`startTS`endTS`filter`groupBy`agg!((table);startTS;endTS;wc;0b;()!());
    res:.kxi.selectTable args;
    delete bucketTime from res
    }


.da.registerAPI[`.crypto.vwapCalc;
    .sapi.metaDescription["Calculate VWAP Depth"],
    .sapi.metaParam[`name`type`isReq`description!(`table;-11h;1b;"Table Name")],
    .sapi.metaParam[`name`type`isReq`description!(`startTS;-12h;1b;"start time")],
    .sapi.metaParam[`name`type`isReq`description!(`endTS;-12h;1b;"end time")],
    .sapi.metaParam[`name`type`isReq`description!(`sym;desc -11 11h;1b;"sym")],
    .sapi.metaReturn[`type`description!(98h;"Result of the call")],
    .sapi.metaMisc[enlist[`safe]!enlist 1b]
    ]
