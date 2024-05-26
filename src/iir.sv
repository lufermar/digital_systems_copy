module iir 
    #(
        parameter timeconstant = 9
    )(
        input clk_i,
        input reset_i,
        input signed[15:0] data_i,
        output signed[15:0] data_o
    ); 

    logic signed[15:0] delayed_input_q, delayed_input_d;
    logic signed[15:0] sum;
        
    always_ff @(posedge clk_i) begin
        if (reset_i) begin
            delayed_input_q <= 0;
        end else begin
            delayed_input_d <= data_i;
            delayed_input_q <= delayed_input_d;
        end
    end

    always_comb begin
        sum = (- delayed_input_q * timeconstant + (1 + timeconstant) * data_i);
    end

    assign data_o = sum;

endmodule