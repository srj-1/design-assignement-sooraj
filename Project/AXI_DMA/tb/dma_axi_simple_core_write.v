//----------------------------------------------------------
// Copyright (c) 2015 by Ando Ki.
// All right reserved.
//----------------------------------------------------------
// VERSION: 2026.06.20.
//----------------------------------------------------------
// DMA AXI write channel.
//----------------------------------------------------------
`include "dma_axi_simple_defines.v"
`timescale 1ns/1ns

module dma_axi_simple_core_write
     #(parameter AXI_WIDTH_CID=4
               , AXI_WIDTH_ID =4
               , AXI_WIDTH_AD =32
               , AXI_WIDTH_DA =32
               , AXI_WIDTH_DS =(AXI_WIDTH_DA/8)
               , AXI_WIDTH_DSB=clogb2(AXI_WIDTH_DS)
               , AXI_WIDTH_SID=AXI_WIDTH_CID+AXI_WIDTH_ID
               , FIFO_WIDTH   =AXI_WIDTH_DS+AXI_WIDTH_DA
               , FIFO_AW      =4
               , FIFO_DEPTH   =1<<FIFO_AW
               , AXI_TIMEOUT  =1024
               )
(
       input  wire                     ARESETn
     , input  wire                     ACLK
     //-----------------------------------------------------------
     `undef Otype `define Otype reg
     `undef Itype `define Itype wire
     `AMBA_AXI_MASTER_PORT_AW
     `AMBA_AXI_MASTER_PORT_W
     `AMBA_AXI_MASTER_PORT_B
     //-----------------------------------------------------------
     , input   wire            DMA_EN
     , input   wire            DMA_GO
     , output  reg             DMA_BUSY=1'b0
     , output  reg             DMA_DONE=1'b0
     , output  reg             DMA_ERROR=1'b0
     , output  reg   [ 7:0]    DMA_ERROR_CODE=`DMA_ERR_NONE
     , input   wire  [31:0]    DMA_DST
     , input   wire  [31:0]    DMA_BNUM
     , input   wire  [ 7:0]    DMA_CHUNK
     //-----------------------------------------------------------
     , output  reg                    fifo_rd_rdy=1'b0
     , input   wire                   fifo_rd_vld
     , input   wire  [FIFO_WIDTH-1:0] fifo_rd_dat
     , input   wire  [FIFO_AW:0]      fifo_items
);
   //-----------------------------------------------------
`ifdef AMBA_AXI4
   localparam MAX_BURST_BEATS = 256;
`else
   localparam MAX_BURST_BEATS = 16;
