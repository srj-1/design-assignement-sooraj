//----------------------------------------------------------
// Copyright (c) 2015 by Ando Ki.
// All right reserved.
//----------------------------------------------------------
// VERSION: 2026.06.20.
//----------------------------------------------------------
// DMA AXI core with legacy simple mode and scatter-gather mode.
//----------------------------------------------------------
`include "dma_axi_simple_defines.v"
`include "dma_axi_simple_core_read.v"
`include "dma_axi_simple_core_write.v"
`include "dma_axi_simple_fifo_sync_small.v"
`timescale 1ns/1ns

module dma_axi_simple_core
     #(parameter AXI_MST_ID   =1
               , AXI_WIDTH_CID=4
               , AXI_WIDTH_ID =4
               , AXI_WIDTH_AD =32
               , AXI_WIDTH_DA =32
               , AXI_WIDTH_DS =(AXI_WIDTH_DA/8)
               , AXI_WIDTH_DSB=clogb2(AXI_WIDTH_DS)
               , AXI_WIDTH_SID=AXI_WIDTH_CID+AXI_WIDTH_ID
               , SG_ENABLE    =1
               , SG_MAX_TRANSFER_BYTES=32'h7FFF_FFFF
               , AXI_TIMEOUT  =1024
               )
(
       input  wire                     ARESETn
     , input  wire                     ACLK
     //-----------------------------------------------------------
     `undef Otype `define Otype wire
     `undef Itype `define Itype wire
     `AMBA_AXI_MASTER_PORT
     //-----------------------------------------------------------
     , input   wire            DMA_EN
     , input   wire            DMA_GO
     , output  wire            DMA_BUSY
     , output  wire            DMA_DONE
     , output  wire            DMA_ERROR
     , output  wire  [ 7:0]    DMA_ERROR_CODE
     , input   wire  [31:0]    DMA_SRC
     , input   wire  [31:0]    DMA_DST
     , input   wire  [31:0]    DMA_BNUM
     , input   wire  [ 7:0]    DMA_CHUNK
     //-----------------------------------------------------------
     , input   wire            SG_MODE
     , input   wire  [31:0]    SG_DESC_ADDR
     , output  wire            SG_BUSY
     , output  wire            SG_DONE
     , output  wire            SG_ERROR
     , output  wire  [ 7:0]    SG_STATE
     , output  wire  [ 7:0]    SG_ERROR_CODE
     , output  wire  [31:0]    SG_CURDESC
     , output  wire  [31:0]    SG_NEXTDESC
     , output  wire  [31:0]    SG_CUR_SRC
     , output  wire  [31:0]    SG_CUR_DST
     , output  wire  [31:0]    SG_CUR_LEN
     , output  wire  [31:0]    SG_CUR_CTRL
     , output  wire  [31:0]    SG_CUR_STATUS
     , output  wire  [31:0]    SG_BYTES_DONE
     , output  wire  [31:0]    SG_DESC_DONE
);
   //-----------------------------------------------------
   assign M_MID = AXI_MST_ID[AXI_WIDTH_CID-1:0];
   //-----------------------------------------------------
   wire sg_capable = (SG_ENABLE!=0);
   //-----------------------------------------------------
   localparam FIFO_DW = AXI_WIDTH_DS + AXI_WIDTH_DA;
   localparam FIFO_AW = 5;
   //-----------------------------------------------------
   wire data_busy_r;
   wire data_done_r;
   wire data_error_r;
   wire [7:0] data_error_code_r;
   wire data_busy_w;
   wire data_done_w;
   wire data_error_w;
   wire [7:0] data_error_code_w;
   wire data_busy = data_busy_r | data_busy_w;
   wire data_done = data_done_r & data_done_w;
   //-----------------------------------------------------
   wire [31:0] data_src;
   wire [31:0] data_dst;
   wire [31:0] data_bnum;
   wire [ 7:0] data_chunk;
   wire        data_go;
   //-----------------------------------------------------
   wire fifo_wr_rdy;
   wire fifo_wr_vld;
   wire [FIFO_DW-1:0] fifo_wr_dat;
   wire fifo_rd_rdy;
   wire fifo_rd_vld;
   wire [FIFO_DW-1:0] fifo_rd_dat;
   wire fifo_full;
   wire fifo_empty;
   wire [FIFO_AW:0] fifo_items;
   wire [FIFO_AW:0] fifo_rooms;
   wire fifo_overflow  = fifo_wr_vld & ~fifo_wr_rdy;
   wire fifo_underflow = fifo_rd_rdy & ~fifo_rd_vld;
   wire data_error = data_error_r | data_error_w | fifo_overflow | fifo_underflow;
   wire [7:0] data_error_code = data_error_r ? data_error_code_r :
                                data_error_w ? data_error_code_w :
                                fifo_overflow ? `DMA_ERR_FIFO_OVERFLOW :
                                fifo_underflow ? `DMA_ERR_FIFO_UNDERFLOW :
                                `DMA_ERR_NONE;
   //-----------------------------------------------------
   // Read mover AXI wires
   wire [AXI_WIDTH_ID-1:0] rd_M_ARID;
   wire [AXI_WIDTH_AD-1:0] rd_M_ARADDR;
`ifdef AMBA_AXI4
   wire [ 7:0]             rd_M_ARLEN;
   wire                    rd_M_ARLOCK;
`else
   wire [ 3:0]             rd_M_ARLEN;
   wire [ 1:0]             rd_M_ARLOCK;
`endif
   wire [ 2:0]             rd_M_ARSIZE;
   wire [ 1:0]             rd_M_ARBURST;
`ifdef AMBA_AXI_CACHE
   wire [ 3:0]             rd_M_ARCACHE;
`endif
`ifdef AMBA_AXI_PROT
   wire [ 2:0]             rd_M_ARPROT;
`endif
   wire                    rd_M_ARVALID;
   wire                    rd_M_ARREADY;
`ifdef AMBA_AXI4
   wire [ 3:0]             rd_M_ARQOS;
   wire [ 3:0]             rd_M_ARREGION;
`endif
   wire                    rd_M_RVALID;
   wire                    rd_M_RREADY;
   //-----------------------------------------------------
   // Write mover AXI wires
   wire [AXI_WIDTH_ID-1:0] wr_M_AWID;
   wire [AXI_WIDTH_AD-1:0] wr_M_AWADDR;
`ifdef AMBA_AXI4
   wire [ 7:0]             wr_M_AWLEN;
   wire                    wr_M_AWLOCK;
`else
   wire [ 3:0]             wr_M_AWLEN;
   wire [ 1:0]             wr_M_AWLOCK;
