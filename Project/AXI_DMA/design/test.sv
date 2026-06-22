`timescale 1ns/1ps

class test;
    environment env;

    function new(virtual axi_dma_if vif);
        env = new(vif);
    endfunction

    // Explicitly flushes mailboxes and flags components to stop
    virtual function void clean_up();
        $display("[TEST_CLEANUP] Flushing verification environment components...");
        env.agt.mon.enable = 0;
        env.scb.enable     = 0;
        
        // Purge any residual transactions inside the generator to driver mailbox
        if (env.agt.gen2driv != null) begin
            transaction dummy;
            while (env.agt.gen2driv.num() > 0) begin
                void'(env.agt.gen2driv.try_get(dummy));
            end
        end
    endfunction

    virtual task run();
        // ISOLATION BLOCK: This prevents Vivado from killing the main TB thread
        fork
            begin
                env.run(); // Spawns background components (drivers, monitors)
                
                // VIVADO FIX: Use @(event) instead of wait(event.triggered)
                @(env.agt.gen.ended); 
                
                wait(env.agt.gen2driv.num() == 0);
                #100; 
            end
        join
        
        // VIVADO FIX: Placed here, this safely kills only the threads spawned by env.run()
        disable fork; 
        
        env.scb.print_stats();
        clean_up();
    endtask
endclass

class test_16bit_normal extends test;
    function new(virtual axi_dma_if vif);
        super.new(vif);
    endfunction

    virtual task run();
        $display("=================================================");
        $display("     TEST CASE 1: STARTING 16-BIT NORMAL RUN     ");
        $display("=================================================");
        env.agt.gen.transaction_count = 5; 
        env.agt.gen.force_mode        = 0;  
        env.agt.gen.force_size        = 16; 
        super.run(); 
    endtask
endclass

class test_scatter_gather extends test;
    function new(virtual axi_dma_if vif);
        super.new(vif);
    endfunction

    virtual task run();
        $display("=================================================");
        $display("     TEST CASE 2: STARTING SCATTER-GATHER RUN    ");
        $display("=================================================");
        env.agt.gen.transaction_count = 5; 
        env.agt.gen.force_mode        = 1;  
        env.agt.gen.force_size        = -1; 
        super.run(); 
    endtask
endclass

// Added missing randomized test class so the testbench loop works
class test_randomized extends test;
    function new(virtual axi_dma_if vif);
        super.new(vif);
    endfunction

    virtual task run();
        $display("=================================================");
        $display("     TEST CASE 3: STARTING RANDOMIZED RUN        ");
        $display("=================================================");
        env.agt.gen.transaction_count = 10; 
        env.agt.gen.force_mode        = -1; // Let generator randomize  
        env.agt.gen.force_size        = -1; // Let generator randomize
        super.run(); 
    endtask
endclass
