module top_level_RO #(
        parameter int unsigned N_STAGES = 32,
        parameter int unsigned RO_LENGTH = 64
        )
    (
        `ifdef SIM
         input  int unsigned inv_delay[N_STAGES][RO_LENGTH],    
        `endif
         input  logic                        RO_en,
         input  logic                        dff_en,	 
         input  logic                        rst_ni,      	
         input  logic                        clk,
         output logic                        random_bit,
         output logic[7 : 0]                 random_seq
    );

    logic[N_STAGES - 2 : 0]  last_out, random_out;
    logic[RO_LENGTH - 1 : 0] parallel_out[N_STAGES - 2 : 0];
    logic[N_STAGES - 2 : 0] transposed_parallel_out[RO_LENGTH - 1 : 0];
    logic out_xor_tree;
    logic[RO_LENGTH - 1 : 0] parallel_out_xor_tree, RO_clk;
    logic[7 : 0] random_seq_tmp1;
    logic[7 : 0] random_seq_tmp2;
    logic unused_port;
    
    genvar i;
    generate
        for (i = 0; i < N_STAGES - 1; i++) begin
            RO #(.RO_LENGTH(RO_LENGTH)) RO_i( 
                `ifdef SIM
                .inv_delay(inv_delay[i]),    
                `endif
                .RO_enable(RO_en), 
                .random_bit(last_out[i]),
                .parallel_out(parallel_out[i])
                ); /* synthesis keep */   
        end
    endgenerate

    RO #(.RO_LENGTH(RO_LENGTH)) sampler( 
                `ifdef SIM
                .inv_delay(inv_delay[N_STAGES-1]),    
                `endif
                .RO_enable(RO_en), 
                .random_bit(unused_port),
                .parallel_out(RO_clk)
    ); /* synthesis keep */   

    `ifndef PARALLEL_OUT 
        REG #(.NBITS(N_STAGES - 1)) sampling_reg(
                    .comb_in(last_out),
                    .clk(clk),
                    .rst_ni(rst_ni),
                    .dff_en(dff_en),
                    .sample_out(random_out)
                );

        assign out_xor_tree = ^random_out;

    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // I can directly use register file?
    REG #(.NBITS(1)) out_xor_reg(
                .comb_in(out_xor_tree),
                .clk(clk),
                .rst_ni(rst_ni),
                .dff_en(dff_en),
                .sample_out(random_bit)
            );
    `else 
        genvar n_inv_var, n_stages_var;
        generate
            for (n_inv_var = 0; n_inv_var < RO_LENGTH; n_inv_var++) begin
                for (n_stages_var = 0; n_stages_var < (N_STAGES - 1); n_stages_var++) begin
                    assign transposed_parallel_out[n_inv_var][n_stages_var] = parallel_out[n_stages_var][n_inv_var];
                end
                assign parallel_out_xor_tree[n_inv_var] = ^(transposed_parallel_out[n_inv_var]);
            end
        endgenerate

        //sampling with another RO --> agains deterministic jitter attacks
        
        REG #(.NBITS(8)) out_xor_reg(
            .comb_in(parallel_out_xor_tree[7 : 0]),
            .clk(RO_clk[0]),
            .rst_ni(rst_ni),
            .dff_en(dff_en),
            .sample_out(random_seq_tmp1)
        );

        REG #(.NBITS(8)) out_xor_reg2(
            .comb_in(parallel_out_xor_tree[RO_LENGTH - 1 : RO_LENGTH - 1 - 7]),
            .clk(RO_clk[1]),
            .rst_ni(rst_ni),
            .dff_en(dff_en),
            .sample_out(random_seq_tmp2)
        );

        assign random_seq = (random_seq_tmp1) ^ (random_seq_tmp2);
    
    `endif


endmodule : top_level_RO
