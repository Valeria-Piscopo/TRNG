module CU
    (
     // Common inputs
     input  logic[1 : 0] op_mode,
     // op_mode[0] = 1 TRNG
     // op_mode[1] = 1 KECCAK
     input  logic       conditioning,
     input  logic       rst_ni,
     input  logic       clk_i,

     // TRNG inputs        
     input  logic	trng_error,
     input  logic       key_ack,
     input  logic       total_failure,

     // Keccak inputs
     input logic        ready_dpkeccak_i, 
     input  logic       keccak_error,
     input  logic       total_failure_keccak,

     // TRNG outputs
     output logic       trng_en_o,
     output logic       trng_dff_en_o,
     output logic       key_flush_o, // The flush must be done "manually" from hw side
     output logic       rnd_ready_o,
     output logic       trng_intr,

     // Keccak outputs
     output logic       start_keccak_o,
     output logic       status_d_kec,
     output logic       status_de_kec,
     output logic       keccak_intr
   );

   typedef enum {IDLE, BIST, ES32, WAIT, DEAD} state_trng;
   typedef enum {WAIT_START, DO_PERMUTATION, PERMUTATION_FINISHED} state_keccak;
   state_trng curr_state_trng, next_state_trng;
   state_keccak curr_state_keccak, next_state_keccak;

    // latency = 1 ck x N (depends on how many parallel bits generates the TRNG)
    // worst case = 32
    // best case = 1
    localparam int latency = 1;

    //counter size changes depending on latency
    logic[4:0] counter_BIST;
    logic[4:0] counter_WAIT;
    logic[4:0] counter_keccak;

    logic trng = 0;
    logic keccak = 0;
    logic keccak_flag_trng = 0;

    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            curr_state_trng <= IDLE;
            curr_state_keccak <= WAIT_START;
            counter_BIST <= 0;
            counter_keccak <= 0;
            trng <= 0;
            keccak <= 0;
        end else begin
            if (!total_failure) begin
                    if (curr_state_trng == BIST) begin 
                        //if error, restart
                        if(trng_error) begin
                            counter_BIST <= 0;
                        end else begin
                            counter_BIST <= counter_BIST + 1;
                        end
                        counter_WAIT <= 0;
                    end else if (curr_state_trng == WAIT) begin 
                        counter_WAIT <= counter_WAIT + 1;
                        counter_BIST <= 0;
                    end else begin
                        counter_WAIT <= 0;
                        counter_BIST <= 0;
                    end	 
                curr_state_trng <= next_state_trng;   
            end else begin
                curr_state_trng <= DEAD;
            end

            if ( next_state_keccak == DO_PERMUTATION) begin
	            counter_keccak <= counter_keccak +1;
	        end else begin
	           counter_keccak <= 0;
	        end 
	        curr_state_keccak <= next_state_keccak;
        end
        //quanto durano i segnali di enable?
    end 

    // Despite of the state I'm in, I want to clear the registers containing the key as soon as it is read
    // and if I have a total failure emergency I need to be in the DEAD state (unrecoverable)

    // GESTIRE RICHIESTA DI CHIAVE QUANDO TRNG STA ANCORA LAVORANDO
    always_comb begin

        case(curr_state_trng)
          IDLE: begin
              trng_intr <= 0;
              if(op_mode[0]) begin
                  trng_en_o  <= 1;
                  key_flush_o <= 1;
                  rnd_ready_o  <= 0;
                  trng_dff_en_o     <= 1;
                  next_state_trng   <= BIST;
              end else begin
                next_state_trng <= IDLE;
              end
          end

          BIST: begin
              // 2 is an arbitrary choice 
              if (counter_BIST == (latency*10)) begin
                  next_state_trng   <= WAIT;
              end else begin
                  next_state_trng   <= BIST;
              end
          end

          ES32: begin
              if(trng_error) begin
                  rnd_ready_o <= 0;
                  trng_intr <= 0;
                  next_state_trng  <= BIST;
              end else if(key_ack) begin
                  key_flush_o <= 1;
                  rnd_ready_o  <= 0;
                  trng_intr <= 0;
                  next_state_trng   <= WAIT;
             end else begin
                 key_flush_o <= 0;
                 trng_intr   <= 1;
                 rnd_ready_o  <= 1;
                 if(conditioning) begin
                  keccak_flag_trng = 1;
                 end
                 next_state_trng  <= ES32;
             end

             trng_en_o   <= 1;
             trng_dff_en_o  <= 1;
           end

           //depends on latency of the system, if 32 bits of randomness ready in one clock cycle, state not even needed
         WAIT: begin
             if(trng_error) begin
                 next_state_trng  <= BIST;
             end
             else if(counter_WAIT == (latency)) begin
                 next_state_trng  <= ES32;
             end else begin
                 next_state_trng  <= WAIT;
             end
               
             trng_en_o   <= 1;
             trng_dff_en_o  <= 1;
             rnd_ready_o   <= 0;
             if(key_ack) begin
                 key_flush_o <= 1;
             end else begin
                 key_flush_o <= 0;
             end
         end

         DEAD: begin
             next_state_trng   <= DEAD;
             trng_en_o  <= 0;
             trng_dff_en_o <= 0;
             rnd_ready_o  <= 0;
             trng_intr   <= 1;
             key_flush_o <= 1;
         end    

         default: begin
            next_state_trng    <= BIST;
            trng_en_o   <= 0;
            trng_dff_en_o <= 0;
            rnd_ready_o   <= 0;
            trng_intr   <= 0;
            key_flush_o  <= 0; 
         end
        endcase

        case (curr_state_keccak)
    	  WAIT_START : begin
    	        keccak_intr <= 0;
    	        if ((op_mode == 2'b10 || keccak_flag_trng) && ready_dpkeccak_i) begin
    	           start_keccak_o <= 1;
    	           next_state_keccak <= DO_PERMUTATION;
    	        end else begin
    	           start_keccak_o <= 0;
    	           next_state_keccak <= WAIT_START;	      
    	        end
    	    end
          DO_PERMUTATION : begin
                start_keccak_o <= 0;
                status_d_kec <= 0;
                status_de_kec <=0;
                //keccak_intr <= 0;
                if (counter_keccak == 24) begin
                   //din_keccak_o <= 0;
                   next_state_keccak <= PERMUTATION_FINISHED;
                end else begin
                   next_state_keccak <= DO_PERMUTATION;
                end
          end
	      PERMUTATION_FINISHED : begin
	            start_keccak_o <= 0;
                if(!(keccak_error || total_failure_keccak)) begin
	                status_d_kec <= 1;
	                status_de_kec <= 1;
	                keccak_intr <= 1;
	                next_state_keccak <= WAIT_START;
                end else begin
                    next_state_keccak <= DO_PERMUTATION;
                end
          end 
	       default : begin
	            start_keccak_o <= 0;
	            status_d_kec <= 0;
   	            status_de_kec <=0;
   	            //keccak_intr <= 0;
   	            next_state_keccak <= WAIT_START;
   	       end
           endcase
    end
endmodule : CU
