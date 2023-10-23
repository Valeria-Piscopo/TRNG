import constants_pkg::*;

module FiRO #(
        parameter int unsigned  FIRO_LENGTH, 
        parameter int unsigned  INV_DELAY,
        parameter poly_FIRO     prime_poly_FIRO
        ) 
   (
     input logic                        RO_enable,

     `ifndef SYNTHESIS
     input logic                        startup_sig,     // just for simulation purpose
     `endif     

     output logic[FIRO_LENGTH - 1 : 0]  random_out 	       
   );

    logic[FIRO_LENGTH - 1 : 0] out_inv; // output of INV
    logic[FIRO_LENGTH : 0]     in2_xor; // second XOR input

    assign in2_xor[0] = out_inv[FIRO_LENGTH-1];

    // order of XORs from right to left
    // order of INVs from left to right
    genvar i;
    generate
        for (i = 0; i < FIRO_LENGTH; i++) begin

            `ifdef SYNTHESIS
            
                INV #(INV_DELAY) inv_i( 
                        .in((i == 0)? (in2_xor[FIRO_LENGTH] & RO_enable) : out_inv[i-1]),   
                        .out(out_inv[i])
                        );

                //prime_poly_FIRO(0) must be equal 0 because no XOR
                XOR xor_i(
                    .in1((prime_poly_FIRO[i] == 1'b1)? startup_sig : 1'b0),
                    .in2(in2_xor[FIRO_LENGTH - 1 - i]),
                    .out(in2_xor[FIRO_LENGTH - 1 - i + 1])
                    );

            `else

                INV #(INV_DELAY) inv_i( 
                        .in((i == 0)? ((in2_xor[FIRO_LENGTH] | startup_sig) & RO_enable) : (out_inv[i-1] | startup_sig)),   
                        .out(out_inv[i])
                        );

                //prime_poly(0) must be equal 0 because no XOR
                XOR xor_i(
                    .in1((prime_poly_FIRO[i] == 1'b1)? (out_inv[i] | startup_sig) : 1'b0),
                    .in2(in2_xor[FIRO_LENGTH - 1 - i] | startup_sig),
                    .out(in2_xor[FIRO_LENGTH - 1 - i + 1])
                    );

            `endif
        end
    endgenerate


    //RO_enable effect also on output??
    assign random_out = out_inv;

endmodule : FiRO