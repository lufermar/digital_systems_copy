
// Here we define the inputs / outputs
module quartus_proj(
    input           MAX10_CLK1_50,  // 50 HMz clock
    input  [1:0]    KEY,            // Buttons
    inout  [9:0]    ARDUINO_IO,     // Header pins
    output [9:0]    LEDR,           // LEDs
    input  [9:0]    SW,             // Switches
    output [7:0]    HEX0,           // 7-segment dieplay
    output [7:0]    HEX1,           // 7-segment dieplay
    output [7:0]    HEX2,           // 7-segment dieplay
    output [7:0]    HEX3
);
    
	 // Connect the LEDs 0 and 1 to the switches 0 and 1
    SevenSegment0 digit0(SW[2:0], HEX0[6:0]);
    assign HEX0[7] = 1; // turn dot off
    SevenSegment1 digit1(SW[2:0], HEX1[6:0]);
    assign HEX1[7] = 1; // turn dot off
    SevenSegment2 digit2(SW[2:0], HEX2[6:0]);
    assign HEX2[7] = 1; // turn dot off
    SevenSegment3 digit3(SW[2:0], HEX3[6:0]);
    assign HEX2[7] = 1; // turn dot off
	 assign HEX3[7] = 1; // turn dot off

    FilterStateMachine #(.TIMER_W(TIMER_W))timerStateMachine(
    .clk_i(clk),
    .state_i(reset),
    .state_o(state_o)
  );

endmodule
