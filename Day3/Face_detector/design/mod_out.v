`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2026 20:11:11
// Design Name: 
// Module Name: mod_out
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


module mod_out(input clk,input [7:0]d_in,output reg [7:0]d_out);
 reg [1:0]state;
  parameter IDLE = 2'b00,
              S1   = 2'b01,
              S2   = 2'b10;
              
 reg [7:0]temp;
initial
    begin
        state = IDLE;
        d_out = 8'b0;
    end
    
always @(posedge clk)
begin
    case(state)

        IDLE:
        begin
            temp <= d_in;
            state <= S1;
        end

        S1:
        begin
            state <= S2;
        end

        S2:
        begin
            d_out <= temp;
            state <= IDLE;
        end

    endcase
end
    
    



endmodule
