module RO #(parameter int unsigned RO_LENGTH = 64)
   (
    `ifdef SIM
     input  int unsigned inv_delay[RO_LENGTH],    
    `endif
     input  logic                     RO_enable,
     output logic                     random_bit, 
     output logic[RO_LENGTH - 1 : 0]  parallel_out	       
   );
    
    logic[RO_LENGTH - 1 : 0] out_inv;
        
    genvar i;
    generate
        for (i = 0; i < RO_LENGTH; i++) begin
            INV inv_i( 
                `ifdef SIM
                .delay(inv_delay[i]),    
                `endif
                .in((i == 0)? (out_inv[RO_LENGTH - 1] | RO_enable) : out_inv[i-1]),   
                .out(out_inv[i])
                ); /* synthesis keep */                
        end
    endgenerate 

    assign parallel_out = out_inv;
    assign random_bit = out_inv[RO_LENGTH - 1];


endmodule : RO