`endif
   wire [ 2:0]             wr_M_AWSIZE;
   wire [ 1:0]             wr_M_AWBURST;
`ifdef AMBA_AXI_CACHE
   wire [ 3:0]             wr_M_AWCACHE;
`endif
`ifdef AMBA_AXI_PROT
   wire [ 2:0]             wr_M_AWPROT;
`endif
   wire                    wr_M_AWVALID;
   wire                    wr_M_AWREADY;
`ifdef AMBA_AXI4
   wire [ 3:0]             wr_M_AWQOS;
   wire [ 3:0]             wr_M_AWREGION;
`endif
   wire [AXI_WIDTH_ID-1:0] wr_M_WID;
   wire [AXI_WIDTH_DA-1:0] wr_M_WDATA;
   wire [AXI_WIDTH_DS-1:0] wr_M_WSTRB;
   wire                    wr_M_WLAST;
   wire                    wr_M_WVALID;
   wire                    wr_M_WREADY;
   wire                    wr_M_BVALID;
   wire                    wr_M_BREADY;
   //-----------------------------------------------------
   // Scatter-gather descriptor AXI registers.
   localparam [AXI_WIDTH_ID-1:0] SG_AXI_ID = {AXI_WIDTH_ID{1'b1}};
   reg [AXI_WIDTH_ID-1:0] sg_M_ARID='h0;
   reg [AXI_WIDTH_AD-1:0] sg_M_ARADDR='h0;
`ifdef AMBA_AXI4
   reg [ 7:0]             sg_M_ARLEN='h0;
   reg                    sg_M_ARLOCK=1'b0;
`else
   reg [ 3:0]             sg_M_ARLEN='h0;
   reg [ 1:0]             sg_M_ARLOCK='h0;
`endif
   reg [ 2:0]             sg_M_ARSIZE='h0;
   reg [ 1:0]             sg_M_ARBURST='h1;
`ifdef AMBA_AXI_CACHE
   reg [ 3:0]             sg_M_ARCACHE='h0;
`endif
`ifdef AMBA_AXI_PROT
   reg [ 2:0]             sg_M_ARPROT='h2;
`endif
   reg                    sg_M_ARVALID=1'b0;
`ifdef AMBA_AXI4
   reg [ 3:0]             sg_M_ARQOS='h0;
   reg [ 3:0]             sg_M_ARREGION='h0;
`endif
   reg                    sg_M_RREADY=1'b0;
   reg [AXI_WIDTH_ID-1:0] sg_M_AWID='h0;
   reg [AXI_WIDTH_AD-1:0] sg_M_AWADDR='h0;
`ifdef AMBA_AXI4
   reg [ 7:0]             sg_M_AWLEN='h0;
   reg                    sg_M_AWLOCK=1'b0;
`else
   reg [ 3:0]             sg_M_AWLEN='h0;
   reg [ 1:0]             sg_M_AWLOCK='h0;
`endif
   reg [ 2:0]             sg_M_AWSIZE='h0;
   reg [ 1:0]             sg_M_AWBURST='h1;
`ifdef AMBA_AXI_CACHE
   reg [ 3:0]             sg_M_AWCACHE='h0;
`endif
`ifdef AMBA_AXI_PROT
   reg [ 2:0]             sg_M_AWPROT='h2;
`endif
   reg                    sg_M_AWVALID=1'b0;
`ifdef AMBA_AXI4
   reg [ 3:0]             sg_M_AWQOS='h0;
   reg [ 3:0]             sg_M_AWREGION='h0;
