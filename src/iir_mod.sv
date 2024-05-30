module iir_mod
    #(
        parameter logic signed [17:0] coef_b0 = 18'sd262143,
        parameter logic signed [17:0] coef_b1 = 18'sd0,
        parameter logic signed [17:0] coef_a1 = 18'sd0
    )(
        input clk_i,
        input reset_i,
        input signed [15:0] data_i,
        output signed [15:0] data_o
    ); 

    logic signed [17:0] input_pipeline1;
    logic signed [17:0] output_pipeline1;
    logic signed [33:0] mul_b0, mul_b1, mul_a1;
    logic signed [34:0] sum_mul;
    logic signed [17:0] sum;

    always_ff @(posedge clk_i) begin
        if (reset_i) begin
            input_pipeline1 <= 18'sd0;
            output_pipeline1 <= 18'sd0;
        end else begin
            input_pipeline1 <= {data_i, 2'b00};
            output_pipeline1 <= sum;
        end
    end

    always_comb begin
        mul_b0 = coef_b0 * data_i;
        mul_b1 = coef_b1 * input_pipeline1;
        mul_a1 = coef_a1 * output_pipeline1;

        // Summing the products, making sure to extend the sign properly
        sum_mul = mul_b0 + mul_b1 - mul_a1;

        // Shifting right to adjust for the fractional bits
        sum = sum_mul[33:16]; // This implicitly handles rounding/truncation

        // Clipping logic
        if (sum > 18'sd32767) begin
            sum = 18'sd32767;
        end else if (sum < -18'sd32768) begin
            sum = -18'sd32768;
        end
    end

    // Assign the output, adjusting the bit-width to fit into 16 bits
    assign data_o = sum[17:2]; // Truncate and fit to 16 bits

endmodule