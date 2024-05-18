

module FilterStateMachine #(
    parameter TIMER_W = 16 // bit depth of the timer #do we need this?
  )(  
    input logic clk_i,
    input logic [2:0] state_i, // 4 states: OFF, IDLE, IIR, FFR

    output logic unsigned [TIMER_W-1:0] state_o  // two things: connection to correct file and print state in screen
  );
  
  typedef enum logic [1:0] {
    OFF,   // FPGA is invisible
    IDLE,  // FPGA lets info pass, no interference
    IIR,   // FPGA applies IIR filter
    FIR   // FPGA applies FFR filter
  } state_e;

  typedef struct packed {
    state_e state;
      } state_t;
  
  state_t state_q, state_d;
  
  // the flipflops
  always_ff @(posedge clk_i) begin
    if (!state_i[0]) begin
      state_q.state   <= OFF;
    end else begin
      state_q  <= state_d;
    end
  end // always_ff
  
  
  // next state logic
  always_comb begin
    // defaults:
    state_d.state   = state_q.state;
    
    case(state_q.state)
      OFF: begin
        if (state_i[0]) begin
            if (state_i[1] * state_i[2]) state_d.state = IIR;
            if (state_i[1] * !state_i[2]) state_d.state = FIR;
            if (!state_i[1]) state_d.state = IDLE;
        end
      end
      IDLE: begin
        if (!state_i[0]) state_d.state = OFF;
        if (state_i[0]) begin
            if (state_i[1] * state_i[2]) state_d.state = IIR;
            if (state_i[1] * !state_i[2]) state_d.state = FIR;
        end
      end
      IIR: begin
        if (!state_i[0]) state_d.state = OFF;
        if (state_i[0]) begin
            if (!state_i[1]) state_d.state = IDLE;
            if (state_i[1] * !state_i[2]) state_d.state = FIR;
        end
      end
      
      FIR: begin
        if (!state_i[0]) state_d.state = OFF;
        if (state_i[0]) begin
            if (!state_i[1]) state_d.state = IDLE;
            if (state_i[1] * state_i[2]) state_d.state = IIR;
        end
      end
      
      
      default: state_d.state = state_q.state; // it's always a good idea to add this!
    endcase
  end // next-state logic
  
  
  // the output
  assign state_o = //signal to be implemented

endmodule
