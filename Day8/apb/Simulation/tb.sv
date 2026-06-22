`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.06.2026 12:40:59
// Design Name: 
// Module Name: tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


class apb_transaction;
  rand bit [31:0] addr;
  rand bit [31:0] wdata;
  rand bit        write;
  bit [31:0]      rdata;

  constraint c_addr { 
    addr[1:0] == 2'b00;       
    addr >= 32'h0000_0000;    
    addr <= 32'h0000_03FC;    
  } 
endclass

typedef mailbox #(apb_transaction) apb_mbx;


class generator;
  apb_mbx gen2drv; 
  int num_pairs = 10; 

  function new(apb_mbx gen2drv);
    this.gen2drv = gen2drv;
  endfunction

  task main();
    repeat(num_pairs) begin
      apb_transaction tr_write = new();
      apb_transaction tr_read  = new();
      
      if (!tr_write.randomize() with { write == 1'b1; }) 
        $fatal(1, "Randomization failed");
      gen2drv.put(tr_write);
      
      if (!tr_read.randomize() with { write == 1'b0; }) 
        $fatal(1, "Randomization failed");
      tr_read.addr = tr_write.addr; 
      gen2drv.put(tr_read);
    end
  endtask
endclass

class driver;
  virtual apb_if vif;
  apb_mbx gen2drv;
  
  function new(virtual apb_if vif, apb_mbx gen2drv);
    this.vif = vif;
    this.gen2drv = gen2drv;
  endfunction
  
  task main();
    vif.paddr   <= 32'h0;
    vif.pwrite  <= 1'b0;
    vif.pwdata  <= 32'h0;
    vif.psel    <= 1'b0;
    vif.penable <= 1'b0;
    
    @(posedge vif.clk);
    while(!vif.rst_n) @(posedge vif.clk);
    
    forever begin
      apb_transaction tr;
      gen2drv.get(tr);
      
      vif.paddr   <= tr.addr;
      vif.pwrite  <= tr.write;
      vif.pwdata  <= tr.wdata;
      vif.psel    <= 1'b1;
      vif.penable <= 1'b0;
      
      @(posedge vif.clk);
      vif.penable <= 1'b1;
      
      @(posedge vif.clk);
      while (!vif.pready) @(posedge vif.clk);
      
      if (!tr.write) tr.rdata = vif.prdata;
      
      vif.psel    <= 1'b0;
      vif.penable <= 1'b0;
      vif.pwrite  <= 1'b0;
      @(posedge vif.clk); 
    end
  endtask
endclass


class monitor;
  virtual apb_if vif;
  apb_mbx mon2scb;
  
  function new(virtual apb_if vif, mailbox #(apb_transaction) mon2scb);
    this.vif = vif;
    this.mon2scb = mon2scb;
  endfunction
  
  task main();
    forever begin
      @(posedge vif.clk);
      #1; 
      if (vif.psel && vif.penable && vif.pready) begin
        apb_transaction tr = new();
        tr.addr  = vif.paddr;
        tr.write = vif.pwrite;
        if (vif.pwrite) begin
          tr.wdata = vif.pwdata;
        end else begin
          @(posedge vif.clk);
          #1;
          tr.rdata = vif.prdata;
        end
        mon2scb.put(tr);
      end
    end
  endtask
endclass

class scoreboard;
  apb_mbx mon2scb;
  bit [31:0] internal_mem [bit [31:0]];
  
  function new(apb_mbx mon2scb);
    this.mon2scb = mon2scb;
  endfunction
  
  task main();
    forever begin
      apb_transaction tr;
      mon2scb.get(tr);
      if (tr.write) begin
        internal_mem[tr.addr] = tr.wdata;
        $display("[SCB] WRITE: Addr=0x%0h, Data=0x%0h", tr.addr, tr.wdata);
      end else begin
        $display("[SCB] READ : Addr=0x%0h", tr.addr);
        if (internal_mem.exists(tr.addr)) begin
          if (internal_mem[tr.addr] == tr.rdata)
            $display("[SCB] MATCH: Expected=0x%0h, Got=0x%0h (SUCCESS)\n", internal_mem[tr.addr], tr.rdata);
          else
            $error("[SCB] MISMATCH: Expected=0x%0h, Got=0x%0h (FAIL)\n", internal_mem[tr.addr], tr.rdata);
        end else begin
          $display("[SCB] WARNING: Read from uninitialized Addr=0x%0h\n", tr.addr);
        end
      end
    end
  endtask
endclass

class environment;
  generator  gen;
  driver     drv;
  monitor    mon;
  scoreboard scb;
  apb_mbx gen2drv; 
  apb_mbx mon2scb; 
  
  virtual apb_if vif;
  
  function new(virtual apb_if vif);
    this.vif = vif;
    gen2drv = new();
    mon2scb = new();
    gen = new(gen2drv);
    drv = new(vif, gen2drv);
    mon = new(vif, mon2scb);
    scb = new(mon2scb);
  endfunction
  
  task run();
    fork
      gen.main();
      drv.main();
      mon.main();
      scb.main();
    join_any
  endtask
endclass


module tb;
  reg clk;
  
  apb_if vif(clk);
  
  top dut (
    .clk    (clk),
    .rst_n  (vif.rst_n),
    .paddr  (vif.paddr),
    .psel   (vif.psel),
    .penable(vif.penable),
    .pwrite (vif.pwrite),
    .pwdata (vif.pwdata),
    .prdata (vif.prdata),
    .pready (vif.pready)
  );

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    vif.rst_n = 0;
    #20 vif.rst_n = 1;
  end

  environment env;

  initial begin
    env = new(vif);
    #40;
    env.run();
    #800; 
    $display("Testbench complete. Ending simulation.");
    $finish;
  end
endmodule
