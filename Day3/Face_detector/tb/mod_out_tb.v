`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2026 20:35:29
// Design Name: 
// Module Name: mod_out_tb
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


module mod_out_tb();
reg clk_tb;
reg [7:0]d_in_tb;
wire [7:0]d_out_tb;
mod_out dut(clk_tb,d_in_tb,d_out_tb);

initial begin
{clk_tb,d_in_tb}=0;
end

always #5 clk_tb=~clk_tb;
initial
begin

   d_in_tb = 8'h00;
        #12 d_in_tb = 8'hA5;  // 10100101
        #10 d_in_tb = 8'h3C;  // 00111100
        #10 d_in_tb = 8'hF0;  // 11110000
        #10 d_in_tb = 8'h55;  // 01010101
        #10 d_in_tb = 8'hFF;  // 11111111


end


endmodule
