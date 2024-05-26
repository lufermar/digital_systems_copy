module iir 
    #(
        parameter timeconstant = 9
    )(
        input clk_i,
        input reset_i,
        input signed[15:0] data_i,
        output signed[15:0] data_o
    ); 

    logic signed[15:0] delayed_input_q, delayed_input_d, delayed_output_q;
    logic signed[15:0] sum;
    logic signed[15:0] factor = 1;
        
    always_ff @(posedge clk_i) begin
        if (reset_i) begin
            delayed_input_q <= 0;
            delayed_output_q <= 0;
        end else begin
            delayed_input_d <= data_i;
            delayed_input_q <= delayed_input_d;
            delayed_output_q <= sum;
        end
    end

    always_comb begin
        //sum = (- delayed_input_q * timeconstant + (1 + timeconstant) * data_i);
        sum = (- delayed_input_q * (1-2*timeconstant) + (1 + 2*timeconstant) * data_i)*factor - delayed_output_q;
    end

    assign data_o = sum;

endmodule