`timescale 1ps/1ps

module INV 
    (
     input logic            in,	      
     output logic           out   	       
   );

   `ifndef SYNTHESIS
    int unsigned    delay; 
    `endif

    always_comb begin
        `ifndef SYNTHESIS
          out <= #delay ~in;
        `else
          out <= ~in;
        `endif
    end

endmodule : INV
