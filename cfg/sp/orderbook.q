
// Logging on/off
.debug.logging:1b;

// Define book tables
book: ([]`s#time:"p"$();`g#sym:`$();bids:();bidsizes:();asks:();asksizes:();exchange:`$());
lastBookBySymExch: ([sym:`$();exchange:`$()]bidbook:();askbook:());
`lastBookBySymExch upsert (`;`;()!();()!());
//////////////////// Define Functions for Book

bookbuilder:{[x;y]
    .debug.xy:(x;y);
    $[not y 0;x;
        $[
            `insert=y 4;
                x,enlist[y 1]! enlist y 2 3;
            `update=y 4;
                $[any (y 1) in key x;
                    [
                        //update size
                        a:.[x;(y 1;1);:;y 3];
                        //update price if the price col is not null
                        $[0n<>y 2;.[a;(y 1;0);:;y 2];a]
                    ];
                    x,enlist[y 1]! enlist y 2 3
                ];  
            `remove=y 4;
                $[any (y 1) in key x;
                    enlist[y 1] _ x;
                    x];
            x
        ]
    ]
    };

///////////////////////////////////////////////
// Streams
book_stream: .qsp.read.fromStream[`quote]
  .qsp.map[{
        .debug.x:x;
        books:update bidbook:bookbuilder\[@[lastBookBySymExch;(first sym; first exchange)]`bidbook;flip (side like "bid";orderID;price;size;action)],askbook:bookbuilder\[@[lastBookBySymExch;(first sym; first exchange)]`askbook;flip (side like "ask";orderID;price;size;action)] by sym, exchange from x;
        lastBookBySymExch,:exec last bidbook,last askbook by sym, exchange from books;
        books:select time,sym,exchange,bids:(value each bidbook)[;;0],bidsizes:(value each bidbook)[;;1],asks:(value each askbook)[;;0],asksizes:(value each askbook)[;;1] from books;
        books:`time`sym`bids`bidsizes`asks`asksizes`exchange xcols update bids:desc each distinct each bids,bidsizes:{sum each x group y}'[bidsizes;bids] @' desc each distinct each bids,asks:asc each distinct each asks,asksizes:{sum each x group y}'[asksizes;asks] @' asc each distinct each asks from books
        }]
  .qsp.write.toStream[`book]

// Start the pipeline
.qsp.run (book_stream)