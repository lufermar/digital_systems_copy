module please_work
    #(
        parameter logic signed [17:0] coef_b0 = 17'sd32767,
        parameter logic signed [17:0] coef_b1 = -17'sd32768,
        parameter logic signed [17:0] coef_a1 = 17'sd0,
        parameter inout_width = 16,
        parameter inout_decimal_width = 15,
        parameter internal_width = 18,
        parameter internal_decimal_width = 17,
        parameter extended_width = 36 // Extended width to handle intermediate products
    )(
        input clk_i,
        input reset_i,
        input signed [15:0] data_i,
        output signed [15:0] data_o
    );
    parameter max = 2**(internal_width - 1) - 1;
    parameter min = -2**(internal_width - 1);
    logic signed [internal_width-1:0] input_pipeline1, input_pipeline2;
    logic signed [internal_width-1:0] output_pipeline1, output_pipeline2;
    logic signed [extended_width-1:0] mul_b0, mul_b1, mul_a1;
    logic signed [extended_width:0] sum;
    logic signed [internal_width-1:0] sum_sat;
    always_ff @(posedge clk_i) begin
        if (reset_i) begin
            input_pipeline1 <= {(internal_width){1'sd0}};
            input_pipeline2 <= {(internal_width){1'sd0}};
            output_pipeline1 <= {(internal_width){1'sd0}};
            output_pipeline2 <= {(internal_width){1'sd0}};
        end else begin
            input_pipeline1 <= {data_i, {(internal_decimal_width - inout_decimal_width){1'b0}}};
            input_pipeline2 <= input_pipeline1;
            output_pipeline1 <= sum_sat;
            output_pipeline2 <= output_pipeline1;
        end
    end
    always_comb begin
        mul_b0 = coef_b0 * {data_i, {(internal_decimal_width - inout_decimal_width){1'b0}}};
        mul_b1 = coef_b1 * input_pipeline2;
        mul_a1 = coef_a1 * output_pipeline2;
        // Summing the products, making sure to extend the sign properly
        sum = (mul_b0 >>> (internal_decimal_width)) + (mul_b1 >>> (internal_decimal_width)) - (mul_a1 >>> (internal_decimal_width));
        // Clipping logic
        if (sum > max) begin
            sum_sat = max;
        end else if (sum < min) begin
            sum_sat = min;
        end else begin
            sum_sat = sum[internal_width-1:0]; // Ensure sum fits into the internal width
        end
    end
    // Assign the output, adjusting the bit-width to fit into 16 bits
    assign data_o = sum_sat[internal_width-1:(internal_width - inout_width)]; // Truncate and fit to 16 bits
endmodule