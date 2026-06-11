`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.06.2026 13:59:37
// Design Name: 
// Module Name: brm_
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


module bram_(
    input clk,
    input arstn,
    input wrenb,
    input [7:0] wraddress,
    input [7:0] rdaddress,
    input [7:0] d_in,
    output reg [7:0] data_out
);

reg [7:0] mem [0:7];
integer i;

always @(posedge clk or negedge arstn)
begin
    if(!arstn)
    begin
        for(i=0;i<8;i=i+1)
            mem[i] <= 8'd0;
    end
    else if(wrenb)
        mem[wraddress[2:0]] <= d_in;
end

always @(posedge clk or negedge arstn)
begin
    if(!arstn)
        data_out <= 8'd0;
    else
        data_out <= mem[rdaddress[2:0]];
end

endmodule
