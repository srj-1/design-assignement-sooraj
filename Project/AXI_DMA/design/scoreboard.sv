class scoreboard;
    mailbox #(transaction) mon2scb;
    int total_valid_writes = 0;

    function new(mailbox #(transaction) mon2scb);
        this.mon2scb = mon2scb;
    endfunction

    task run();
        transaction trans;
        forever begin
            mon2scb.get(trans);
            total_valid_writes++;
        end
    endtask
    
    function void print_stats();
        $display("-------------------------------------------------");
        $display("[SCOREBOARD] Total Valid AXI Writes to Memory: %0d", total_valid_writes);
        $display("-------------------------------------------------");
    endfunction
endclass
