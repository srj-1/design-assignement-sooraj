`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2026 16:23:48
// Design Name: 
// Module Name: Face_Detect_Mod_tb
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


module Face_Detect_Mod_tb();
reg clk_tb;
reg [7:0] s_in_tb;
wire [7:0]s_out_tb;
Face_Detect_Mod dut(clk_tb,s_in_tb,s_out_tb);
initial 
begin
{clk_tb,s_in_tb}=0;
end
always #5 clk_tb=~clk_tb;
initial
begin
    #10 s_in_tb = 8'b00001111;
    #10 s_in_tb = 8'b10101010;
    #10 s_in_tb = 8'b11110000;
    #10 s_in_tb = 8'b11001100;
    #10 s_in_tb = 8'b11111111;

    
end

endmodule


