class monitor;
    virtual axi_dma_if vif;
    mailbox #(transaction) mon2scb;
    
    function new(virtual axi_dma_if vif, mailbox #(transaction) mon2scb);
        this.vif = vif;
        this.mon2scb = mon2scb;
    endfunction

    task run();
        transaction dummy_t = new(); 
        forever begin
            @(posedge vif.ACLK);
            if (vif.M_AWVALID && vif.M_AWREADY && vif.M_WVALID && vif.M_WREADY) begin
                mon2scb.put(dummy_t); 
            end
        end
    endtask
endclass
