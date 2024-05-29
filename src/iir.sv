module iir 
    #(
        parameter logic signed[17:0] coef_delayed_input = -245231,
        // parameter logic signed[17:0] coef_delayed_output = 131072
        parameter logic signed[17:0] coef_delayed_output = 58982
    )(
        input clk_i,
        input reset_i,
        input signed[15:0] data_i,
        output signed[15:0] data_o
    ); 

    logic signed[17:0] delayed_input_q, delayed_input_d;
    logic signed[17:0] delayed_output_q, delayed_output_d;
    logic signed[33:0] mul;
        
    always_ff @(posedge clk_i) begin
        if (reset_i) begin
            delayed_input_q <= 0;
        end else begin
            delayed_input_d <= data_i;
            delayed_input_q <= delayed_input_d;
            delayed_output_d <= data_o;
            delayed_output_q <= delayed_output_d;
        end
    end

    always_comb begin
        mul = data_i;
        // output_data = coef_delayed_output * data_i;
        // output_data = data_i - delayed_input_q;
        // output_data = data_i + coef_delayed_input * delayed_input_q - coef_delayed_output * delayed_output_q;
    end

    assign data_o = 16'(mul >> 18);

endmodule