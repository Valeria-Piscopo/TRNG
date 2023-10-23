import constants_pkg::*;

module top_level #(
        parameter int unsigned N_STAGES,
        parameter int unsigned N_FIROs_GAROs,
        parameter int unsigned FIRO_LENGTH,
        parameter int unsigned GARO_LENGTH,
        parameter int unsigned INV_DELAY
        )
    (
        input  logic                   RO_en,
        input  logic                   dff_en,	       	
        input  logic                   clk,

        `ifndef SYNTHESIS
        input  logic                   startup_sig,     //just for simulation purpose
        `endif       

        output logic[N_STAGES - 1 : 0] random_out   
    );

genvar i;
generate
    for (i = 0; i < N_STAGES; i++) begin
        FiGaRO #(
        .N_FIROs_GAROs(N_FIROs_GAROs),
        .FIRO_LENGTH(FIRO_LENGTH), 
        .GARO_LENGTH(GARO_LENGTH),
        .INV_DELAY(INV_DELAY)) FiGaRO_stage_i( 
            .RO_en(RO_en),   
            .dff_en(dff_en),
            .clk(clk),

            `ifndef SYNTHESIS  
            .startup_sig(startup_sig),
            `endif

            .random_out_stage(random_out[i])
            );
    end
endgenerate

//State sampling?

endmodule : top_level