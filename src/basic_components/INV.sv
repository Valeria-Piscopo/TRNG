`timescale 1ps/1ps

module INV 
    (
     //`ifdef SIM
      input int unsigned    delay,    
     //`endif

     input logic            in,	      
     output logic           out   	       
   );

    always_comb begin
        //`ifdef SIM
          out <= #delay ~in;
        //`else
        //  out <= ~in;
        //`endif
    end

endmodule : INV