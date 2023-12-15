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
     output logic               trng_intr,
     output logic[31 : 0]       key_out,

     // Keccak out signals
     output logic               status_d,
     output logic               status_de,
     output logic               keccak_intr,
     output logic[1599 : 0]     keccak_out
   );

    logic trng_en_s, start_keccak_s, flush_key_reg_s;
    logic error_s, tot_fail_s, key_ready_s;
    logic error_after_cond, tot_fail_after_cond;
    logic[31 : 0] out_key_s;  
    logic[1599 : 0] out_sig;
    logic permutation_computed, status_d_s;
    
    
    trng #(.N_STAGES(N_STAGES), .RO_LENGTH(RO_LENGTH)) i_trng (
        `ifdef SIM
        .inv_delay(inv_delay),
        `endif
        .enable(op_mode[0]),
        .clk(clk),
        .rst_n(rst_n),
        .ack_read(ack_key_read),
        .key_ready(key_ready_s),
        .out_key(out_key_s),
        .trng_intr(trng_intr)
    );

    assign key_ready = conditioning? status_d_s: key_ready_s;
    assign key_out = conditioning? out_sig[31 : 0] : out_key_s;
    
    keccak i_keccak (
		.clk(clk),
		.rst_n(rst_n),
		.start(conditioning? key_ready_s : op_mode[1]), //timing degli op_mode gestito dall'esterno?
		.din(conditioning? out_key_s : keccak_in),
		.dout(out_sig),
		.status_d(status_d_s),
		.status_de(status_de),
		.keccak_intr(keccak_intr)
	);

    //Masking???
    //assign keccak_out = status_d_s? out_sig : 1600'b0;
    assign keccak_out = out_sig;
    assign status_d = status_d_s;

    //health_test #(.NBITS(1600), .CUTOFF(589), .FAIL_THRESH(11)) test_after_keccak (
    //.samples(out_sig),
    //.clk(clk),
    //.error(error_after_cond),
    //.total_failure(tot_fail_after_cond)
    //);

    // 1) GESTIRE error_after_cond/tot_fail_after_cond


endmodule : trng_keccak
