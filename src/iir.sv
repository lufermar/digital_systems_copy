module iir 
    #(
        parameter timeconstant = 9
    )(
        input clk_i,
        input reset_i,
        input signed[15:0] data_i,
        output signed[15:0] data_o,
    ); 

    logic signed[15:0] delayed_input;
    logic signed[15:0] sum;
        
    always_ff @(posedge clk_i) begin
        delayed_input <= data_i;
    end

    always_comb begin
        sum = - delayed_input / (1 + timeconstant) + data_i;
    end

    assign data_o = sum;

endmodule