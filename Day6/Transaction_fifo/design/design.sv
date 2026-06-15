class trans_f;
rand bit rst_tb,wrenb_tb,rdenb_tb;
rand bit [7:0]data_in_tb;
bit [7:0]data_out_tb;
bit full,empty;


constraint c1 { 
                rst_tb dist {0:=8,1:=2};
                wrenb_tb dist {0:=2, 1:=8};  
                rdenb_tb dist  {0:=8, 1:=2};    
                data_in_tb dist {
                             8'hFF := 10,
                             8'hAA := 5,
                              8'h55 := 5};      
                                    };
function void display();
  $display("rst_tb=%0d wrenb_tb=%0b rdenb_tb=%0b din=%0h dout=%0h full=%0b empty=%0b ",
            rst_tb,wrenb_tb,rdenb_tb,data_in_tb,data_out_tb, full, empty );
endfunction
endclass
