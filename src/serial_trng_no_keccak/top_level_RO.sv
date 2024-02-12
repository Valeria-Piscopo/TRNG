module top_level_RO #(
        parameter int unsigned N_STAGES = 32,
        parameter int unsigned RO_LENGTH = 64
    )
    (
        input  logic  RO_en,
        input  logic  dff_en,
        input  logic  rst_ni,      	
        input  logic  clk,
        output logic  random_bit
    );

    logic[N_STAGES - 1 : 0]  last_out, random_out;
    logic out_xor_tree;
    logic random_bit_s;

    `ifndef SYNTHESIS
     int unsigned inv_delay[N_STAGES][RO_LENGTH]; 
    `endif
    
    genvar i;
    generate
        for (i = 0; i < N_STAGES; i++) begin
            (* keep = "true" *) RO #(.RO_LENGTH(RO_LENGTH)) RO_i( 
                .RO_enable(RO_en), 
                .random_bit(last_out[i])
                ); /* synthesis keep */   
            
            `ifndef SYNTHESIS
             assign RO_i.inv_delay = inv_delay[i];
            `endif
        end
    endgenerate

    REG #(.NBITS(N_STAGES)) sampling_reg(
                .comb_in(last_out),
                .clk(clk),
                .rst_ni(rst_ni),
                .dff_en(dff_en),
                .sample_out(random_out)
            );

    assign out_xor_tree = ^random_out;

    REG #(.NBITS(1)) out_xor_reg(
            .comb_in(out_xor_tree),
            .clk(clk),
            .rst_ni(rst_ni),
            .dff_en(dff_en),
            .sample_out(random_bit_s)
        );

    assign random_bit = random_bit_s;

endmodule : top_level_RO
