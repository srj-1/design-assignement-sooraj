`timescale 1ns/1ps

class transaction;
    
    rand bit        sg_mode;
    rand bit [31:0] src_addr;
    rand bit [31:0] dest_addr;
    rand bit [31:0] transfer_bytes;
    rand bit [7:0]  chunk_size;
    rand bit [31:0] sg_desc_addr;

    
    constraint c_addr {
        src_addr       inside {[32'h1000 : 32'h1FFF]};
        dest_addr      inside {[32'h2000 : 32'h2FFF]};
        sg_desc_addr   inside {[32'h4000 : 32'h4FFF]};
        transfer_bytes inside {[16:256]};
        chunk_size     inside {4, 8, 16};
    }

   
    function transaction copy();
        transaction trans = new();
        trans.sg_mode        = this.sg_mode;
        trans.src_addr       = this.src_addr;
        trans.dest_addr      = this.dest_addr;
        trans.transfer_bytes = this.transfer_bytes;
        trans.chunk_size     = this.chunk_size;
        trans.sg_desc_addr   = this.sg_desc_addr;
        return trans;
    endfunction
endclass
