
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.06.2026 17:26:05
// Design Name: 
// Module Name: bcd_adder
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


module bcd_adder(input [3:0]A,[3:0]B,input cin ,output [3:0]S, output cout );
wire [3:0]w;
wire w5,w6,w7,w8;
ripple_carry_add rc1(A,B,cin,w,w5);
and (w6,w[2],w[3]);
and(w7,w[1],w[3]);
or(w8,w5,w6,w7);

ripple_carry_add rc2(w,{1'b0, w8, w8, 1'b0}, 1'b0,S,cout);
  
endmodule

