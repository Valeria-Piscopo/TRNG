import constants_pkg::*;

module FiGaRO #(
        parameter int unsigned N_FIROs_GAROs,
        parameter int unsigned FIRO_LENGTH,
        parameter int unsigned GARO_LENGTH,
        parameter int unsigned INV_DELAY
        )
    (
        input  logic  RO_en,	
        input  logic  clk,

        `ifndef SYNTHESIS
        input  logic  startup_sig,     //just for simulation purpose
        `endif

        input  logic  dff_en,       
        output logic  random_out_stage	       
    );
    
    typedef logic[N_FIROs_GAROs - 1 : 0][FIRO_LENGTH - 1 : 0] parallel_stage_firo;
    typedef logic[N_FIROs_GAROs - 1 : 0][GARO_LENGTH - 1 : 0] parallel_stage_garo;

    parallel_stage_firo random_out_FiRO;
    parallel_stage_garo random_out_GaRO;
    parallel_stage_firo out_state_sample_FiRO;
    parallel_stage_garo out_state_sample_GaRO;

    genvar i;
    generate
        for (i = 0; i <  N_FIROs_GAROs; i++) begin
            FiRO #(.FIRO_LENGTH(FIRO_LENGTH), .INV_DELAY(INV_DELAY), .prime_poly_FIRO(polyFIRO_array[i])) FiRO_stage_i( 
                .RO_enable(RO_en),  

                `ifndef SYNTHESIS  
                .startup_sig(startup_sig),
                `endif

                .random_out(random_out_FiRO[i])
                );
            
            REG #(.NBITS(FIRO_LENGTH)) FiRO_sample_i(
                .comb_in(random_out_FiRO[i]),
                .clk(clk),
                .dff_en(dff_en),
                .sample_out(out_state_sample_FiRO[i])
            );
            
            GaRO #(.GARO_LENGTH(GARO_LENGTH), .INV_DELAY(INV_DELAY), .prime_poly_GARO(polyGARO_array[i])) GaRO_stage_i( 
                .RO_enable(RO_en), 

                `ifndef SYNTHESIS  
                .startup_sig(startup_sig),
                `endif  

                .random_out(random_out_GaRO[i])
                );

            REG #(.NBITS(GARO_LENGTH)) GaRO_sample_i(
                .comb_in(random_out_GaRO[i]),
                .clk(clk),
                .dff_en(dff_en),
                .sample_out(out_state_sample_GaRO[i])
            );

        end
    endgenerate

    assign random_out_stage = ^{out_state_sample_FiRO, out_state_sample_GaRO};

endmodule : FiGaRO