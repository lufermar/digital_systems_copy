module fir_simple
    #(
        parameter logic signed [17:0] coef_b0 = 18'sd131071,
        parameter logic signed [17:0] coef_b1 = -18'sd131072,
        parameter logic signed [17:0] coef_a1 = 18'sd0,
        parameter inout_width = 16,
        parameter inout_decimal_width = 15,
        parameter internal_width = 18,
        parameter internal_decimal_width = 17
    )(
        input clk_i,
        input reset_i,
        input signed [15:0] data_i,
        output signed [15:0] data_o
    ); 

    parameter max = 2**(internal_width - 1) -1;
    parameter min = - 2**(internal_width - 1);

    logic signed [internal_width-1:0] input_pipeline1, input_pipeline2;
    logic signed [internal_width-1:0] output_pipeline1, output_pipeline2;
    logic signed [inout_width + internal_width - 1:0] mul_b0, mul_b1, mul_a1;
    logic signed [internal_width:0] sum1, sum2, sum3;
    logic signed [internal_width-1:0] sum_sat1, sum_sat2, sum_sat3;
    logic signed [inout_width-1:0] sum_sat;

    always_ff @(posedge clk_i) begin
        if (reset_i) begin
            input_pipeline1 <= {(internal_width){1'sd0}};
            input_pipeline2 <= {(internal_width){1'sd0}};
            output_pipeline1 <= {(internal_width){1'sd0}};
            output_pipeline2 <= {(internal_width){1'sd0}};
        end else begin
            input_pipeline1 <= data_i;
            input_pipeline2 <= input_pipeline1;
            output_pipeline1 <= sum_sat;
            output_pipeline2 <= output_pipeline1;
        end
    end

    always_comb begin
        mul_b0 = coef_b0 * input_pipeline1;
        mul_b1 = coef_b1 * input_pipeline2;
        mul_a1 = coef_a1 * output_pipeline2;

        sum1 = (internal_width+1)'(mul_b0 >> (inout_width -1));
        sum_sat1 = internal_width'(sum1);
        if (sum1 > max)
            sum_sat1 = max;
        if (sum1 < min)
            sum_sat1 = min;
        sum2 = (internal_width+1)'(mul_b1 >> (inout_width -1)) + sum_sat1;
        sum_sat2 = internal_width'(sum2);
        if (sum2 > max)
            sum_sat2 = max;
        if (sum2 < min)
            sum_sat2 = min;
        sum3 = (internal_width+1)'(mul_a1 >> (inout_width -1)) + sum_sat2;
        sum_sat3 = internal_width'(sum3);
        if (sum3 > max)
            sum_sat3 = max;
        if (sum3 < min)
            sum_sat3 = min;

        sum_sat = inout_width'(sum_sat3);
        if (sum_sat3 > 2**(inout_width - 1) - 1)
            sum_sat = 2**(inout_width - 1) - 1;
        if (sum_sat3 < - 2**(inout_width - 1))
            sum_sat = - 2**(inout_width - 1);

    end

    assign data_o = sum_sat;

endmodule