`timescale 1ns/1ps

interface axi_dma_if(
    input logic ACLK,
    input logic ARESETn
);

    // IRQ
    logic IRQ;

    // DMA CONTROL
    logic [31:0] DMA_BNUM;
    logic [7:0]  DMA_CHUNK;
    logic [31:0] DMA_DST;
    logic        DMA_EN;
    logic        DMA_GO;
    logic [31:0] DMA_SRC;

    // DMA STATUS
    logic        DMA_BUSY;
    logic        DMA_DONE;
    logic        DMA_ERROR;
    logic [7:0]  DMA_ERROR_CODE;

    // SCATTER-GATHER CONTROL
    logic [31:0] SG_DESC_ADDR;
    logic        SG_MODE;

    // SCATTER-GATHER STATUS
    logic        SG_BUSY;
    logic [31:0] SG_BYTES_DONE;
    logic [31:0] SG_CURDESC;
    logic [31:0] SG_CUR_CTRL;
    logic [31:0] SG_CUR_DST;
    logic [31:0] SG_CUR_LEN;
    logic [31:0] SG_CUR_SRC;
    logic [31:0] SG_CUR_STATUS;
    logic [31:0] SG_DESC_DONE;
    logic        SG_DONE;
    logic        SG_ERROR;
    logic [7:0]  SG_ERROR_CODE;
    logic [31:0] SG_NEXTDESC;
    logic [7:0]  SG_STATE;

    // CSR AXI SLAVE (S_*)
    logic [31:0] S_AWADDR;
    logic [1:0]  S_AWBURST;
    logic [7:0]  S_AWID;
    logic [3:0]  S_AWLEN;
    logic [1:0]  S_AWLOCK;
    logic [2:0]  S_AWSIZE;
    logic        S_AWVALID;
    logic        S_AWREADY;
    logic [31:0] S_WDATA;
    logic [7:0]  S_WID;
    logic        S_WLAST;
    logic [3:0]  S_WSTRB;
    logic        S_WVALID;
    logic        S_WREADY;
    logic [7:0]  S_BID;
    logic [1:0]  S_BRESP;
    logic        S_BVALID;
    logic        S_BREADY;
    logic [31:0] S_ARADDR;
    logic [1:0]  S_ARBURST;
    logic [7:0]  S_ARID;
    logic [3:0]  S_ARLEN;
    logic [1:0]  S_ARLOCK;
    logic [2:0]  S_ARSIZE;
    logic        S_ARVALID;
    logic        S_ARREADY;
    logic [31:0] S_RDATA;
    logic [7:0]  S_RID;
    logic        S_RLAST;
    logic [1:0]  S_RRESP;
    logic        S_RVALID;
    logic        S_RREADY;

    // DMA AXI MASTER (M_*)
    logic [31:0] M_ARADDR;
    logic [1:0]  M_ARBURST;
    logic [3:0]  M_ARID;
    logic [3:0]  M_ARLEN;
    logic [1:0]  M_ARLOCK;
    logic [2:0]  M_ARSIZE;
    logic        M_ARVALID;
    logic        M_ARREADY;
    logic [31:0] M_RDATA;
    logic [3:0]  M_RID;
    logic        M_RLAST;
    logic [1:0]  M_RRESP;
    logic        M_RVALID;
    logic        M_RREADY;
    logic [31:0] M_AWADDR;
    logic [1:0]  M_AWBURST;
    logic [3:0]  M_AWID;
    logic [3:0]  M_AWLEN;
    logic [1:0]  M_AWLOCK;
    logic [2:0]  M_AWSIZE;
    logic        M_AWVALID;
    logic        M_AWREADY;
    logic [31:0] M_WDATA;
    logic [3:0]  M_WID;
    logic        M_WLAST;
    logic [3:0]  M_WSTRB;
    logic        M_WVALID;
    logic        M_WREADY;
    logic [3:0]  M_BID;
    logic [1:0]  M_BRESP;
    logic        M_BVALID;
    logic        M_BREADY;
    logic [3:0]  M_MID;

endinterface
