import constants_pkg::*;

module GaRO #(
        parameter int unsigned GARO_LENGTH,
        parameter int unsigned INV_DELAY,
        parameter poly_GARO prime_poly_GARO
        )
   
   (
     input logic   RO_enable,
     `ifndef SYNTHESIS
     input logic   startup_sig,     //just for simulation purpose
     `endif       
     output logic[GARO_LENGTH - 1 : 0]  random_out      
   );

    logic[GARO_LENGTH - 1 : 0] in_next_inv; //output XOR
    logic[GARO_LENGTH - 1 : 0] out_inv;     //output INV

    genvar i;
    generate
        for (i = 0; i < GARO_LENGTH; i++) begin
            `ifdef SYNTHESIS
                INV #(INV_DELAY) inv_i( 
                    .in((i == 0)? ((in_next_inv[GARO_LENGTH-1])) : ((i == GARO_LENGHT - 1)? (in_next_inv[i-1] & RO_enable) : in_next_inv[i-1])),   
                    .out(out_inv[i])
                    );

                //prime_poly(0) must be equal 0 because no XOR
                XOR xor_i(
                    .in1(out_inv[i]),
                    .in2((prime_poly_GARO[GARO_LENGTH - i - 1] == 1)? in_next_inv[GARO_LENGTH-1] : 1'b0),
                    .out(in_next_inv[i])
                );     
            `else

               INV #(INV_DELAY) inv_i( 
                    .in((i == 0)? (((in_next_inv[GARO_LENGTH-1]) | startup_sig))  :  ((i == GARO_LENGHT - 1)? (in_next_inv[i-1] & RO_enable) : in_next_inv[i-1])),   
                    .out(out_inv[i])
                    );

                //prime_poly(0) must be equal 0 because no XOR
                XOR xor_i(
                    .in1(startup_sig | out_inv[i]),
                    .in2((prime_poly_GARO[GARO_LENGTH - i - 1] == 1)? (in_next_inv[GARO_LENGTH-1] | startup_sig) : 1'b0),
                    .out(in_next_inv[i])
                ); 
            `endif
        end
    endgenerate


    assign random_out = in_next_inv;

endmodule : GaRO