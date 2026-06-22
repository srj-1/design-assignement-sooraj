class driver;
    virtual axi_dma_if vif;
    mailbox #(transaction) gen2driv;

    function new(virtual axi_dma_if vif, mailbox #(transaction) gen2driv);
        this.vif = vif;
        this.gen2driv = gen2driv;
    endfunction

    task run();
        transaction trans;
        
        vif.DMA_EN = 1'b0;
        vif.DMA_GO = 1'b0;
        vif.SG_MODE = 1'b0;
        
        forever begin
            gen2driv.get(trans);
            @(posedge vif.ACLK);
            
            if (trans.sg_mode == 1'b0) begin
                $display("[DRIVER] Driving Normal DMA: SRC=%0h, DST=%0h, BYTES=%0d", trans.src_addr, trans.dest_addr, trans.transfer_bytes);
                vif.SG_MODE   <= 1'b0;
                vif.DMA_SRC   <= trans.src_addr;
                vif.DMA_DST   <= trans.dest_addr;
                vif.DMA_BNUM  <= trans.transfer_bytes;
                vif.DMA_CHUNK <= trans.chunk_size;
                vif.DMA_EN    <= 1'b1;
                
                @(posedge vif.ACLK);
                vif.DMA_GO    <= 1'b1;
                @(posedge vif.ACLK);
                vif.DMA_GO    <= 1'b0;
                
                wait(vif.DMA_DONE == 1'b1);
                $display("[DRIVER] Normal DMA Transfer Complete.");
            end else begin
                $display("[DRIVER] Driving Scatter-Gather DMA: DESC_ADDR=%0h", trans.sg_desc_addr);
                vif.SG_MODE      <= 1'b1;
                vif.SG_DESC_ADDR <= trans.sg_desc_addr;
                vif.DMA_EN       <= 1'b1;
                
                @(posedge vif.ACLK);
                vif.DMA_GO       <= 1'b1;
                @(posedge vif.ACLK);
                vif.DMA_GO       <= 1'b0;
                
                wait(vif.SG_DONE == 1'b1);
                $display("[DRIVER] Scatter-Gather Transfer Complete.");
            end
            
            repeat(10) @(posedge vif.ACLK);
        end
    endtask
endclass
