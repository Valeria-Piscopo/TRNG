module REG #(
        parameter int unsigned NBITS
        ) 
   (
     input  logic[NBITS - 1 : 0]  comb_in,
     input  logic                 clk,
     input  logic                 rst_ni,
     input  logic                 dff_en,
     output logic[NBITS - 1 : 0]  sample_out	       
   );


    always_ff @(posedge clk) begin
      if(dff_en == 1 && rst_ni) begin
          sample_out <= comb_in;
      end 
    end

endmodule
