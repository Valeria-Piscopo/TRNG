module trng #(
    parameter int unsigned N_STAGES = 32,
    parameter int unsigned RO_LENGTH = 64,
    parameter int unsigned N_BITS_KEY = 32
  )
    (
        input  logic                       enable,
        input  logic                       clk,
        input  logic                       rst_n, 
        input  logic                       ack_read,
        output logic                       key_ready,
        output logic[N_BITS_KEY - 1 : 0]   out_key,
        output logic                       trng_intr
   );

   logic enable_dp_s, error_s, tot_fail_s, dff_en_s, flush_reg_s, rnd_ready_s;
   logic[N_BITS_KEY - 1 : 0] random_seq;
   logic rnd_bit_s;

   `ifndef SYNTHESIS
    int unsigned inv_delay[N_STAGES][RO_LENGTH];  
    assign entropy_src.inv_delay = inv_delay;
   `endif
  
  top_level_RO #(.N_STAGES(N_STAGES), .RO_LENGTH(RO_LENGTH)) entropy_src ( 
    .RO_en(enable),
    .dff_en(dff_en_s),
    .rst_ni(rst_n),
    .clk(clk),
    .random_bit(rnd_bit_s)
  ); 

  SHIFT_REG #(.NBITS(N_BITS_KEY)) shift_key_reg(
    .in_bit(rnd_bit_s),
    .clk(clk),
    .dff_en(dff_en_s),
    .rst_ni(rst_n),
    .sample_out(random_seq)
   );

   health_test #(.NBITS(N_BITS_KEY), .CUTOFF(589), .FAIL_THRESH(11)) health_comp (
   .samples(random_seq),
   .clk(clk),
   .error(error_s),
   .total_failure(tot_fail_s)
    );
 
  trng_cu CU_comp (
    .rst_ni(rst_n),
    .clk_i(clk),
    .enable_i(enable),
    .error_i(error_s),
    .ack_read_i(ack_read),
    .total_failure(tot_fail_s),
    .enable_dp_o(enable_dp_s),
    .dff_en_o(dff_en_s),
    .flush_regs_o(flush_reg_s),
    .rnd_ready_o(rnd_ready_s),
    .trng_intr(trng_intr)
  );

  
  assign out_key = (rnd_ready_s && (!flush_reg_s))? random_seq : 32'b0;
  assign key_ready = rnd_ready_s;
  
endmodule : trng
