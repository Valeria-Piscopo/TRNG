module trng_keccak_top 
  import trng_keccak_data_reg_pkg::*;
  import trng_keccak_ctrl_reg_pkg::*;
  import reg_pkg::*;
  import obi_pkg::*;  
(
	input logic clk_i,
	input logic rst_ni,
    //`ifdef SIM
    // input  int unsigned        inv_delay[N_STAGES][RO_LENGTH],    
    //`endif

	// AHB Slave interface (data memory)
	input 	    obi_req_t slave_req_i,
	output 	    obi_resp_t slave_resp_o,
    // APB interface (ctrl mem)
	input 	    reg_req_t reg_req_i,
    output 	    reg_rsp_t reg_rsp_o,
  
    output      flush_key_reg, //trng_intr_o?
	output 	    keccak_intr_o
);

   reg_req_t periph_req_i;   
   reg_rsp_t periph_rsp_o;
   
   trng_keccak_data_reg2hw_t reg_file_to_ip_data;
   trng_keccak_data_hw2reg_t ip_to_reg_file_data;   
   trng_keccak_ctrl_reg2hw_t reg_file_to_ip_ctrl;
   trng_keccak_ctrl_hw2reg_t ip_to_reg_file_ctrl;

	
   periph_to_reg #(
      .req_t(reg_pkg::reg_req_t),
      .rsp_t(reg_pkg::reg_rsp_t),
      .IW(1)
   ) periph_to_reg_i (
      .clk_i,
      .rst_ni,
      .req_i(slave_req_i.req),
      .add_i(slave_req_i.addr),
      .wen_i(~slave_req_i.we),
      .wdata_i(slave_req_i.wdata),
      .be_i(slave_req_i.be),
      .id_i('0),
      .gnt_o(slave_resp_o.gnt),
      .r_rdata_o(slave_resp_o.rdata),
      .r_opc_o(),
      .r_id_o(),
      .r_valid_o(slave_resp_o.rvalid),
      .reg_req_o(periph_req_i),
      .reg_rsp_i(periph_rsp_o)
   );


   keccak_data_reg_top #(
	.reg_req_t(reg_req_t),
	.reg_rsp_t(reg_rsp_t)
	) i_data_regfile (
		.clk_i,
		.rst_ni,
		.devmode_i(1'b1),
		// From the bus to regfile
		.reg_req_i(periph_req_i),
		.reg_rsp_o(periph_rsp_o),
		
		// Signals from regfile to keccak IP
		.reg2hw(reg_file_to_ip_data),
		.hw2reg(ip_to_reg_file_data) 
	);

   trng_keccak_ctrl_reg_top #(
	.reg_req_t(reg_req_t),
	.reg_rsp_t(reg_rsp_t)
	) i_ctrl_regfile (
		.clk(clk_i),
		.rst_ni(rst_ni),
		.devmode_i(1'b1),
		// From the bus to regfile
		.reg_req_i(reg_req_i),
		.reg_rsp_o(reg_rsp_o),		
		// Signals from regfile to keccak IP
		.reg2hw(reg_file_to_ip_ctrl),
		.hw2reg(ip_to_reg_file_ctrl) 
	);


     
   // wiring signals between control unit and ip
   logic op_mode;
   logic[1599 : 0] din_keccak, dout_keccak;
   logic[31 : 0]   out_key; 
   
   assign op_mode = {reg_file_to_ip_ctrl.keccak_en, reg_file_to_ip_ctrl.trng_en};
   assign din_keccak = reg_file_to_ip_data.keccak_din;	

	trng_keccak i_keccak_trng (
		.clk(clk_i),
		.rst_n(rst_ni),
        .op_mode(op_mode),
        .conditioning(reg_file_to_ip_ctrl.conditioning),
        .ack_key_read(reg_file_to_ip_ctrl.ack_key_read),
		.keccak_in(din_keccak),
        .key_ready(ip_to_reg_file_ctrl.status.trng.d),
        .flush_key_reg(flush_key_reg),
        .key_out(out_key),
		.status_d(ip_to_reg_file_ctrl.status.keccak.d),
		.status_de(ip_to_reg_file_ctrl.status.keccak.de),
		.keccak_intr(keccak_intr_o),
        .keccak_out(dout_keccak)
	);
   
    assign ip_to_reg_file_data.keccak_dout = dout_keccak;
    assign ip_to_reg_file_data.trng_dout = out_key;
endmodule : trng_keccak_top