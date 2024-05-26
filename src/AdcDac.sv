module AdcDac(
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
    
      
    logic reset;
    logic debounced_key;
    logic clk;
    logic tick;
    logic signed[15:0] data;
    logic signed[15:0] data_filtered;
    logic signed[15:0] data_iir;
    logic signed[15:0] data_fir;
    
    logic              adc_clk;        // SPI clk
    logic              adc_mosi;       // MOSI: always 1
    logic              adc_cnv;        // Start conversion (SPI CS)
    logic              adc_miso;       // MISO: The DAC data
    
    logic              dac_clk;        // SPI clock
    logic              dac_mosi;       // SPI MOSI
    logic              dac_cs;         // chip select
    logic              dac_reset_n;    // reset of the DAC
	 
	 
    
    assign reset = !KEY[0];
    assign clk = MAX10_CLK1_50;
	 
	 
/*     Debouncer #(50) debounce(
        .clk_i(clk),
        .reset_i(reset),
        .bouncing_i(KEY[1]),
        .debounced_o(debounced_key)
    ); */

    TickGen #(
    .DIVIDER(32)
    ) tickGen (
    .clk_i(clk),
    .reset_i(reset),
    .tick_o(tick)
    );
    //.toggle_i(debounced_key),
    AdcReader reader(
        .clk_i(clk),
        .reset_i(reset),
        .start_i(tick),
        .data_o(data),
        .spi_clk_o(adc_clk),
        .spi_mosi_o(adc_mosi),
        .cnv_o(adc_cnv),
        .spi_miso_i(adc_miso),
		 .is_idle_o()
    );
    
    DacWriter writer(
        .clk_i(clk),
        .reset_i(reset),
        .start_i(tick),
        .data_i(data_filtered),
        .spi_clk_o(dac_clk),
        .spi_mosi_o(dac_mosi),
        .spi_cs_o(dac_cs),
        .dac_reset_no(dac_reset_n),
		  .is_idle_o()
    );
	 
	 iir #(
		.timeconstant(27)
	 ) iir(
		.clk_i(tick),
		.reset_i(reset_i),
		.data_i(data),
		.data_o(data_iir)
	 );
    
    // the wireing:
    assign ARDUINO_IO[0] = dac_cs;
	 assign ARDUINO_IO[1] = dac_clk;
    assign ARDUINO_IO[2] = dac_mosi;
    assign ARDUINO_IO[3] = dac_reset_n;
    
    assign ARDUINO_IO[4] = adc_cnv;
    assign ARDUINO_IO[5] = adc_clk;
    assign ARDUINO_IO[6] = adc_mosi;
    assign adc_miso = ARDUINO_IO[7];

        
    always_comb begin
        if (!SW[0]) begin
            data_filtered = 16'b0;
        end
        else begin
            if (!SW[1]) begin
                data_filtered = data;
            end
            else begin
                if (!SW[2]) begin 
                    data_filtered = 16'b0;//data_fir;
                end
                else begin
                    data_filtered = data_iir;//data_iir;
                end
            end
        end
    end
    SevenSegment0 digit0(SW[2:0], HEX0[6:0]);
    assign HEX0[7] = 1; // turn dot off
    SevenSegment1 digit1(SW[2:0], HEX1[6:0]);
    assign HEX1[7] = 1; // turn dot off
    SevenSegment2 digit2(SW[2:0], HEX2[6:0]);
    assign HEX2[7] = 1; // turn dot off
    SevenSegment3 digit3(SW[2:0], HEX3[6:0]);
    assign HEX2[7] = 1; // turn dot off
	 assign HEX3[7] = 1; // turn dot off
    
endmodule