`endif
   reg [AXI_WIDTH_ID-1:0] sg_M_WID='h0;
   reg [AXI_WIDTH_DA-1:0] sg_M_WDATA='h0;
   reg [AXI_WIDTH_DS-1:0] sg_M_WSTRB='h0;
   reg                    sg_M_WLAST=1'b0;
   reg                    sg_M_WVALID=1'b0;
   reg                    sg_M_BREADY=1'b0;
   //-----------------------------------------------------
   reg        sg_owned=1'b0;
   reg        sg_busy_reg=1'b0;
   reg        sg_done_reg=1'b0;
   reg        sg_error_reg=1'b0;
   reg [7:0]  sg_state_reg=`DMA_SG_STATE_IDLE;
   reg [7:0]  sg_error_code_reg=`DMA_ERR_NONE;
   reg        sg_data_go=1'b0;
   reg        sg_pending_error=1'b0;
   reg [7:0]  sg_pending_error_code=`DMA_ERR_NONE;
   reg        sg_fetch_error=1'b0;
   reg [2:0]  sg_fetch_index=3'h0;
   reg [31:0] sg_timeout_cnt=32'h0;
   reg [31:0] sg_curdesc_reg=32'h0;
   reg [31:0] sg_next_reg=32'h0;
   reg [31:0] sg_src_reg=32'h0;
   reg [31:0] sg_dst_reg=32'h0;
   reg [31:0] sg_len_reg=32'h0;
   reg [31:0] sg_ctrl_reg=32'h0;
   reg [31:0] sg_status_reg=32'h0;
   reg [31:0] sg_status_word=32'h0;
   reg [31:0] sg_bytes_done_reg=32'h0;
   reg [31:0] sg_desc_done_reg=32'h0;
   //-----------------------------------------------------
   wire sg_path_selected = sg_capable & (sg_owned | (SG_MODE & DMA_GO));
   wire sg_ar_sel = sg_path_selected &
                    ((sg_state_reg==`DMA_SG_STATE_FETCH_AR) |
                     (sg_state_reg==`DMA_SG_STATE_FETCH_R));
   wire sg_r_sel  = sg_path_selected & (sg_state_reg==`DMA_SG_STATE_FETCH_R);
   wire sg_aw_sel = sg_path_selected &
                    ((sg_state_reg==`DMA_SG_STATE_UPDATE_AW) |
                     (sg_state_reg==`DMA_SG_STATE_UPDATE_W)  |
                     (sg_state_reg==`DMA_SG_STATE_UPDATE_B));
   wire sg_w_sel  = sg_aw_sel;
   wire sg_b_sel  = sg_path_selected & (sg_state_reg==`DMA_SG_STATE_UPDATE_B);
   wire sg_arready = sg_ar_sel ? M_ARREADY : 1'b0;
   wire sg_awready = sg_aw_sel ? M_AWREADY : 1'b0;
   wire sg_wready  = sg_w_sel  ? M_WREADY  : 1'b0;
   //-----------------------------------------------------
   assign data_src   = sg_path_selected ? sg_src_reg : DMA_SRC;
   assign data_dst   = sg_path_selected ? sg_dst_reg : DMA_DST;
   assign data_bnum  = sg_path_selected ? sg_len_reg : DMA_BNUM;
   assign data_chunk = DMA_CHUNK;
   assign data_go    = sg_path_selected ? sg_data_go : DMA_GO;
   //-----------------------------------------------------
   assign rd_M_ARREADY = sg_ar_sel ? 1'b0 : M_ARREADY;
   assign rd_M_RVALID  = sg_r_sel  ? 1'b0 : M_RVALID;
   assign wr_M_AWREADY = sg_aw_sel ? 1'b0 : M_AWREADY;
   assign wr_M_WREADY  = sg_w_sel  ? 1'b0 : M_WREADY;
   assign wr_M_BVALID  = sg_b_sel  ? 1'b0 : M_BVALID;
   //-----------------------------------------------------
   assign M_ARID    = sg_ar_sel ? sg_M_ARID    : rd_M_ARID;
   assign M_ARADDR  = sg_ar_sel ? sg_M_ARADDR  : rd_M_ARADDR;
   assign M_ARLEN   = sg_ar_sel ? sg_M_ARLEN   : rd_M_ARLEN;
   assign M_ARLOCK  = sg_ar_sel ? sg_M_ARLOCK  : rd_M_ARLOCK;
   assign M_ARSIZE  = sg_ar_sel ? sg_M_ARSIZE  : rd_M_ARSIZE;
   assign M_ARBURST = sg_ar_sel ? sg_M_ARBURST : rd_M_ARBURST;
`ifdef AMBA_AXI_CACHE
   assign M_ARCACHE = sg_ar_sel ? sg_M_ARCACHE : rd_M_ARCACHE;
`endif
`ifdef AMBA_AXI_PROT
   assign M_ARPROT  = sg_ar_sel ? sg_M_ARPROT  : rd_M_ARPROT;
`endif
   assign M_ARVALID = sg_ar_sel ? sg_M_ARVALID : rd_M_ARVALID;
`ifdef AMBA_AXI4
   assign M_ARQOS    = sg_ar_sel ? sg_M_ARQOS    : rd_M_ARQOS;
   assign M_ARREGION = sg_ar_sel ? sg_M_ARREGION : rd_M_ARREGION;
`endif
   assign M_RREADY = sg_r_sel ? sg_M_RREADY : rd_M_RREADY;
   //-----------------------------------------------------
   assign M_AWID    = sg_aw_sel ? sg_M_AWID    : wr_M_AWID;
   assign M_AWADDR  = sg_aw_sel ? sg_M_AWADDR  : wr_M_AWADDR;
   assign M_AWLEN   = sg_aw_sel ? sg_M_AWLEN   : wr_M_AWLEN;
   assign M_AWLOCK  = sg_aw_sel ? sg_M_AWLOCK  : wr_M_AWLOCK;
   assign M_AWSIZE  = sg_aw_sel ? sg_M_AWSIZE  : wr_M_AWSIZE;
   assign M_AWBURST = sg_aw_sel ? sg_M_AWBURST : wr_M_AWBURST;
`ifdef AMBA_AXI_CACHE
   assign M_AWCACHE = sg_aw_sel ? sg_M_AWCACHE : wr_M_AWCACHE;
`endif
`ifdef AMBA_AXI_PROT
   assign M_AWPROT  = sg_aw_sel ? sg_M_AWPROT  : wr_M_AWPROT;
`endif
   assign M_AWVALID = sg_aw_sel ? sg_M_AWVALID : wr_M_AWVALID;
`ifdef AMBA_AXI4
   assign M_AWQOS    = sg_aw_sel ? sg_M_AWQOS    : wr_M_AWQOS;
   assign M_AWREGION = sg_aw_sel ? sg_M_AWREGION : wr_M_AWREGION;
`endif
   assign M_WID     = sg_w_sel ? sg_M_WID     : wr_M_WID;
   assign M_WDATA   = sg_w_sel ? sg_M_WDATA   : wr_M_WDATA;
   assign M_WSTRB   = sg_w_sel ? sg_M_WSTRB   : wr_M_WSTRB;
   assign M_WLAST   = sg_w_sel ? sg_M_WLAST   : wr_M_WLAST;
   assign M_WVALID  = sg_w_sel ? sg_M_WVALID  : wr_M_WVALID;
   assign M_BREADY  = sg_b_sel ? sg_M_BREADY  : wr_M_BREADY;
   //-----------------------------------------------------
   assign DMA_BUSY = sg_path_selected ? sg_busy_reg : data_busy;
   assign DMA_DONE = sg_path_selected ? sg_done_reg : data_done;
   assign DMA_ERROR = sg_path_selected ? sg_error_reg : data_error;
   assign DMA_ERROR_CODE = sg_path_selected ? sg_error_code_reg : data_error_code;
   assign SG_BUSY = sg_busy_reg;
   assign SG_DONE = sg_done_reg;
   assign SG_ERROR = sg_error_reg;
   assign SG_STATE = sg_state_reg;
   assign SG_ERROR_CODE = sg_error_code_reg;
   assign SG_CURDESC = sg_curdesc_reg;
   assign SG_NEXTDESC = sg_next_reg;
   assign SG_CUR_SRC = sg_src_reg;
   assign SG_CUR_DST = sg_dst_reg;
   assign SG_CUR_LEN = sg_len_reg;
   assign SG_CUR_CTRL = sg_ctrl_reg;
   assign SG_CUR_STATUS = sg_status_reg;
   assign SG_BYTES_DONE = sg_bytes_done_reg;
   assign SG_DESC_DONE = sg_desc_done_reg;
   //-----------------------------------------------------
   dma_axi_simple_core_read #(.AXI_WIDTH_CID(AXI_WIDTH_CID)
                             ,.AXI_WIDTH_ID (AXI_WIDTH_ID )
                             ,.AXI_WIDTH_AD (AXI_WIDTH_AD )
                             ,.AXI_WIDTH_DA (AXI_WIDTH_DA )
                             ,.FIFO_WIDTH   (FIFO_DW      )
                             ,.FIFO_AW      (FIFO_AW      )
                             ,.FIFO_DEPTH   (1<<FIFO_AW   )
                             ,.AXI_TIMEOUT  (AXI_TIMEOUT  ))
   u_read (
       .ARESETn   (ARESETn )
     , .ACLK      (ACLK    )
     , .M_ARID    (rd_M_ARID)
     , .M_ARADDR  (rd_M_ARADDR)
     , .M_ARLEN   (rd_M_ARLEN)
     , .M_ARLOCK  (rd_M_ARLOCK)
     , .M_ARSIZE  (rd_M_ARSIZE)
     , .M_ARBURST (rd_M_ARBURST)
`ifdef AMBA_AXI_CACHE
     , .M_ARCACHE (rd_M_ARCACHE)
`endif
`ifdef AMBA_AXI_PROT
     , .M_ARPROT  (rd_M_ARPROT)
`endif
     , .M_ARVALID (rd_M_ARVALID)
     , .M_ARREADY (rd_M_ARREADY)
`ifdef AMBA_AXI4
     , .M_ARQOS   (rd_M_ARQOS)
     , .M_ARREGION(rd_M_ARREGION)
`endif
     , .M_RID     (M_RID)
     , .M_RDATA   (M_RDATA)
     , .M_RRESP   (M_RRESP)
     , .M_RLAST   (M_RLAST)
     , .M_RVALID  (rd_M_RVALID)
     , .M_RREADY  (rd_M_RREADY)
     , .DMA_EN    (DMA_EN)
     , .DMA_GO    (data_go)
     , .DMA_BUSY  (data_busy_r)
     , .DMA_DONE  (data_done_r)
     , .DMA_ERROR (data_error_r)
     , .DMA_ERROR_CODE(data_error_code_r)
     , .DMA_SRC   (data_src)
     , .DMA_BNUM  (data_bnum)
     , .DMA_CHUNK (data_chunk)
     , .fifo_wr_rdy(fifo_wr_rdy)
     , .fifo_wr_vld(fifo_wr_vld)
     , .fifo_wr_dat(fifo_wr_dat)
     , .fifo_empty (fifo_empty )
     , .fifo_rooms (fifo_rooms )
   );
   //-----------------------------------------------------
   dma_axi_simple_core_write #(.AXI_WIDTH_CID(AXI_WIDTH_CID)
                              ,.AXI_WIDTH_ID (AXI_WIDTH_ID )
                              ,.AXI_WIDTH_AD (AXI_WIDTH_AD )
                              ,.AXI_WIDTH_DA (AXI_WIDTH_DA )
                              ,.FIFO_WIDTH   (FIFO_DW      )
                              ,.FIFO_AW      (FIFO_AW      )
                              ,.FIFO_DEPTH   (1<<FIFO_AW   )
                              ,.AXI_TIMEOUT  (AXI_TIMEOUT  ))
   u_write (
       .ARESETn   (ARESETn )
     , .ACLK      (ACLK    )
     , .M_AWID    (wr_M_AWID)
     , .M_AWADDR  (wr_M_AWADDR)
     , .M_AWLEN   (wr_M_AWLEN)
     , .M_AWLOCK  (wr_M_AWLOCK)
     , .M_AWSIZE  (wr_M_AWSIZE)
     , .M_AWBURST (wr_M_AWBURST)
`ifdef AMBA_AXI_CACHE
     , .M_AWCACHE (wr_M_AWCACHE)
`endif
`ifdef AMBA_AXI_PROT
     , .M_AWPROT  (wr_M_AWPROT)
`endif
     , .M_AWVALID (wr_M_AWVALID)
     , .M_AWREADY (wr_M_AWREADY)
`ifdef AMBA_AXI4
     , .M_AWQOS   (wr_M_AWQOS)
     , .M_AWREGION(wr_M_AWREGION)
`endif
     , .M_WID     (wr_M_WID)
     , .M_WDATA   (wr_M_WDATA)
     , .M_WSTRB   (wr_M_WSTRB)
     , .M_WLAST   (wr_M_WLAST)
     , .M_WVALID  (wr_M_WVALID)
     , .M_WREADY  (wr_M_WREADY)
     , .M_BID     (M_BID)
     , .M_BRESP   (M_BRESP)
     , .M_BVALID  (wr_M_BVALID)
     , .M_BREADY  (wr_M_BREADY)
     , .DMA_EN    (DMA_EN)
     , .DMA_GO    (data_go)
     , .DMA_BUSY  (data_busy_w)
     , .DMA_DONE  (data_done_w)
     , .DMA_ERROR (data_error_w)
     , .DMA_ERROR_CODE(data_error_code_w)
     , .DMA_DST   (data_dst)
     , .DMA_BNUM  (data_bnum)
     , .DMA_CHUNK (data_chunk)
     , .fifo_rd_rdy(fifo_rd_rdy)
     , .fifo_rd_vld(fifo_rd_vld)
     , .fifo_rd_dat(fifo_rd_dat)
     , .fifo_items (fifo_items )
   );
   //-----------------------------------------------------------
   dma_axi_simple_fifo_sync_small
          #(.FDW(FIFO_DW), .FAW(FIFO_AW))
   u_fifo (
       .rst     (~ARESETn)
     , .clr     (~DMA_EN )
     , .clk     ( ACLK   )
     , .wr_rdy  (fifo_wr_rdy )
     , .wr_vld  (fifo_wr_vld )
     , .wr_din  (fifo_wr_dat )
     , .rd_rdy  (fifo_rd_rdy )
     , .rd_vld  (fifo_rd_vld )
     , .rd_dout (fifo_rd_dat )
     , .full    (fifo_full   )
     , .empty   (fifo_empty  )
     , .fullN   ()
     , .emptyN  ()
     , .rd_cnt  (fifo_items  )
     , .wr_cnt  (fifo_rooms  )
   );
   //-----------------------------------------------------------
   always @ (posedge ACLK or negedge ARESETn) begin
   if (ARESETn==1'b0) begin
       sg_M_ARID      <= 'h0;
       sg_M_ARADDR    <= 'h0;
       sg_M_ARLEN     <= 'h0;
       sg_M_ARLOCK    <= 'h0;
       sg_M_ARSIZE    <= 'h0;
       sg_M_ARBURST   <= 'h1;
`ifdef AMBA_AXI_CACHE
       sg_M_ARCACHE   <= 'h0;
`endif
`ifdef AMBA_AXI_PROT
       sg_M_ARPROT    <= 'h2;
`endif
       sg_M_ARVALID   <= 1'b0;
`ifdef AMBA_AXI4
       sg_M_ARQOS     <= 'h0;
       sg_M_ARREGION  <= 'h0;
`endif
       sg_M_RREADY    <= 1'b0;
       sg_M_AWID      <= 'h0;
       sg_M_AWADDR    <= 'h0;
       sg_M_AWLEN     <= 'h0;
       sg_M_AWLOCK    <= 'h0;
       sg_M_AWSIZE    <= 'h0;
       sg_M_AWBURST   <= 'h1;
`ifdef AMBA_AXI_CACHE
       sg_M_AWCACHE   <= 'h0;
`endif
`ifdef AMBA_AXI_PROT
       sg_M_AWPROT    <= 'h2;
`endif
       sg_M_AWVALID   <= 1'b0;
`ifdef AMBA_AXI4
       sg_M_AWQOS     <= 'h0;
       sg_M_AWREGION  <= 'h0;
`endif
       sg_M_WID       <= 'h0;
       sg_M_WDATA     <= 'h0;
       sg_M_WSTRB     <= 'h0;
       sg_M_WLAST     <= 1'b0;
       sg_M_WVALID    <= 1'b0;
       sg_M_BREADY    <= 1'b0;
       sg_owned       <= 1'b0;
       sg_busy_reg    <= 1'b0;
       sg_done_reg    <= 1'b0;
       sg_error_reg   <= 1'b0;
       sg_state_reg   <= `DMA_SG_STATE_IDLE;
       sg_error_code_reg <= `DMA_ERR_NONE;
       sg_data_go     <= 1'b0;
       sg_pending_error <= 1'b0;
       sg_pending_error_code <= `DMA_ERR_NONE;
       sg_fetch_error <= 1'b0;
       sg_fetch_index <= 3'h0;
       sg_timeout_cnt <= 32'h0;
       sg_curdesc_reg <= 32'h0;
       sg_next_reg    <= 32'h0;
       sg_src_reg     <= 32'h0;
       sg_dst_reg     <= 32'h0;
       sg_len_reg     <= 32'h0;
       sg_ctrl_reg    <= 32'h0;
       sg_status_reg  <= 32'h0;
       sg_status_word <= 32'h0;
       sg_bytes_done_reg <= 32'h0;
       sg_desc_done_reg  <= 32'h0;
   end else if ((DMA_EN==1'b0) || (sg_capable==1'b0)) begin
       sg_M_ARVALID   <= 1'b0;
       sg_M_RREADY    <= 1'b0;
       sg_M_AWVALID   <= 1'b0;
       sg_M_WVALID    <= 1'b0;
       sg_M_BREADY    <= 1'b0;
       sg_owned       <= 1'b0;
       sg_busy_reg    <= 1'b0;
       sg_done_reg    <= 1'b0;
       sg_error_reg   <= 1'b0;
       sg_state_reg   <= `DMA_SG_STATE_IDLE;
       sg_error_code_reg <= `DMA_ERR_NONE;
       sg_data_go     <= 1'b0;
       sg_pending_error <= 1'b0;
       sg_pending_error_code <= `DMA_ERR_NONE;
       sg_fetch_error <= 1'b0;
       sg_timeout_cnt <= 32'h0;
   end else begin
   case (sg_state_reg)
   `DMA_SG_STATE_IDLE: begin
      sg_M_ARVALID <= 1'b0;
      sg_M_RREADY  <= 1'b0;
      sg_M_AWVALID <= 1'b0;
      sg_M_WVALID  <= 1'b0;
      sg_M_BREADY  <= 1'b0;
      sg_data_go   <= 1'b0;
      sg_timeout_cnt <= 32'h0;
      if (DMA_GO==1'b0) begin
          sg_owned <= 1'b0;
          sg_done_reg <= 1'b0;
          sg_error_reg <= 1'b0;
          sg_error_code_reg <= `DMA_ERR_NONE;
      end
      if ((SG_MODE==1'b1)&&(DMA_GO==1'b1)&&(sg_owned==1'b0)) begin
          sg_owned    <= 1'b1;
          sg_busy_reg <= 1'b1;
          sg_done_reg <= 1'b0;
          sg_error_reg <= 1'b0;
          sg_error_code_reg <= `DMA_ERR_NONE;
          sg_pending_error <= 1'b0;
          sg_pending_error_code <= `DMA_ERR_NONE;
          sg_fetch_error <= 1'b0;
          sg_fetch_index <= 3'h0;
          sg_bytes_done_reg <= 32'h0;
          sg_desc_done_reg  <= 32'h0;
          sg_curdesc_reg <= SG_DESC_ADDR;
          sg_next_reg    <= 32'h0;
          sg_src_reg     <= 32'h0;
          sg_dst_reg     <= 32'h0;
          sg_len_reg     <= 32'h0;
          sg_ctrl_reg    <= 32'h0;
          sg_status_reg  <= 32'h0;
          if (SG_DESC_ADDR==32'h0) begin
              sg_busy_reg <= 1'b0;
              sg_done_reg <= 1'b1;
              sg_error_reg <= 1'b1;
              sg_error_code_reg <= `DMA_ERR_DESC_NULL;
              sg_state_reg <= `DMA_SG_STATE_ERROR;
          end else if (SG_DESC_ADDR[1:0]!=2'b00) begin
              sg_busy_reg <= 1'b0;
              sg_done_reg <= 1'b1;
              sg_error_reg <= 1'b1;
              sg_error_code_reg <= `DMA_ERR_DESC_ALIGN;
              sg_state_reg <= `DMA_SG_STATE_ERROR;
          end else begin
              sg_M_ARID    <= SG_AXI_ID;
              sg_M_ARADDR  <= SG_DESC_ADDR;
              sg_M_ARLEN   <= 'd5;
              sg_M_ARLOCK  <= 'h0;
              sg_M_ARSIZE  <= 3'h2;
              sg_M_ARBURST <= 2'b01;
`ifdef AMBA_AXI_CACHE
              sg_M_ARCACHE <= 4'h0;
`endif
`ifdef AMBA_AXI_PROT
              sg_M_ARPROT  <= 3'h2;
`endif
`ifdef AMBA_AXI4
              sg_M_ARQOS   <= 4'h0;
              sg_M_ARREGION<= 4'h0;
`endif
              sg_M_ARVALID <= 1'b1;
              sg_state_reg <= `DMA_SG_STATE_FETCH_AR;
          end
      end
      end
   `DMA_SG_STATE_FETCH_AR: begin
      if (sg_M_ARVALID & sg_arready) begin
          sg_M_ARVALID <= 1'b0;
          sg_M_RREADY  <= 1'b1;
          sg_fetch_index <= 3'h0;
          sg_fetch_error <= 1'b0;
          sg_timeout_cnt <= 32'h0;
          sg_state_reg <= `DMA_SG_STATE_FETCH_R;
      end else if (sg_timeout_cnt>=AXI_TIMEOUT) begin
          sg_M_ARVALID <= 1'b0;
          sg_busy_reg <= 1'b0;
          sg_done_reg <= 1'b1;
          sg_error_reg <= 1'b1;
          sg_error_code_reg <= `DMA_ERR_TIMEOUT;
          sg_state_reg <= `DMA_SG_STATE_ERROR;
      end else begin
          sg_timeout_cnt <= sg_timeout_cnt + 1;
      end
      end
   `DMA_SG_STATE_FETCH_R: begin
      if (M_RVALID & sg_M_RREADY) begin
          sg_timeout_cnt <= 32'h0;
          if (M_RRESP[1] || (M_RID!=SG_AXI_ID)) begin
              sg_fetch_error <= 1'b1;
              sg_error_code_reg <= M_RRESP[1] ? `DMA_ERR_AXI_READ : `DMA_ERR_AXI_ID;
          end
          case (sg_fetch_index)
          3'd0: sg_next_reg   <= get_bus_word(M_RDATA,sg_curdesc_reg+`DMA_SG_DESC_NEXT);
          3'd1: sg_src_reg    <= get_bus_word(M_RDATA,sg_curdesc_reg+`DMA_SG_DESC_SRC);
          3'd2: sg_dst_reg    <= get_bus_word(M_RDATA,sg_curdesc_reg+`DMA_SG_DESC_DST);
          3'd3: sg_len_reg    <= get_bus_word(M_RDATA,sg_curdesc_reg+`DMA_SG_DESC_LEN);
          3'd4: sg_ctrl_reg   <= get_bus_word(M_RDATA,sg_curdesc_reg+`DMA_SG_DESC_CTRL);
          3'd5: sg_status_reg <= get_bus_word(M_RDATA,sg_curdesc_reg+`DMA_SG_DESC_STATUS);
          endcase
          if (sg_fetch_index==3'd5) begin
              sg_M_RREADY <= 1'b0;
              if (M_RLAST!=1'b1) begin
                  sg_error_code_reg <= `DMA_ERR_AXI_READ;
                  sg_busy_reg <= 1'b0;
                  sg_done_reg <= 1'b1;
                  sg_error_reg <= 1'b1;
                  sg_state_reg <= `DMA_SG_STATE_ERROR;
              end else if (sg_fetch_error || M_RRESP[1] || (M_RID!=SG_AXI_ID)) begin
                  sg_busy_reg <= 1'b0;
                  sg_done_reg <= 1'b1;
                  sg_error_reg <= 1'b1;
                  sg_state_reg <= `DMA_SG_STATE_ERROR;
              end else begin
                  sg_state_reg <= `DMA_SG_STATE_DECODE;
              end
          end else begin
              sg_fetch_index <= sg_fetch_index + 1;
          end
      end else if (sg_timeout_cnt>=AXI_TIMEOUT) begin
          sg_M_RREADY <= 1'b0;
          sg_busy_reg <= 1'b0;
          sg_done_reg <= 1'b1;
          sg_error_reg <= 1'b1;
          sg_error_code_reg <= `DMA_ERR_TIMEOUT;
          sg_state_reg <= `DMA_SG_STATE_ERROR;
      end else begin
          sg_timeout_cnt <= sg_timeout_cnt + 1;
      end
      end
   `DMA_SG_STATE_DECODE: begin
      sg_timeout_cnt <= 32'h0;
      sg_pending_error <= 1'b0;
      sg_pending_error_code <= `DMA_ERR_NONE;
      sg_status_reg <= {1'b0,1'b0,1'b1,5'h0,`DMA_ERR_NONE,sg_len_reg[15:0]};
      if (sg_ctrl_reg[`DMA_SG_CTRL_VALID]==1'b0) begin
          sg_pending_error <= 1'b1;
          sg_pending_error_code <= `DMA_ERR_DESC_INVALID;
          sg_error_code_reg <= `DMA_ERR_DESC_INVALID;
          sg_status_word <= make_status(1'b1,`DMA_ERR_DESC_INVALID,sg_len_reg);
          sg_status_reg  <= make_status(1'b1,`DMA_ERR_DESC_INVALID,sg_len_reg);
          sg_M_AWID    <= SG_AXI_ID;
          sg_M_AWADDR  <= sg_curdesc_reg + `DMA_SG_DESC_STATUS;
          sg_M_AWLEN   <= 'h0;
          sg_M_AWLOCK  <= 'h0;
          sg_M_AWSIZE  <= 3'h2;
          sg_M_AWBURST <= 2'b01;
          sg_M_AWVALID <= 1'b1;
          sg_state_reg <= `DMA_SG_STATE_UPDATE_AW;
      end else if (sg_len_reg==32'h0) begin
          sg_pending_error <= 1'b1;
          sg_pending_error_code <= `DMA_ERR_LEN_ZERO;
          sg_error_code_reg <= `DMA_ERR_LEN_ZERO;
          sg_status_word <= make_status(1'b1,`DMA_ERR_LEN_ZERO,sg_len_reg);
          sg_status_reg  <= make_status(1'b1,`DMA_ERR_LEN_ZERO,sg_len_reg);
          sg_M_AWID    <= SG_AXI_ID;
          sg_M_AWADDR  <= sg_curdesc_reg + `DMA_SG_DESC_STATUS;
          sg_M_AWLEN   <= 'h0;
          sg_M_AWLOCK  <= 'h0;
          sg_M_AWSIZE  <= 3'h2;
          sg_M_AWBURST <= 2'b01;
          sg_M_AWVALID <= 1'b1;
          sg_state_reg <= `DMA_SG_STATE_UPDATE_AW;
      end else if (sg_len_reg>SG_MAX_TRANSFER_BYTES) begin
          sg_pending_error <= 1'b1;
          sg_pending_error_code <= `DMA_ERR_LEN_TOO_LARGE;
          sg_error_code_reg <= `DMA_ERR_LEN_TOO_LARGE;
          sg_status_word <= make_status(1'b1,`DMA_ERR_LEN_TOO_LARGE,sg_len_reg);
          sg_status_reg  <= make_status(1'b1,`DMA_ERR_LEN_TOO_LARGE,sg_len_reg);
          sg_M_AWID    <= SG_AXI_ID;
          sg_M_AWADDR  <= sg_curdesc_reg + `DMA_SG_DESC_STATUS;
          sg_M_AWLEN   <= 'h0;
          sg_M_AWLOCK  <= 'h0;
          sg_M_AWSIZE  <= 3'h2;
          sg_M_AWBURST <= 2'b01;
          sg_M_AWVALID <= 1'b1;
          sg_state_reg <= `DMA_SG_STATE_UPDATE_AW;
      end else if (sg_src_reg[AXI_WIDTH_DSB-1:0]!=sg_dst_reg[AXI_WIDTH_DSB-1:0]) begin
          sg_pending_error <= 1'b1;
          sg_pending_error_code <= `DMA_ERR_ADDR_ALIGN;
          sg_error_code_reg <= `DMA_ERR_ADDR_ALIGN;
          sg_status_word <= make_status(1'b1,`DMA_ERR_ADDR_ALIGN,sg_len_reg);
          sg_status_reg  <= make_status(1'b1,`DMA_ERR_ADDR_ALIGN,sg_len_reg);
          sg_M_AWID    <= SG_AXI_ID;
          sg_M_AWADDR  <= sg_curdesc_reg + `DMA_SG_DESC_STATUS;
          sg_M_AWLEN   <= 'h0;
          sg_M_AWLOCK  <= 'h0;
          sg_M_AWSIZE  <= 3'h2;
          sg_M_AWBURST <= 2'b01;
          sg_M_AWVALID <= 1'b1;
          sg_state_reg <= `DMA_SG_STATE_UPDATE_AW;
      end else if ((sg_next_reg[1:0]!=2'b00) && (sg_ctrl_reg[`DMA_SG_CTRL_EOC]==1'b0)) begin
          sg_pending_error <= 1'b1;
          sg_pending_error_code <= `DMA_ERR_DESC_ALIGN;
          sg_error_code_reg <= `DMA_ERR_DESC_ALIGN;
          sg_status_word <= make_status(1'b1,`DMA_ERR_DESC_ALIGN,sg_len_reg);
          sg_status_reg  <= make_status(1'b1,`DMA_ERR_DESC_ALIGN,sg_len_reg);
          sg_M_AWID    <= SG_AXI_ID;
          sg_M_AWADDR  <= sg_curdesc_reg + `DMA_SG_DESC_STATUS;
          sg_M_AWLEN   <= 'h0;
          sg_M_AWLOCK  <= 'h0;
          sg_M_AWSIZE  <= 3'h2;
          sg_M_AWBURST <= 2'b01;
          sg_M_AWVALID <= 1'b1;
          sg_state_reg <= `DMA_SG_STATE_UPDATE_AW;
      end else begin
          sg_data_go <= 1'b1;
          sg_state_reg <= `DMA_SG_STATE_EXECUTE;
      end
      end
   `DMA_SG_STATE_EXECUTE: begin
      if (data_error) begin
          sg_pending_error <= 1'b1;
          sg_pending_error_code <= data_error_code;
          sg_error_code_reg <= data_error_code;
      end
      if (data_done || (data_error && (data_busy==1'b0))) begin
          sg_data_go <= 1'b0;
          if (data_error==1'b0) begin
              sg_bytes_done_reg <= sg_bytes_done_reg + sg_len_reg;
          end
          if (sg_pending_error | data_error) begin
              sg_status_word <= make_status(1'b1,
                                            data_error ? data_error_code : sg_pending_error_code,
                                            sg_len_reg);
              sg_status_reg <= make_status(1'b1,
                                           data_error ? data_error_code : sg_pending_error_code,
                                           sg_len_reg);
          end else begin
              sg_status_word <= make_status(1'b0,`DMA_ERR_NONE,sg_len_reg);
              sg_status_reg  <= make_status(1'b0,`DMA_ERR_NONE,sg_len_reg);
          end
          sg_M_AWID    <= SG_AXI_ID;
          sg_M_AWADDR  <= sg_curdesc_reg + `DMA_SG_DESC_STATUS;
          sg_M_AWLEN   <= 'h0;
          sg_M_AWLOCK  <= 'h0;
          sg_M_AWSIZE  <= 3'h2;
          sg_M_AWBURST <= 2'b01;
          sg_M_AWVALID <= 1'b1;
          sg_timeout_cnt <= 32'h0;
          sg_state_reg <= `DMA_SG_STATE_UPDATE_AW;
      end
      end
   `DMA_SG_STATE_UPDATE_AW: begin
      if (sg_M_AWVALID & sg_awready) begin
          sg_M_AWVALID <= 1'b0;
          sg_M_WID     <= SG_AXI_ID;
          sg_M_WDATA   <= put_bus_word(sg_status_word,sg_curdesc_reg+`DMA_SG_DESC_STATUS);
          sg_M_WSTRB   <= get_word_strb(sg_curdesc_reg+`DMA_SG_DESC_STATUS);
          sg_M_WLAST   <= 1'b1;
          sg_M_WVALID  <= 1'b1;
          sg_timeout_cnt <= 32'h0;
          sg_state_reg <= `DMA_SG_STATE_UPDATE_W;
      end else if (sg_timeout_cnt>=AXI_TIMEOUT) begin
          sg_M_AWVALID <= 1'b0;
          sg_busy_reg <= 1'b0;
          sg_done_reg <= 1'b1;
          sg_error_reg <= 1'b1;
          sg_error_code_reg <= `DMA_ERR_TIMEOUT;
          sg_state_reg <= `DMA_SG_STATE_ERROR;
      end else begin
          sg_timeout_cnt <= sg_timeout_cnt + 1;
      end
      end
   `DMA_SG_STATE_UPDATE_W: begin
      if (sg_M_WVALID & sg_wready) begin
          sg_M_WVALID <= 1'b0;
          sg_M_BREADY <= 1'b1;
          sg_timeout_cnt <= 32'h0;
          sg_state_reg <= `DMA_SG_STATE_UPDATE_B;
      end else if (sg_timeout_cnt>=AXI_TIMEOUT) begin
          sg_M_WVALID <= 1'b0;
          sg_busy_reg <= 1'b0;
          sg_done_reg <= 1'b1;
          sg_error_reg <= 1'b1;
          sg_error_code_reg <= `DMA_ERR_TIMEOUT;
          sg_state_reg <= `DMA_SG_STATE_ERROR;
      end else begin
          sg_timeout_cnt <= sg_timeout_cnt + 1;
      end
      end
   `DMA_SG_STATE_UPDATE_B: begin
      if (M_BVALID & sg_M_BREADY) begin
          sg_M_BREADY <= 1'b0;
          sg_timeout_cnt <= 32'h0;
          if (M_BRESP[1] || (M_BID!=SG_AXI_ID)) begin
              sg_busy_reg <= 1'b0;
              sg_done_reg <= 1'b1;
              sg_error_reg <= 1'b1;
              sg_error_code_reg <= M_BRESP[1] ? `DMA_ERR_AXI_WRITE : `DMA_ERR_AXI_ID;
              sg_state_reg <= `DMA_SG_STATE_ERROR;
          end else if (sg_pending_error) begin
              sg_busy_reg <= 1'b0;
              sg_done_reg <= 1'b1;
              sg_error_reg <= 1'b1;
              sg_error_code_reg <= sg_pending_error_code;
              sg_state_reg <= `DMA_SG_STATE_ERROR;
          end else begin
              sg_desc_done_reg <= sg_desc_done_reg + 1;
              sg_state_reg <= `DMA_SG_STATE_CHAIN;
          end
      end else if (sg_timeout_cnt>=AXI_TIMEOUT) begin
          sg_M_BREADY <= 1'b0;
          sg_busy_reg <= 1'b0;
          sg_done_reg <= 1'b1;
          sg_error_reg <= 1'b1;
          sg_error_code_reg <= `DMA_ERR_TIMEOUT;
          sg_state_reg <= `DMA_SG_STATE_ERROR;
      end else begin
          sg_timeout_cnt <= sg_timeout_cnt + 1;
      end
      end
   `DMA_SG_STATE_CHAIN: begin
      sg_pending_error <= 1'b0;
      sg_pending_error_code <= `DMA_ERR_NONE;
      sg_fetch_error <= 1'b0;
      sg_fetch_index <= 3'h0;
      if ((sg_ctrl_reg[`DMA_SG_CTRL_EOC]==1'b1) || (sg_next_reg==32'h0)) begin
          sg_busy_reg <= 1'b0;
          sg_done_reg <= 1'b1;
          sg_error_reg <= 1'b0;
          sg_error_code_reg <= `DMA_ERR_NONE;
          sg_state_reg <= `DMA_SG_STATE_DONE;
      end else begin
          sg_curdesc_reg <= sg_next_reg;
          sg_M_ARID    <= SG_AXI_ID;
          sg_M_ARADDR  <= sg_next_reg;
          sg_M_ARLEN   <= 'd5;
          sg_M_ARLOCK  <= 'h0;
          sg_M_ARSIZE  <= 3'h2;
          sg_M_ARBURST <= 2'b01;
`ifdef AMBA_AXI_CACHE
          sg_M_ARCACHE <= 4'h0;
`endif
`ifdef AMBA_AXI_PROT
          sg_M_ARPROT  <= 3'h2;
`endif
`ifdef AMBA_AXI4
          sg_M_ARQOS   <= 4'h0;
          sg_M_ARREGION<= 4'h0;
`endif
          sg_M_ARVALID <= 1'b1;
          sg_timeout_cnt <= 32'h0;
          sg_state_reg <= `DMA_SG_STATE_FETCH_AR;
      end
      end
   `DMA_SG_STATE_DONE: begin
      sg_busy_reg <= 1'b0;
      sg_done_reg <= 1'b1;
      sg_data_go  <= 1'b0;
      if (DMA_GO==1'b0) begin
          sg_owned <= 1'b0;
          sg_done_reg <= 1'b0;
          sg_state_reg <= `DMA_SG_STATE_IDLE;
      end
      end
   `DMA_SG_STATE_ERROR: begin
      sg_busy_reg <= 1'b0;
      sg_done_reg <= 1'b1;
      sg_error_reg <= 1'b1;
      sg_data_go <= 1'b0;
      sg_M_ARVALID <= 1'b0;
      sg_M_RREADY  <= 1'b0;
      sg_M_AWVALID <= 1'b0;
      sg_M_WVALID  <= 1'b0;
      sg_M_BREADY  <= 1'b0;
      if (DMA_GO==1'b0) begin
          sg_owned <= 1'b0;
          sg_done_reg <= 1'b0;
          sg_error_reg <= 1'b0;
          sg_state_reg <= `DMA_SG_STATE_IDLE;
      end
      end
   default: begin
      sg_state_reg <= `DMA_SG_STATE_IDLE;
      sg_busy_reg <= 1'b0;
      sg_data_go <= 1'b0;
   end
   endcase
   end
   end
   //-----------------------------------------------------------
   function [31:0] get_bus_word;
      input [AXI_WIDTH_DA-1:0] data;
      input [31:0]             addr;
      integer                   shift_bits;
   begin
      shift_bits = (((addr & (AXI_WIDTH_DS-1)) >> 2) << 5);
      get_bus_word = data >> shift_bits;
   end
   endfunction
   //-----------------------------------------------------------
   function [AXI_WIDTH_DA-1:0] put_bus_word;
      input [31:0] word;
      input [31:0] addr;
      integer      shift_bits;
      reg [AXI_WIDTH_DA-1:0] word_ext;
   begin
      shift_bits = (((addr & (AXI_WIDTH_DS-1)) >> 2) << 5);
      word_ext = word;
      put_bus_word = word_ext << shift_bits;
   end
   endfunction
   //-----------------------------------------------------------
   function [AXI_WIDTH_DS-1:0] get_word_strb;
      input [31:0] addr;
      integer      shift_bytes;
   begin
      shift_bytes = (((addr & (AXI_WIDTH_DS-1)) >> 2) << 2);
      get_word_strb = ({AXI_WIDTH_DS{1'b0}} | 4'hF) << shift_bytes;
   end
   endfunction
   //-----------------------------------------------------------
   function [31:0] make_status;
      input        error;
      input [7:0]  code;
      input [31:0] length;
   begin
      make_status = {1'b1,error,1'b0,5'h0,code,length[15:0]};
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
   // synthesis translate_off
   always @ (posedge ACLK) begin
       if (DMA_EN&DMA_GO&(~sg_path_selected)) begin
           if (DMA_SRC[AXI_WIDTH_DSB-1:0]!==DMA_DST[AXI_WIDTH_DSB-1:0]) begin
               $display($time,,"%m src dst not aligned: 0x%X 0x%X",
                        DMA_SRC[AXI_WIDTH_DSB-1:0],DMA_DST[AXI_WIDTH_DSB-1:0]);
           end
       end
   end
   // synthesis translate_on
   //-----------------------------------------------------------
endmodule
//----------------------------------------------------------
// Revision history
//
// 2015.07.12: Started by Ando Ki.
// 2026.06.20: Added scatter-gather descriptor supervisor.
//----------------------------------------------------------
