/*
    7-segment decoder for a single digit
    designed for the Terasic DE10-Lite board
    
    Yves Acremann, 3.1.2021
    Pol Welter, 2022-03-15
*/ 

module SevenSegment3(    
    input [2:0]    input_i,
    output [6:0]            LED_o
    );
    
    always_comb
    begin
        case(input_i)
            3'b000: LED_o = 7'b1111111; //f
            3'b100: LED_o = 7'b1111111; //f
            3'b110: LED_o =7'b1111111; //f
            3'b010: LED_o = 7'b1111111; //f
            3'b001: LED_o = 7'b1111001; //f
            3'b101: LED_o = 7'b1111001; //f
            3'b011: LED_o = 7'b1111111; //f
            3'b111: LED_o = 7'b1111111; //f
            default: LED_o = 7'b1111111;
        endcase
    end    
endmodule

// comments on how to write the code
// number 0 is 1000000,
// letter F is 1111001,
// letter U is 10000001,
// letter 7'b1000111; //L