`endif
   //-----------------------------------------------------
   reg  [31:0]              W_addr =32'h0;
   reg  [AXI_WIDTH_DSB:0]   W_size =  'h0;
   reg  [ 8:0]              W_len  = 9'h0;
   reg  [31:0]              W_rem  =32'h0;
   reg  [31:0]              W_chunk=32'h0;
   reg  [31:0]              W_inc  =32'h0;
   reg                      W_go   = 1'b0;
   reg                      W_done = 1'b0;
   //-----------------------------------------------------
   wire [31:0] W_full_rem_bytes = {W_rem[31:AXI_WIDTH_DSB],
                                   {AXI_WIDTH_DSB{1'b0}}};
   wire [31:0] W_req_bytes      = (W_rem>=W_chunk) ? W_chunk
                                                   : W_full_rem_bytes;
   wire [31:0] W_burst_bytes    = limit_4k(W_addr,W_req_bytes);
   wire [ 8:0] W_burst_beats    = W_burst_bytes >> AXI_WIDTH_DSB;
   //-----------------------------------------------------
   localparam ST_READY      = 'h0,
              ST_MISALIGN   = 'h1,
              ST_ALIGN      = 'h2,
              ST_WRITE      = 'h3,
              ST_WRITE_DONE = 'h4;
   reg [2:0] state = ST_READY; // synthesis attribute keep of state is "true";
   //-----------------------------------------------------
   always @ (posedge ACLK or negedge ARESETn) begin
   if (ARESETn==1'b0) begin
       DMA_BUSY <= 1'b0;
       DMA_DONE <= 1'b0;
       W_addr   <= 32'h0;
       W_size   <=   'h0;
       W_len    <=  9'h0;
       W_rem    <= 32'h0;
       W_chunk  <= 32'h0;
       W_inc    <= 32'h0;
       W_go     <=  1'b0;
       state    <= ST_READY;
   end else if (DMA_EN==1'b0) begin
       DMA_BUSY <= 1'b0;
       DMA_DONE <= 1'b0;
       W_addr   <= 32'h0;
       W_size   <=   'h0;
       W_len    <=  9'h0;
       W_rem    <= 32'h0;
       W_chunk  <= 32'h0;
       W_inc    <= 32'h0;
       W_go     <=  1'b0;
       state    <= ST_READY;
   end else begin
   case (state)
   ST_READY: begin
      if (DMA_GO==1'b0) DMA_DONE <= 1'b0;
      if ((DMA_DONE==1'b0)&&(fifo_rd_vld==1'b1)&&
          (DMA_GO==1'b1)&&(DMA_BNUM!=32'h0)) begin
          DMA_BUSY  <= 1'b1;
          DMA_DONE  <= 1'b0;
          W_addr    <= DMA_DST;
          W_size    <= 'h0;
          W_len     <= 9'h0;
          W_rem     <= DMA_BNUM;
          W_go      <= 1'b0;
          W_chunk   <= (DMA_BNUM<=AXI_WIDTH_DS) ? DMA_BNUM
                                                : normalize_chunk(DMA_CHUNK);
          if (|DMA_DST[AXI_WIDTH_DSB-1:0]) begin
              state <= ST_MISALIGN;
          end else begin
              state <= ST_ALIGN;
          end
      end
      end
   ST_MISALIGN: begin
      if (fifo_items!=0) begin
          W_size <= 1;
          W_len  <= 9'h1;
          W_inc  <= 32'h1;
          W_go   <= 1'b1;
          state  <= ST_WRITE;
      end
      end
   ST_ALIGN: begin
      if (W_burst_bytes>=AXI_WIDTH_DS) begin
          if (fifo_items>=W_burst_beats) begin
              W_size <= AXI_WIDTH_DS;
              W_len  <= W_burst_beats;
              W_inc  <= W_burst_bytes;
              W_go   <= 1'b1;
              state  <= ST_WRITE;
          end
      end else if (fifo_items!=0) begin
          W_size <= 1;
          W_len  <= 9'h1;
          W_inc  <= 32'h1;
          W_go   <= 1'b1;
          state  <= ST_WRITE;
      end
      end
   ST_WRITE: begin
      if (W_done==1'b1) begin
          W_go   <= 1'b0;
          W_addr <= W_addr + W_inc;
          W_rem  <= W_rem  - W_inc;
          state  <= ST_WRITE_DONE;
      end
      end
   ST_WRITE_DONE: begin
      if (W_done==1'b0) begin
          if (|W_rem) begin
              if (|W_addr[AXI_WIDTH_DSB-1:0]) begin
                  state <= ST_MISALIGN;
              end else begin
                  state <= ST_ALIGN;
              end
          end else begin
              DMA_DONE <= 1'b1;
              DMA_BUSY <= 1'b0;
              state    <= ST_READY;
          end
      end
      end
   endcase
   end
   end
   //-------------------------------------------------------
   reg  [AXI_WIDTH_ID-1:0] CID='h0;
   reg  [ 8:0]             W_cnt=9'h0;
   reg  [31:0]             timeout_cnt=32'h0;
   //-------------------------------------------------------
   localparam SW_IDLE = 'h0,
              SW_ARB  = 'h1,
              SW_WR   = 'h2,
              SW_BR   = 'h3,
              SW_DONE = 'h4;
   reg [2:0] state_write=SW_IDLE; // synthesis attribute keep of state_write is "true";
   //-------------------------------------------------------
   always @ (posedge ACLK or negedge ARESETn) begin
   if (ARESETn==0) begin
       M_AWID      <= 'h0;
       M_AWADDR    <= 'h0;
       M_AWLEN     <= 'h0;
       M_AWLOCK    <= 'h0;
       M_AWSIZE    <= 'h0;
       M_AWBURST   <= 'h1;
       `ifdef AMBA_AXI_CACHE
       M_AWCACHE   <= 'h0;
       `endif
       `ifdef AMBA_AXI_PROT
       M_AWPROT    <= 'h2;
       `endif
       M_AWVALID   <= 1'b0;
       `ifdef AMBA_AXI4
       M_AWQOS     <= 'h0;
       M_AWREGION  <= 'h0;
       `endif
       M_WID       <= 'h0;
       M_WSTRB     <= 'h0;
       M_BREADY    <= 1'b0;
       DMA_ERROR      <= 1'b0;
       DMA_ERROR_CODE <= `DMA_ERR_NONE;
       W_done         <= 1'b0;
       CID            <= 'h0;
       W_cnt          <= 9'h0;
       timeout_cnt    <= 32'h0;
       state_write    <= SW_IDLE;
   end else if (DMA_EN==0) begin
       M_AWID      <= 'h0;
       M_AWADDR    <= 'h0;
       M_AWLEN     <= 'h0;
       M_AWLOCK    <= 'h0;
       M_AWSIZE    <= 'h0;
       M_AWBURST   <= 'h1;
       `ifdef AMBA_AXI_CACHE
       M_AWCACHE   <= 'h0;
       `endif
       `ifdef AMBA_AXI_PROT
       M_AWPROT    <= 'h2;
       `endif
       M_AWVALID   <= 1'b0;
       `ifdef AMBA_AXI4
       M_AWQOS     <= 'h0;
       M_AWREGION  <= 'h0;
       `endif
       M_WID       <= 'h0;
       M_WSTRB     <= 'h0;
       M_BREADY    <= 1'b0;
       DMA_ERROR      <= 1'b0;
       DMA_ERROR_CODE <= `DMA_ERR_NONE;
       W_done         <= 1'b0;
       CID            <= 'h0;
       W_cnt          <= 9'h0;
       timeout_cnt    <= 32'h0;
       state_write    <= SW_IDLE;
   end else begin
   case (state_write)
   SW_IDLE: begin
      timeout_cnt <= 32'h0;
      if (W_go==1'b1) begin
          DMA_ERROR      <= 1'b0;
          DMA_ERROR_CODE <= `DMA_ERR_NONE;
          M_AWID         <= CID+1;
          CID            <= CID + 1;
          M_AWADDR       <= W_addr;
          M_AWLEN        <= W_len - 1;
          case (W_size)
          'd1:  M_AWSIZE <= 'h0;
          'd2:  M_AWSIZE <= 'h1;
          'd4:  M_AWSIZE <= 'h2;
          'd8:  M_AWSIZE <= 'h3;
          'd16: M_AWSIZE <= 'h4;
          default: M_AWSIZE <= 'h0;
          endcase
          M_AWVALID   <= 1'b1;
          state_write <= SW_ARB;
      end
      end
   SW_ARB: begin
      if (M_AWREADY) begin
          M_AWVALID   <= 1'b0;
          W_cnt       <= 9'h1;
          M_WID       <= CID;
          M_WSTRB     <= get_strb(W_addr[AXI_WIDTH_DSB-1:0],W_size);
          timeout_cnt <= 32'h0;
          state_write <= SW_WR;
      end else if (timeout_cnt>=AXI_TIMEOUT) begin
          M_AWVALID      <= 1'b0;
          DMA_ERROR      <= 1'b1;
          DMA_ERROR_CODE <= `DMA_ERR_TIMEOUT;
          W_done         <= 1'b1;
          state_write    <= SW_DONE;
      end else begin
          timeout_cnt <= timeout_cnt + 1;
      end
      end
   SW_WR: begin
      if (M_WVALID&M_WREADY) begin
          timeout_cnt <= 32'h0;
          W_cnt <= W_cnt + 1;
          if (W_cnt>=W_len) begin
               M_BREADY    <= 1'b1;
               state_write <= SW_BR;
          end
      end else if (timeout_cnt>=AXI_TIMEOUT) begin
          DMA_ERROR      <= 1'b1;
          DMA_ERROR_CODE <= `DMA_ERR_TIMEOUT;
          W_done         <= 1'b1;
          state_write    <= SW_DONE;
      end else begin
          timeout_cnt <= timeout_cnt + 1;
      end
      end
   SW_BR: begin
      if (M_BVALID) begin
          M_BREADY    <= 1'b0;
          W_done      <= 1'b1;
          state_write <= SW_DONE;
          if (M_BID[AXI_WIDTH_ID-1:0]!=CID) begin
              DMA_ERROR      <= 1'b1;
              DMA_ERROR_CODE <= `DMA_ERR_AXI_ID;
          end else if (M_BRESP[1]) begin
              DMA_ERROR      <= 1'b1;
              DMA_ERROR_CODE <= `DMA_ERR_AXI_WRITE;
          end
      end else if (timeout_cnt>=AXI_TIMEOUT) begin
          M_BREADY       <= 1'b0;
          DMA_ERROR      <= 1'b1;
          DMA_ERROR_CODE <= `DMA_ERR_TIMEOUT;
          W_done         <= 1'b1;
          state_write    <= SW_DONE;
      end else begin
          timeout_cnt <= timeout_cnt + 1;
      end
      end
   SW_DONE: begin
      timeout_cnt <= 32'h0;
      if (W_go==1'b0) begin
          W_done      <= 1'b0;
          state_write <= SW_IDLE;
      end
      end
   endcase
   end
   end
   //---------------------------------------------------------
   always @ ( * ) begin
       fifo_rd_rdy = (state_write==SW_WR) & fifo_rd_vld & M_WREADY;
       M_WDATA     = fifo_rd_dat[AXI_WIDTH_DA-1:0];
       M_WVALID    = (state_write==SW_WR) & fifo_rd_vld;
       M_WLAST     = (state_write==SW_WR) & (W_cnt==W_len);
   end
   //---------------------------------------------------------
   function [AXI_WIDTH_DS-1:0] get_strb;
       input [AXI_WIDTH_DSB-1:0] addr;
       input [AXI_WIDTH_DSB:0]   size;
       integer                   idx;
   begin
       get_strb = {AXI_WIDTH_DS{1'b0}};
       for (idx=0; idx<AXI_WIDTH_DS; idx=idx+1) begin
           if ((idx>=addr) && (idx<(addr+size))) begin
               get_strb[idx] = 1'b1;
           end
       end
   end
   endfunction
   //-----------------------------------------------------------
   function [31:0] normalize_chunk;
       input [7:0] chunk;
       reg [31:0] beats;
   begin
       if (chunk<=AXI_WIDTH_DS) begin
           beats = 1;
       end else begin
           beats = chunk >> AXI_WIDTH_DSB;
       end
       if (beats==0) beats = 1;
       if (beats>FIFO_DEPTH) beats = FIFO_DEPTH;
       if (beats>MAX_BURST_BEATS) beats = MAX_BURST_BEATS;
       normalize_chunk = beats << AXI_WIDTH_DSB;
   end
   endfunction
   //-----------------------------------------------------------
   function [31:0] limit_4k;
       input [31:0] addr;
       input [31:0] bytes;
       reg   [31:0] boundary;
   begin
       boundary = 32'd4096 - {20'h0,addr[11:0]};
       if (bytes>boundary) limit_4k = boundary;
       else                limit_4k = bytes;
   end
   endfunction
   //-----------------------------------------------------------
   function integer clogb2;
   input [31:0] value;
   reg   [31:0] tmp;
   begin
      tmp = value - 1;
      for (clogb2 = 0; tmp > 0; clogb2 = clogb2 + 1) tmp = tmp >> 1;
   end
   endfunction
   //-----------------------------------------------------------
endmodule
//----------------------------------------------------------
// Revision history
//
// 2015.07.12: Started by Ando Ki.
// 2026.06.20: Added 32-bit lengths, generic strobes, and errors.
//----------------------------------------------------------
