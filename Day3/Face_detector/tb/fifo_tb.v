`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2026 16:50:07
// Design Name: 
// Module Name: FIFO_tb
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


module FIFO_tb();

reg clk_tb;
reg rst_tb;
reg wrenb_tb;
reg rdenb_tb;
reg [7:0] data_in_tb;

wire [7:0] data_out_tb;
wire full_tb;
wire empty_tb;

FIFO dut(clk_tb,rst_tb,wrenb_tb,rdenb_tb,data_in_tb,data_out_tb,full_tb,empty_tb);
   

always #5 clk_tb = ~clk_tb;

initial
begin
    clk_tb = 0;
    rst_tb = 1;
    wrenb_tb = 0;
    rdenb_tb = 0;
    data_in_tb = 0;

    #10;
    rst_tb = 0;

    // Write data
    wrenb_tb = 1;
    data_in_tb = 8'h11; #10;
    data_in_tb = 8'h22; #10;
    data_in_tb = 8'h33; #10;
    data_in_tb = 8'h44; #10;

    wrenb_tb = 0;

    // Read data
    #10;
    rdenb_tb = 1;

    #10;
    #10;
    #10;
    #10;

    rdenb_tb = 0;

    // Write more data
    #10;
    wrenb_tb = 1;
    data_in_tb = 8'hAA; #10;
    data_in_tb = 8'hBB; #10;

    wrenb_tb = 0;

    // Read again
    #10;
    rdenb_tb = 1;
    #20;
    rdenb_tb = 0;

    
end

endmodule
