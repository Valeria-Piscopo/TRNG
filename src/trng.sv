module trng #(
    parameter int unsigned N_STAGES = 32,
    parameter int unsigned RO_LENGTH = 64
  )
    (
     input  logic               enable,
     input  logic               clk,
     input  logic               rst_n, 
     input  logic               ack_read,
     output logic               key_ready,
     output logic[31 : 0]       out_key,
     output logic               trng_intr 
   );

   logic enable_dp_s, error_s, tot_fail_s, dff_en_s, flush_reg_s;
   logic[7 : 0] random_seq;
   logic rnd_bit;

   `ifdef SIM
    int unsigned inv_delay[N_STAGES][RO_LENGTH];  
    assign entropy_src.inv_delay = inv_delay;
   `endif
  
  top_level_RO #(.N_STAGES(N_STAGES), .RO_LENGTH(RO_LENGTH)) entropy_src (
    //.RO_en(enable_dp_s), 
    //enable_dp_s può essere usato per regolare esattamente la durata 
    //Dell'enable nel caso in cui non sia così da input 
    .RO_en(enable),
    .dff_en(dff_en_s),
    .rst_ni(rst_n),
    .clk(clk),
    .random_bit(rnd_bit),
    .random_seq(random_seq)
  ); 


  health_test #(.NBITS(8), .CUTOFF(589), .FAIL_THRESH(11)) health_comp (
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
