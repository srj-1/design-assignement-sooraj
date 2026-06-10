`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2026 21:24:58
// Design Name: 
// Module Name: TOP_tb
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




module TOP_tb();

reg clk_tb;
reg rst_tb;
reg [7:0] s_in_tb;

wire [7:0] d_out_tb;

TOP dut(clk_tb,rst_tb,s_in_tb,d_out_tb);

// Clock Generation
initial
begin
    clk_tb = 0;
end

always #5 clk_tb = ~clk_tb;

// Stimulus
initial
begin
    rst_tb = 1;
    s_in_tb = 8'h00;

    #10;
    rst_tb = 0;

    #10 s_in_tb = 8'hA5;   // 10100101
    #10 s_in_tb = 8'h3C;   // 00111100
    #10 s_in_tb = 8'hF0;   // 11110000
    #10 s_in_tb = 8'h55;   // 01010101
    #10 s_in_tb = 8'hAA;   // 10101010
    #10 s_in_tb = 8'h0F;   // 00001111
    #10 s_in_tb = 8'hFF;   // 11111111
    #10 s_in_tb = 8'h11;   // 00010001
    #10 s_in_tb = 8'h22;   // 00100010
    #10 s_in_tb = 8'h33;   // 00110011

    #100;
    $finish;
end

endmodule
