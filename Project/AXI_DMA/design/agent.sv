class agent;
    generator  gen; 
    driver     driv; 
    monitor    mon;
    
    mailbox #(transaction) gen2driv; 
    mailbox #(transaction) mon2scb;
    
    virtual axi_dma_if vif;

    function new(virtual axi_dma_if vif, mailbox #(transaction) mon2scb);
        this.vif = vif; 
        this.mon2scb = mon2scb; 
        
        gen2driv = new(); 
        gen  = new(gen2driv); 
        driv = new(vif, gen2driv); 
        mon  = new(vif, mon2scb);
    endfunction

    task run(); 
        fork 
            gen.run(); 
            driv.run(); 
            mon.run(); 
        join_any 
    endtask
endclass
