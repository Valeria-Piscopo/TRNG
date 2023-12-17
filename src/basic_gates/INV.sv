`timescale 1ps/1ps

module INV 
    (
     input logic            in,	      
     output logic           out   	       
   );

   `ifdef SIM
    int unsigned    delay; 
    `endif

    always_comb begin
        `ifdef SIM
          out <= #delay ~in;
        `else
          out <= ~in;
        `endif
    end

endmodule : INV