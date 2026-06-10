`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2026 21:24:58
// Design Name: 
// Module Name: TOP
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
module TOP(
    input clk,
    input rst,
    input [7:0] s_in,
    output [7:0] d_out
);

wire [7:0] face_out;
wire [7:0] fifo_out;

wire full;
wire empty;

// Face Detection Module
Face_Detect_Mod FD(clk, s_in, face_out);

// FIFO
FIFO F1(clk, rst, 1'b1, 1'b1, face_out, fifo_out, full, empty);

// Output Module
mod_out M1(clk, fifo_out, d_out);

endmodule
