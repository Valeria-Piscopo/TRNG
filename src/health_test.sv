module health_test #(
        parameter int unsigned NBITS,
        parameter int unsigned CUTOFF,
        parameter int unsigned FAIL_THRESH
       )
    (
     input  logic[NBITS - 1 : 0]  samples,
     input  logic                 enable,
     input  logic                 clk,	       
     output logic                 error,
     output logic                 total_failure 	       
   );

    logic stuck_at_0, stuck_at_1;
    logic error_adapt = 0;
    logic tot_fail_s = 0;
    (* keep = "true" *) int unsigned acc = 0;
    int unsigned cnt = 0;
    int unsigned consec_error_cnt = 0;

    assign stuck_at_1 = &samples;
    assign stuck_at_0 = &(~samples);

    always_ff @(posedge clk) begin
            if(enable) begin
            // window of 1024 samples
            if(cnt < 1024) begin
                // new value in shift register accumulated
                acc <= acc + samples[0];
                cnt <= cnt + 1;
            end else begin
                if(acc > CUTOFF || acc < (1024 - CUTOFF)) begin
                    error_adapt <= 1'b1;
                end else begin
                    error_adapt <= 1'b0;
                end 

                acc <= 0;
                cnt <= 0;   
            end 

            if(stuck_at_0 || stuck_at_1 || error_adapt) begin
                consec_error_cnt <= consec_error_cnt + 1;

                if(consec_error_cnt == FAIL_THRESH) begin
                   tot_fail_s <= 1'b1;
                end
            end else begin
                consec_error_cnt <= 0;
                tot_fail_s <= 1'b0;
            end
            end
    end

    assign total_failure = tot_fail_s;
    assign error = (stuck_at_0 | stuck_at_1 | error_adapt) & (~tot_fail_s);

endmodule : health_test
