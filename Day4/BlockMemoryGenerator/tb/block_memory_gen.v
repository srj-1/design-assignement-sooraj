`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.06.2026 14:05:34
// Design Name: 
// Module Name: bram_tb
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


module bram_tb();

reg clk;
reg arstn;
reg wrenb;
reg [7:0] wraddress;
reg [7:0] rdaddress;
reg [7:0] d_in;
wire [7:0] data_out;

bram_ dut(
    clk,
    arstn,
    wrenb,
    wraddress,
    rdaddress,
    d_in,
    data_out
);

always #5 clk = ~clk;

initial
begin
    {clk, arstn, wrenb, wraddress, rdaddress, d_in} = 0;

    
    #10;
    arstn = 1;

    
    @(posedge clk);
    wrenb = 1;
    wraddress = 8'd0;
    d_in = 8'h55;

    
    @(posedge clk);
    wraddress = 8'd1;
    d_in = 8'hAA;

    
    @(posedge clk);
    wraddress = 8'd2;
    d_in = 8'hF0;


    @(posedge clk);
    wrenb = 0;

    
    rdaddress = 8'd0;
    @(posedge clk);

    
    rdaddress = 8'd1;
    @(posedge clk);

    
    rdaddress = 8'd2;
    @(posedge clk);

   
end

endmodule
