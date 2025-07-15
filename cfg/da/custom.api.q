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

.call.simple:{[table;startTS;endTS;sym]
    show "Starting .custom.simple from ",string .da.i.dapType;
    wc:enlist(in;`sym;enlist sym);
    res:.kxi.selectTable[table;(startTS;endTS);wc;0b;.kxasm.colNames[table];()];
    res:update dap:.da.i.dapType from res;
    show 5 sublist res;
    res
    }


.da.registerAPI[`.call.simple;
    .sapi.metaDescription["Simple Call of Table"],
    .sapi.metaParam[`name`type`isReq`description!(`table;-11h;1b;"Table Name")],
    .sapi.metaParam[`name`type`isReq`description!(`startTS;-12h;1b;"start time")],
    .sapi.metaParam[`name`type`isReq`description!(`endTS;-12h;1b;"end time")],
    .sapi.metaParam[`name`type`isReq`description!(`sym;desc -11 11h;1b;"sym")],
    .sapi.metaReturn[`type`description!(98h;"Result of the call")],
    .sapi.metaMisc[enlist[`safe]!enlist 1b]
    ]

.call.tableCountByDap:{[table;startTS;endTS;sym]
    show "Starting .call.tableCountByDap from ",string .da.i.dapType;
    wc:$[null sym;();wc:enlist(in;`sym;enlist sym)];
    aggClause:(enlist`x)!enlist(count;`i);
     args:$[.da.i.dapType=`HDB;
         `table`startTS`endTS`filter`groupBy`agg!((table);startTS;endTS;wc;(`date`exchange`sym)!`date`exchange`sym;(enlist`x)!enlist(count;`i));
         `table`startTS`endTS`filter`groupBy`agg!((table);startTS;endTS;wc;(`exchange`sym)!`exchange`sym;(enlist`x)!enlist(count;`i))
         ];
    //args:`table`startTS`endTS`filter`groupBy`agg!((table);startTS;endTS;enlist(in;`sym;enlist sym);0b;(enlist`x)!enlist(count;`i));
    res:.kxi.selectTable args;
    show 5 sublist res;
    res:update dap:.da.i.dapType from res;
    if[not `HDB in first res`dap;
        res:update date:.z.d from res];
    show 5 sublist res;
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


.call.brokenCall:{[table;startTS;endTS;sym]
    show "Starting .call.brokenCall from ",string .da.i.dapType;
    wc:enlist(in;`sym;enlist sym);
    tabCols:`dap`exchange!`dap`exchange;
    aggClause:(enlist`x)!enlist(count;`i);
    args:`table`startTS`endTS`filter`groupBy`agg!((table);startTS;endTS;wc;(enlist`timehh)!enlist(xbar;0D01:00:00;time);(enlist`x)!enlist(count;`i));
    res:.kxi.selectTable args;
    res:update dap:.da.i.dapType from res;
    res:update date:?[dap=`HDB;date;.z.d] from res;
    show 5 sublist res;
    res
    }


.da.registerAPI[`.call.brokenCall;
    .sapi.metaDescription["Get table count by DAP"],
    .sapi.metaParam[`name`type`isReq`description!(`table;-11h;1b;"Table Name")],
    .sapi.metaParam[`name`type`isReq`description!(`startTS;-12h;1b;"start time")],
    .sapi.metaParam[`name`type`isReq`description!(`endTS;-12h;1b;"end time")],
    .sapi.metaParam[`name`type`isReq`description!(`sym;desc -11 11h;1b;"sym")],
    .sapi.metaReturn[`type`description!(98h;"Result of the call")],
    .sapi.metaMisc[enlist[`safe]!enlist 1b]
    ]