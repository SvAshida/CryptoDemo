gw:hopen `:sggw:5040;

queryData:{[tab;sd;ed;sym;exchange]
    elements:`table`startTS`endTS`filter`labels;
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