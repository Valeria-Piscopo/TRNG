module trng_keccak #(
    parameter int unsigned N_STAGES = 32,
    parameter int unsigned RO_LENGTH = 64
  )
    (
     // Common in signals
     input  logic               clk,
     input  logic               rst_n, 
     input  logic[1 : 0]        op_mode,
     // op_mode[0] = 1 TRNG
     // op_mode[1] = 1 KECCAK
     input logic               conditioning,
     // TRNG in signals
    `ifdef SIM
     input  int unsigned        inv_delay[N_STAGES][RO_LENGTH],    
    `endif
     input  logic               ack_key_read,

     // Keccak in signal
     input  logic[1599 : 0]     keccak_in,

     // TRNG out signals
     output logic               key_ready,
     output logic               flush_key_reg, //could be the interrupt??
     output logic[7 : 0]        key_out,

     // Keccak out signals
     output logic               status_d,
     output logic               status_de,
     output logic               keccak_intr,
     output logic[1599 : 0]     keccak_out

     // MUST BE ADDED 
     //output logic               trng_intr
   );


    logic trng_en_s, start_keccak_s;
    logic error_s, tot_fail_s, key_ready_s;
    logic error_after_cond, tot_fail_after_cond;
    logic[7 : 0] out_key_s;  
    logic[1599 : 0] out_sig;
    logic permutation_computed, status_d_s;
 
    // !!!!!!!!!!!
    // key_ready_s dopo un po' si dovrebbe abbassare se va come start di keccak ?

    trng #(.N_STAGES(N_STAGES), .RO_LENGTH(RO_LENGTH)) trng (
        `ifdef SIM
        .inv_delay(inv_delay),
        `endif
        .enable(op_mode[0]),
        .dff_en(dff_en_s),
        .clk(clk),
        .rst_n(rst_n),
        .ack_read(ack_key_read),
        .error(error_s),
        .total_fail(tot_fail_s),
        .out_key(out_key_s)
    );

    assign key_out = (key_ready_s)? out_key_s : 8'b0;

    //shift register oppure accesso al register file da parte di trng??
    
    keccak_dp i_keccak (
		.clk(clk),
		.rst_n(rst_n),
		.start_i(start_keccak_s), //timing degli op_mode gestito dall'esterno?
		.din((conditioning)? out_key_s : keccak_in),
        .ready_o(permutation_computed),
		.dout(out_sig)
	);

    health_test #(.NBITS(1600), .CUTOFF(589), .FAIL_THRESH(11)) test_after_keccak (
        .samples(out_sig),
        .clk(clk),
        .error(error_after_cond),
        .total_failure(tot_fail_after_cond)
    ); 
    // If errors after keccak, compute another key

    //Masking???
    //assign keccak_out = status_d_s? out_sig : 1600'b0;
    assign keccak_out = out_sig;

    CU top_CU (
      .op_mode(op_mode),
      .conditioning(conditioning),
      .rst_ni(rst_n),
      .clk_i(clk),
      //TRNG in
      .trng_error(error_s),
      .key_ack(ack_key_read),
      .total_failure(tot_fail_s),
      //Keccak in
      .keccak_error(error_after_cond),
      .ready_dpkeccak_i(permutation_computed),
      .total_failure_keccak(tot_fail_after_cond),
      //TRNG out
      .trng_en_o(trng_en_s),
      .trng_dff_en_o(dff_en_s),
      .key_flush_o(flush_key_reg),
      .rnd_ready_o(key_ready_s),
      //Keccak out
      .start_keccak_o(start_keccak_s),
      .status_d_kec(status_d_s),
      .status_de_kec(status_de),
      .keccak_intr(keccak_intr)
    );

    assign key_ready = key_ready_s;
    assign status_d = status_d_s;
endmodule : trng_keccak
