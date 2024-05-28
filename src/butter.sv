module butter 
    #(
        parameter timeconstant = 9
    )(
        input clk_i,
        input reset_i,
        input signed[15:0] data_i,
        output signed[15:0] data_o
    ); 

    logic signed[15:0] delayed_input_d1, delayed_input_d2; 
    logic signed[15:0] delayed_output_d1, delayed_output_d2, output_q;
    logic signed[15:0] sum;
        
    always_ff @(posedge clk_i) begin
        if (reset_i) begin
            delayed_input_d1 <= 0;
            delayed_input_d2 <= 0;
            delayed_output_d1 <= 0;
            delayed_output_d2 <= 0;
            output_q <= 0;
        end else begin
            delayed_input_d1 <= data_i;
            delayed_input_d2 <= delayed_input_d1;
            delayed_output_d1 <= output_q;
            delayed_output_d2 <= delayed_output_d1;
            output_q <= sum;

        end
    end

    always_comb begin
        sum = data_i * 1 / 100000 + delayed_input_d1 * 1/50000 + delayed_input_d2 * 1/100000 - delayed_output_d1 * -19999/10000 - delayed_output_d2 * 9999/10000;
    end

    assign data_o = output_q;

endmodule