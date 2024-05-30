module iir 
    #(
        parameter logic signed[17:0] coef_b0 = 262143,
        parameter logic signed[17:0] coef_b1 = 0,
        parameter logic signed[17:0] coef_a1 = 0
    )(
        input clk_i,
        input reset_i,
        input signed[15:0] data_i,
        output signed[15:0] data_o
    ); 

    logic signed[17:0] input_pipeline1;
    logic signed[17:0] output_pipeline1;
    logic signed[33:0] mul_b0, mul_b1, mul_a1;
    logic signed[18:0] sum_mul;
    logic signed[17:0] sum;
        
    always_ff @(posedge clk_i) begin
        if (reset_i) begin
            input_pipeline1 <= 0;
            output_pipeline1 <= 0;
        end else begin
            input_pipeline1 <= data_i;
            output_pipeline1 <= sum;
        end
    end

    always_comb begin
        mul_b0 = coef_b0 * data_i;
        mul_b1 = coef_b1 * input_pipeline1;
        mul_a1 = coef_a1 * sum;
        sum_mul = 17'((mul_b0 + mul_b1 + mul_a1) >>> 17);
        sum = 16'(sum_mul);
        if (sum_mul > 2**15 - 1)
            sum = 2**15 - 1;
        if (sum_mul < - 2**15)
            sum = - 2**15;
        // output_data = coef_delayed_output * data_i;
        // output_data = data_i - delayed_input_q;
        // output_data = data_i + coef_delayed_input * delayed_input_q - coef_delayed_output * delayed_output_q;
    end

    assign data_o = 16'(sum >>> 1);

endmodule