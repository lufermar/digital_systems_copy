module TickGen
    #(
        parameter DIVIDER = 50,
        parameter FREQ_DIGITS_STEP_N = 3
    )(
        input clk_i,
        input reset_i, 
        input toggle_i, 
        
        output tick_o     // 1 for one clock cycle every DIVIDER cycles
    );

    logic unsigned [23:0] counter_r;
    logic unsigned [23:0] divider_r = 24'(DIVIDER); 
/* 
    always_ff @(posedge reset_i, posedge toggle_i) begin
        if (reset_i) begin
            divider_r <= 24'(DIVIDER);
        end else if (divider_r < 24'(DIVIDER *(10**FREQ_DIGITS_STEP_N) )) begin
            divider_r <= divider_r*10;
        end else begin
            divider_r <= 24'(DIVIDER);
        end
    end */

    always_ff @(posedge clk_i)
    begin
        if (reset_i)
            counter_r <= 0;
        else
            if (counter_r < divider_r)
                counter_r <= counter_r + 24'd1;
            else
                counter_r <= 0;
    end // ff

    assign tick_o = (counter_r == 0);

endmodule
