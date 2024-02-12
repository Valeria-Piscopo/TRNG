module RO #(parameter int unsigned RO_LENGTH = 64)
   (
     input  logic                     RO_enable,
     output logic                     random_bit       
   );
    
    logic[RO_LENGTH - 1 : 0] out_inv;

    `ifndef SYNTHESIS
     int unsigned inv_delay[RO_LENGTH];    
    `endif
        
    genvar i;
    generate
        for (i = 0; i < RO_LENGTH; i++) begin
             (* keep = "true" *) INV inv_i( 
                .in((i == 0)? (out_inv[RO_LENGTH - 1] | RO_enable) : out_inv[i-1]),   
                .out(out_inv[i])
                ); /* synthesis keep */  
            
               `ifndef SYNTHESIS
                assign inv_i.delay = inv_delay[i];    
               `endif
        end
    endgenerate 

    assign random_bit = out_inv[RO_LENGTH - 1];


endmodule : RO