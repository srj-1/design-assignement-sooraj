`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2026 16:01:28
// Design Name: 
// Module Name: Face_detect_mod
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


module Face_Detect_Mod(input clk,input [7:0]s_in ,output reg [7:0]s_out);
always @(posedge clk)
s_out<=s_in;
endmodule
