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