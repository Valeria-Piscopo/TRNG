module trng #(
    parameter int unsigned N_STAGES = 32,
    parameter int unsigned RO_LENGTH = 64
  )
    (
    `ifdef SIM
     input  int unsigned inv_delay[N_STAGES][RO_LENGTH],    
    `endif
     input  logic               enable, 
     input  logic               dff_en, 
     input  logic               clk,
     input  logic               rst_n, 
     input  logic               ack_read,
     output logic               error,
     output logic               total_fail,
     output logic[7 : 0]        out_key 
   );

   logic enable_dp_s;
   logic[7 : 0] random_seq;
   logic rnd_bit;

  
  top_level_RO #(.N_STAGES(N_STAGES), .RO_LENGTH(RO_LENGTH)) entropy_src (
    `ifdef SIM
     .inv_delay(inv_delay),
    `endif
    //.RO_en(enable_dp_s), 
    //enable_dp_s può essere usato per regolare esattamente la durata 
    //Dell'enable nel caso in cui non sia così da input 
    .RO_en(enable),
    .dff_en(dff_en),
    .rst_ni(rst_n),
    .clk(clk),
    .random_bit(rnd_bit),
    .random_seq(random_seq)
  ); 


  health_test #(.NBITS(8), .CUTOFF(589), .FAIL_THRESH(11)) health_comp (
    .samples(random_seq),
    .clk(clk),
    .error(error),
    .total_failure(total_fail)
  );

  assign out_key = random_seq; //mask with rnd_ready?
endmodule : trng
