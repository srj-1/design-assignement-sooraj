`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.06.2026 12:36:27
// Design Name: 
// Module Name: top_apb
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


module top_apb (
  input  logic        clk,
  input  logic        rst_n,
  input  logic [31:0] paddr,
  input  logic        psel,
  input  logic        penable,
  input  logic        pwrite,
  input  logic [31:0] pwdata,
  output logic [31:0] prdata,
  output logic        pready
);

  apb_slave u_apb_slave (
    .clk    (clk),
    .rst_n  (rst_n),
    .paddr  (paddr),
    .psel   (psel),
    .penable(penable),
    .pwrite (pwrite),
    .pwdata (pwdata),
    .prdata (prdata),
    .pready (pready)
  );

endmodule
