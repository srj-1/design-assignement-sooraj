`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.06.2026 14:49:36
// Design Name: 
// Module Name: usr
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



module usr(
input clk, rst, sin,
input [3:0] p_in,
input shift, load, enb,
input [1:0] mod,
output reg sout,
output reg [3:0] p_out
);
reg [3:0] temp;
always @(posedge clk) begin
if (shift) begin
if (load) begin
case (mod)
2'b00: begin
if (rst) begin
temp <= 4'b0000;
sout <= 1'b0;
end
else if (enb == 0) begin
temp <= {sin, temp[3:1]};
end
else if (enb == 1) begin
sout <= temp[0];
end
end
2'b01: begin 
if (rst) begin
temp <= 4'b0000;
end
else if (enb == 0) begin
temp <= {sin, temp[3:1]};
end
else if (enb == 1) begin
p_out <= temp;
end
end
2'b10: begin
if (rst) begin
temp <= 4'b0000;
sout <= 1'b0;
end
else if (enb == 1) begin
temp <= p_in;
end
else if (enb == 0) begin
sout <= temp[0];
temp <= temp >> 1'b1;
end
end
2'b11: begin
if (rst) begin
temp <= 4'b0000;
p_out <= 4'b0000;
end
else if (enb == 1) begin
temp <= p_in;
end
else if (enb == 0) begin
p_out <= temp;
end
end
endcase
end
end
end
endmodule
