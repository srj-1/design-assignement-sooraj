//----------------------------------------------------------
// Copyright (c) 2015 by Ando Ki.
// All right reserved.
//----------------------------------------------------------
// dma_axi_simple_csr.v
//----------------------------------------------------------
// VERSION: 2026.06.20.
//----------------------------------------------------------
// AXI DMA CSR block with legacy simple-DMA registers and
// scatter-gather descriptor observability.
//----------------------------------------------------------
`timescale 1ns/1ns

module dma_axi_simple_csr #(parameter T_ADDR_WID=8,
                            parameter SG_ENABLE=1)
(
       input   wire                   RESET_N
     , input   wire                   CLK
     , input   wire [T_ADDR_WID-1:0]  T_ADDR
     , input   wire                   T_WREN
     , input   wire                   T_RDEN
     , input   wire [31:0]            T_WDATA
     , output  reg  [31:0]            T_RDATA
     , output  wire                   IRQ
     //-----------------------------------------------------
     , output  wire            DMA_EN
     , output  wire            DMA_GO
     , input   wire            DMA_BUSY
     , input   wire            DMA_DONE
     , input   wire            DMA_ERROR
     , input   wire  [ 7:0]    DMA_ERROR_CODE
     , output  wire  [31:0]    DMA_SRC
     , output  wire  [31:0]    DMA_DST
     , output  wire  [31:0]    DMA_BNUM // num of bytes to move
     , output  wire  [ 7:0]    DMA_CHUNK// num of bytes to move at a time
     //-----------------------------------------------------
     , output  wire            SG_MODE
     , output  wire  [31:0]    SG_DESC_ADDR
     , input   wire            SG_BUSY
     , input   wire            SG_DONE
     , input   wire            SG_ERROR
     , input   wire  [ 7:0]    SG_STATE
     , input   wire  [ 7:0]    SG_ERROR_CODE
     , input   wire  [31:0]    SG_CURDESC
     , input   wire  [31:0]    SG_NEXTDESC
     , input   wire  [31:0]    SG_CUR_SRC
     , input   wire  [31:0]    SG_CUR_DST
     , input   wire  [31:0]    SG_CUR_LEN
     , input   wire  [31:0]    SG_CUR_CTRL
     , input   wire  [31:0]    SG_CUR_STATUS
     , input   wire  [31:0]    SG_BYTES_DONE
     , input   wire  [31:0]    SG_DESC_DONE
);
   //--------------------------------------------------------
   // CSR address map. Legacy addresses are unchanged.
   //-------------------------------------------------------
   localparam CSRA_NAME0        = 8'h00,
              CSRA_NAME1        = 8'h04,
              CSRA_NAME2        = 8'h08,
              CSRA_NAME3        = 8'h0C,
              CSRA_COMP0        = 8'h10,
              CSRA_COMP1        = 8'h14,
              CSRA_COMP2        = 8'h18,
              CSRA_COMP3        = 8'h1C,
              CSRA_VERSION      = 8'h20,
              CSRA_CONTROL      = 8'h30,
              CSRA_NUM          = 8'h40,
              CSRA_SOURCE       = 8'h44,
              CSRA_DEST         = 8'h48,
              CSRA_STATUS       = 8'h4C,
              CSRA_SG_CONTROL   = 8'h50,
              CSRA_SG_DESC      = 8'h54,
              CSRA_SG_STATUS    = 8'h58,
              CSRA_SG_ERROR     = 8'h5C,
              CSRA_SG_CURDESC   = 8'h60,
              CSRA_SG_NEXTDESC  = 8'h64,
              CSRA_SG_SOURCE    = 8'h68,
              CSRA_SG_DEST      = 8'h6C,
              CSRA_SG_LENGTH    = 8'h70,
              CSRA_SG_DCTRL     = 8'h74,
              CSRA_SG_DSTATUS   = 8'h78,
              CSRA_SG_BYTES     = 8'h7C,
              CSRA_SG_DESC_DONE = 8'h80;
   //-------------------------------------------------------
   wire [31:0] csr_name0   = "DMA ";
   wire [31:0] csr_name1   = "AXI ";
   wire [31:0] csr_name2   = "SG  ";
   wire [31:0] csr_name3   = "    ";
   wire [31:0] csr_comp0   = "DYNA";
   wire [31:0] csr_comp1   = "LITH";
   wire [31:0] csr_comp2   = "    ";
   wire [31:0] csr_comp3   = "    ";
   wire [31:0] csr_version = 32'h20260620;
   //-------------------------------------------------------
   reg         csr_ctl_en    = 1'b0; // bit-31
   reg         csr_ctl_ip    = 1'b0; // bit-1
   reg         csr_ctl_ie    = 1'b0; // bit-0
   //-------------------------------------------------------
   reg         csr_num_go    = 1'b0; // bit-31
   reg  [ 7:0] csr_num_chunk = 8'b0; // bit-23~16
   reg  [15:0] csr_num_byte  =16'b0; // bit-15~0
   //-------------------------------------------------------
   reg  [31:0] csr_source    =32'h0;
   reg  [31:0] csr_dest      =32'h0;
   reg         csr_sg_mode   = 1'b0;
   reg  [31:0] csr_sg_desc   =32'h0;
   //-------------------------------------------------------
   wire        sg_capable    = (SG_ENABLE!=0);
   wire [31:0] dma_status    = {DMA_BUSY,
                                DMA_DONE,
                                DMA_ERROR,
                                5'h0,
                                DMA_ERROR_CODE,
                                16'h0};
   wire [31:0] sg_status     = {sg_capable,
                                csr_sg_mode,
                                SG_BUSY,
                                SG_DONE,
                                SG_ERROR,
                                11'h0,
                                SG_STATE,
                                SG_ERROR_CODE};
   //-------------------------------------------------------
   // CSR read
   always @ (posedge CLK or negedge RESET_N) begin
   if (RESET_N==1'b0) begin
       T_RDATA <= 32'h0;
   end else begin
      if (T_RDEN) begin
         case (T_ADDR) // synthesis full_case parallel_case
           CSRA_NAME0        : T_RDATA <= csr_name0;
           CSRA_NAME1        : T_RDATA <= csr_name1;
           CSRA_NAME2        : T_RDATA <= csr_name2;
           CSRA_NAME3        : T_RDATA <= csr_name3;
           CSRA_COMP0        : T_RDATA <= csr_comp0;
           CSRA_COMP1        : T_RDATA <= csr_comp1;
           CSRA_COMP2        : T_RDATA <= csr_comp2;
           CSRA_COMP3        : T_RDATA <= csr_comp3;
           CSRA_VERSION      : T_RDATA <= csr_version;
           CSRA_CONTROL      : T_RDATA <= {csr_ctl_en,29'h0,csr_ctl_ip,csr_ctl_ie};
           CSRA_NUM          : T_RDATA <= {csr_num_go,
                                           DMA_BUSY,
                                           DMA_DONE,
                                           DMA_ERROR,
                                           4'h0,
                                           csr_num_chunk,
                                           csr_num_byte};
           CSRA_SOURCE       : T_RDATA <= csr_source;
           CSRA_DEST         : T_RDATA <= csr_dest;
           CSRA_STATUS       : T_RDATA <= dma_status;
           CSRA_SG_CONTROL   : T_RDATA <= {sg_capable,30'h0,csr_sg_mode};
           CSRA_SG_DESC      : T_RDATA <= csr_sg_desc;
           CSRA_SG_STATUS    : T_RDATA <= sg_status;
           CSRA_SG_ERROR     : T_RDATA <= {24'h0,SG_ERROR_CODE};
           CSRA_SG_CURDESC   : T_RDATA <= SG_CURDESC;
           CSRA_SG_NEXTDESC  : T_RDATA <= SG_NEXTDESC;
           CSRA_SG_SOURCE    : T_RDATA <= SG_CUR_SRC;
           CSRA_SG_DEST      : T_RDATA <= SG_CUR_DST;
           CSRA_SG_LENGTH    : T_RDATA <= SG_CUR_LEN;
           CSRA_SG_DCTRL     : T_RDATA <= SG_CUR_CTRL;
           CSRA_SG_DSTATUS   : T_RDATA <= SG_CUR_STATUS;
           CSRA_SG_BYTES     : T_RDATA <= SG_BYTES_DONE;
           CSRA_SG_DESC_DONE : T_RDATA <= SG_DESC_DONE;
           default           : T_RDATA <= 32'h0;
         endcase
      end else begin
         T_RDATA <= 32'h0;
      end
   end
   end
   //-------------------------------------------------------
   // CSR write
   always @ (posedge CLK or negedge RESET_N) begin
   if (RESET_N==1'b0) begin
       csr_ctl_en    <= 1'b0;
       csr_num_chunk <= 8'b0;
       csr_num_byte  <= 16'h0;
       csr_source    <= 32'h0;
       csr_dest      <= 32'h0;
       csr_sg_mode   <= 1'b0;
       csr_sg_desc   <= 32'h0;
   end else begin
      if (T_WREN) begin
         case (T_ADDR) // synthesis full_case parallel_case
           CSRA_CONTROL: begin
                csr_ctl_en <= T_WDATA[31];
           end
           CSRA_NUM: begin
                csr_num_chunk <= T_WDATA[23:16];
                csr_num_byte  <= T_WDATA[15:0];
           end
           CSRA_SOURCE: begin
                csr_source <= T_WDATA;
           end
           CSRA_DEST: begin
                csr_dest <= T_WDATA;
           end
           CSRA_SG_CONTROL: begin
                csr_sg_mode <= sg_capable & T_WDATA[0];
           end
           CSRA_SG_DESC: begin
                csr_sg_desc <= T_WDATA;
           end
         endcase
      end
      if (sg_capable==1'b0) begin
          csr_sg_mode <= 1'b0;
      end
   end
   end
   //-------------------------------------------------------
   // go
   always @ (posedge CLK or negedge RESET_N) begin
   if (RESET_N==1'b0) begin
       csr_num_go <= 1'b0;
   end else begin
       if (T_WREN&&(T_ADDR==CSRA_NUM)) begin
           csr_num_go <= csr_ctl_en & T_WDATA[31];
       end else begin
           if (DMA_DONE) csr_num_go <= 1'b0;
           if (DMA_ERROR) csr_num_go <= 1'b0;
           if (csr_ctl_en==1'b0) csr_num_go <= 1'b0;
       end
   end
   end
   //-------------------------------------------------------
   // interrupt
   always @ (posedge CLK or negedge RESET_N) begin
   if (RESET_N==1'b0) begin
       csr_ctl_ie <= 1'b0;
       csr_ctl_ip <= 1'b0;
   end else begin
       if (T_WREN&&(T_ADDR==CSRA_CONTROL)) begin
           csr_ctl_ie <= T_WDATA[0];
           if (T_WDATA[1]) csr_ctl_ip <= 1'b0;
       end else begin
           if (csr_ctl_ie & DMA_GO & (DMA_DONE | DMA_ERROR))
               csr_ctl_ip <= 1'b1;
       end
   end
   end
   //-------------------------------------------------------
   assign IRQ = csr_ctl_ip;
   //-------------------------------------------------------
   assign DMA_EN    = csr_ctl_en;
   assign DMA_GO    = csr_ctl_en & csr_num_go;
   assign DMA_SRC   = csr_source;
   assign DMA_DST   = csr_dest;
   assign DMA_BNUM  = {16'h0,csr_num_byte};
   assign DMA_CHUNK = csr_num_chunk;
   assign SG_MODE   = sg_capable & csr_sg_mode;
   assign SG_DESC_ADDR = csr_sg_desc;
   //-------------------------------------------------------
endmodule
//-------------------------------------------------------
// Revision History
//
// 2015.07.12: Started by Ando Ki
// 2026.06.20: Added scatter-gather CSR extension.
//-------------------------------------------------------
