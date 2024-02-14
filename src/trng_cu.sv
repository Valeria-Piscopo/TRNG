module trng_cu
    (   
     input  logic   rst_ni, //global reset
     input  logic   clk_i,
     input  logic   enable_i, //enable TRNG, supposing a pulse          
     input  logic	error_i,
     input  logic   ack_read_i,
     input  logic   total_failure,
     output logic   enable_dp_o,
     output logic   dff_en_o,
     output logic   flush_regs_o,
     output logic   rnd_ready_o,
     output logic   trng_intr   
   );

    typedef enum {IDLE, BIST, ES32, WAIT, DEAD} state_trng;
    state_trng curr_state, next_state;

    // latency = 1 ck x N (depends on how many parallel bits generates the TRNG)
    // worst case = 32
    // best case = 1
    localparam int latency = 1;
    
    //counter size changes depending on latency
    logic[4:0] counter_BIST;
    logic[4:0] counter_WAIT;

    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin    
            curr_state <= IDLE;
            counter_BIST <= 0;
        end else if(!total_failure || (curr_state == IDLE)) begin
            if (curr_state == BIST) begin 
                //if error, restart
                if(error_i) begin
                    counter_BIST <= 0;
                end else begin
                    counter_BIST <= counter_BIST + 1;
                end
                counter_WAIT <= 0;
            end 
            else if (curr_state == WAIT) begin 
                counter_WAIT <= counter_WAIT + 1;
                counter_BIST <= 0;
            end else begin
                counter_WAIT <= 0;
                counter_BIST <= 0;
            end	 
            curr_state <= next_state;   
        end else begin
            curr_state <= DEAD;
        end
    end 
    //quanto durano i segnali di enable?

    // Despite of the state I'm in, I want to clear the registers containing the key as soon as it is read
    // If I have a total failure emergency I need to be in the DEAD state (unrecoverable)

    // GESTIRE RICHIESTA DI CHIAVE QUANDO TRNG STA ANCORA LAVORANDO
    always_comb begin
     case(curr_state)
        IDLE: begin
            if(enable_i) begin
                trng_intr <= 0;
                rnd_ready_o  <= 0;
                enable_dp_o  <= 1;
                flush_regs_o <= 1;
                dff_en_o     <= 1;
                next_state   <= BIST;
             end else begin
                trng_intr <= 0;
                rnd_ready_o  <= 0;
                enable_dp_o <= 0;
                flush_regs_o <= 0;
                dff_en_o <= 0;
                next_state <= IDLE;
            end
        end

        BIST: begin
            // 10 is an arbitrary choice 
            if (counter_BIST == (latency*10)) begin
                next_state   <= WAIT;
                // AGGIUNTO DOPO
                trng_intr    <= 0;
                rnd_ready_o  <= 0;
                enable_dp_o  <= 1;
                flush_regs_o <= 1;
                dff_en_o     <= 1;
                //
            end else begin
                // AGGIUNTO DOPO
                trng_intr <= 0;
                rnd_ready_o  <= 0;
                enable_dp_o  <= 1;
                flush_regs_o <= 1;
                dff_en_o     <= 1;
                //
                next_state   <= BIST;
            end
        end

        ES32: begin
            if(error_i) begin
                trng_intr   <= 0;
                flush_regs_o <= 1;
                rnd_ready_o   <= 0;
                enable_dp_o   <= 1;
                dff_en_o      <= 1;
                next_state  <= BIST;
            end else if(ack_read_i) begin
                trng_intr    <= 0;
                flush_regs_o <= 1;
                rnd_ready_o  <= 0;
                enable_dp_o   <= 1;
                dff_en_o      <= 1;
                next_state   <= WAIT;
            end else begin
                flush_regs_o <= 0;
                trng_intr    <= 1;
                rnd_ready_o  <= 1;
                enable_dp_o   <= 1;
                dff_en_o      <= 1;
                next_state   <= ES32;
            end
        end

        //depends on latency of the system, if 32 bits of randomness ready in one clock cycle, state not even needed
        WAIT: begin
            if(error_i) begin
                next_state  <= BIST;
            end
            else if(counter_WAIT == (latency)) begin
                next_state  <= ES32;
            end else begin
                next_state  <= WAIT;
            end

            enable_dp_o   <= 1;
            dff_en_o      <= 1;
            rnd_ready_o   <= 0;
            trng_intr     <= 0;
            if(ack_read_i) begin
                flush_regs_o <= 1;
            end else begin
                flush_regs_o <= 0;
            end
        end

        DEAD: begin
            next_state   <= DEAD;
            enable_dp_o  <= 0;
            dff_en_o     <= 0;
            rnd_ready_o  <= 0;
            flush_regs_o <= 1;
            trng_intr    <= 1;
        end    
       
        default: begin
           next_state    <= BIST;
           enable_dp_o   <= 0;
           dff_en_o      <= 0;
           rnd_ready_o   <= 0;
           flush_regs_o  <= 0; 
           trng_intr     <= 0;
        end

     endcase
    end

endmodule : trng_cu
