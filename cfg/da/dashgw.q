gw: hopen`:sggw:5040

queryData:{[tab;sd;ed;sym;exchange]
    args: (!) . flip (
        (`table   ; tab);
        (`startTS ; sd);
        (`endTS   ; ed);
        (`filter; enlist ("in";`sym;enlist sym));
        (`labels; (enlist`exchange)!enlist exchange)
        );
    if[null sym;args:`filter _ args];
    if[null exchange;args:`labels _ args];
    $[count last tab: gw(`.kxi.getData;args;`;(0#`)!());
        last tab;
        first tab]
    }

quoteByDaps:{[tab;sd;ed;sym]
    args: (!) . flip (
        (`table   ; tab);
        (`startTS ; sd);
        (`endTS   ; ed);
        (`sym; sym)
        );
    $[count last tab: gw(`.call.tableCountByDap;args;`;()!());
        last tab;
        first tab]
    }

queryLastBook:{[sym;exchange;depth]
    args: (!) . flip (
        (`table   ; `book);
        (`startTS ; .z.p-01:00);
        (`endTS   ; .z.p);
        (`sym; sym);
        (`depth;depth);
        (`labels; (enlist`exchange)!enlist exchange)
        );
        $[count last tab:gw(`.crypto.orderbook;args;`;()!());
            last tab;
            first tab]
    }

querySpread:{[sym;exchange]
    args: (!) . flip (
        (`table   ; `quote);
        (`startTS ; .z.p-01:00);
        (`endTS   ; .z.p);
        (`sym; sym);
        (`labels; (enlist`exchange)!enlist exchange)
        );
        $[count last tab:gw(`.crypto.getSpread;args;`;()!());
             last tab;
             first tab]
    }

queryMidPrice:{[sym;exchange]
    args: (!) . flip (
        (`table   ; `quote);
        (`startTS ; .z.p-1D);
        (`endTS   ; .z.p);
        (`sym; sym);
        (`labels; (enlist`exchange)!enlist exchange)
        );
        $[count last tab:gw(`.crypto.midPriceAgg;args;`;()!());
             last tab;
             first tab]
    }
    