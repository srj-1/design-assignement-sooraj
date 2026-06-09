`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.06.2026 16:10:02
// Design Name: 
// Module Name: sr_flipflop_tb
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


module sr_flipflop_tb();
reg s_tb;
reg r_tb;
reg rst_tb;
reg clk_tb;
wire q_tb;
wire qbar_tb;

sr_flipflop dut (
    .s(s_tb),
    .r(r_tb),
    .rst(rst_tb),
    .clk(clk_tb),
    .q(q_tb),
    .qbar(qbar_tb)
);

initial
begin
    clk_tb = 0;
    forever #5 clk_tb = ~clk_tb;
end

initial
begin
    s_tb = 0;
    r_tb = 0;
    rst_tb = 1;

    #10;
    rst_tb = 0;

    s_tb = 1;
    r_tb = 0;
    #10;

    s_tb = 0;
    r_tb = 0;
    #10;

    s_tb = 0;
    r_tb = 1;
    #10;

    s_tb = 0;
    r_tb = 0;
    #10;

    s_tb = 1;
    r_tb = 1;
    #10;

    $finish;
end

initial
begin
    $monitor("Time=%0t clk=%b rst=%b s=%b r=%b q=%b qbar=%b",
             $time, clk_tb, rst_tb, s_tb, r_tb, q_tb, qbar_tb);
end
endmodule

