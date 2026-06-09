`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.06.2026 15:39:03
// Design Name: 
// Module Name: usr_tb
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




module usr_tb();
reg clk_tb, rst_tb, sin_tb;
reg [3:0] p_in_tb;
reg shift_tb, load_tb, enb_tb;
reg [1:0] mod_tb;
wire sout_tb;
wire [3:0] p_out_tb;
usr dut(
clk_tb, 
rst_tb, 
sin_tb, 
p_in_tb, 
shift_tb, 
load_tb, 
enb_tb, 
mod_tb, 
sout_tb, 
p_out_tb
);
initial begin
{clk_tb, rst_tb, sin_tb, p_in_tb, shift_tb, load_tb, enb_tb, mod_tb} = 0;
end
always #5 clk_tb = ~clk_tb;
initial begin
shift_tb = 1;
load_tb = 1;
rst_tb = 1;
#10;
rst_tb = 0;
mod_tb = 2'b00;
enb_tb = 0;
sin_tb = 1; #10;
sin_tb = 0; #10;
sin_tb = 1; #10;
sin_tb = 0; #10;
enb_tb = 1; #10;
mod_tb = 2'b01;
enb_tb = 0;
sin_tb = 1; #10;
sin_tb = 1; #10;
sin_tb = 0; #10;
sin_tb = 1; #10;
enb_tb = 1; #10;
mod_tb = 2'b10;
p_in_tb = 4'b1101;
enb_tb = 1; #10;
enb_tb = 0; #40;
mod_tb = 2'b11;
p_in_tb = 4'b1011;
enb_tb = 1; #10;
enb_tb = 0; #10;
end
endmodule
