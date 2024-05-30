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
    logic signed [inout_width + internal_width:0] sum;
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
        sum = (mul_b0 >>> (internal_decimal_width + 1)) + 
              (mul_b1 >>> (internal_decimal_width + 1)) - 
              (mul_a1 >>> (internal_decimal_width + 1));

        // Shifting right to adjust for the fractional bits
        // sum = sum_mul >>> 19; // This implicitly handles rounding/truncation

        // sum_sat = sum[internal_width-1:0];
        // Clipping logic
        if (sum > max) begin
            sum_sat = max;
        end else if (sum < min) begin
            sum_sat = min;
        end else begin
            sum_sat = sum[internal_width:0];
        end
    end

    // Assign the output, adjusting the bit-width to fit into 16 bits
    // assign data_o = sum_sat[internal_width-1:(internal_width - inout_width)]; // Truncate and fit to 16 bits
    assign data_o = sum_sat >>> (internal_decimal_width - inout_decimal_width);

endmodule

/**
 This module performs the multiplication and addition and saturates the
 result to the max. possible value (without wrapping).
 
 sum = signal_in*coeff + summand
 
**/
module MultiphyAddSaturated #(
    parameter num_of_bits_internal = 18,
    parameter num_of_bits_io       = 16 
)(
    input  logic signed[num_of_bits_io-1:0]       signal_in,
    input  logic signed[num_of_bits_internal-1:0] coeff,
    input  logic signed[num_of_bits_internal-1:0] summand,
    output logic signed[num_of_bits_internal-1:0] sum
);

    // the min / max value for the signed internal signals
    parameter max =  2**(num_of_bits_internal-1)-1;
    parameter min = -2**(num_of_bits_internal-1);
    // multiplier result:
    logic signed [num_of_bits_internal+num_of_bits_io-1:0] mult_out;
    // adder result: Needs an additional bit!
    logic signed [num_of_bits_internal:0] add_out;
    // the adder and multiplier
    assign mult_out = coeff * signal_in;
    assign add_out  = (num_of_bits_internal+1)'(mult_out >> (num_of_bits_io-1)) + summand;
    // saturation:
    always_comb begin
        sum = num_of_bits_internal'(add_out);
        if (add_out > max)
            sum = max;
        if (add_out < min)
            sum = min;
    end
endmodule