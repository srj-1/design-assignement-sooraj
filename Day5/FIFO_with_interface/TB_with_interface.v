
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.06.2026 19:27:14
// Design Name: 
// Module Name: FIFO_tb_inf
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
interface inf;

logic  clk,rst,wrenb,rdenb, full,empty;
logic [7:0]data_in,data_out;
 
endinterface

module FIFO_tb_inf();
inf intf1();
FIFO dut( intf1.clk,intf1.rst,intf1.wrenb,intf1.rdenb,intf1.data_in,intf1.data_out,intf1.full,intf1.empty);
always #5 intf1.clk=~intf1.clk;
initial begin
{intf1.clk,intf1.rst,intf1.wrenb,intf1.rdenb,intf1.data_in}=0;
 end 
 initial begin 
 
 intf1.rst = 1;
    #10;
   intf1.rst = 0;

    // Write data into FIFO
    intf1.wrenb = 1;

    intf1.data_in = 8'h11; #10;
    intf1.data_in = 8'h22; #10;
    intf1.data_in = 8'h33; #10;
    intf1.data_in= 8'h44; #10;

    intf1.wrenb  = 0;

    // Read data from FIFO
    #10;
   intf1.rdenb = 1;

    #10;
    #10;
    #10;
    #10;

    intf1.rdenb = 0;

 end
 



endmodule
