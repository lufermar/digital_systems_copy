module FilterStateMachine (  
    input logic clk_i,
    input logic [2:0] state_i, // 4 states: OFF, IDLE, IIR, FFR
    input signed [15:0] data_i, // input data
    output signed [15:0] data_o  // two things: connection to correct file and print state in screen
  );
  
  typedef enum logic [1:0] {
    OFF,   // FPGA is invisible
    IDLE,  // FPGA lets info pass, no interference
    IIR,   // FPGA applies IIR filter
    FIR   // FPGA applies FFR filter
  } state_e;

  typedef struct packed {
    state_e state;
    logic unsigned [15:0] data_filtered;
  } state_t;
  
  state_t state_q, state_d;
  
  // the flipflops
  always_ff @(posedge clk_i) begin
    if (!state_i[0]) begin
      state_q.state  <= OFF;
      state_q.data_filtered <= data_i;
    end else begin
      state_q  <= state_d;
    end
  end // always_ff
  
  
  // next state logic
  always_comb begin
    // defaults:
    state_d = state_q;
    
    case(state_q.state)
      OFF: begin
        if (state_i[0]) begin
            if (state_i[1] * state_i[2]) begin
              state_d.state = IIR;
              state_d.data_filtered = data_i;
            end
            if (state_i[1] * !state_i[2]) begin
              state_d.state = FIR;
              state_d.data_filtered = data_i;
            end
            if (!state_i[1]) begin
              state_d.state = IDLE;
              state_d.data_filtered = data_i;
            end
        end else begin
            state_d.data_filtered = data_i;
        end
      end
      IDLE: begin
        if (!state_i[0]) begin
          state_d.state = OFF;
          state_d.data_filtered = data_i;
        end
        if (state_i[0]) begin
            if (state_i[1] * state_i[2]) begin
              state_d.state = IIR;
              state_d.data_filtered = data_i;
            end
            if (state_i[1] * !state_i[2]) begin
              state_d.state = FIR;
              state_d.data_filtered = data_i;
            end
        end
      end
      IIR: begin
        if (!state_i[0]) begin
          state_d.state = OFF;
          state_d.data_filtered = data_i;
        end
        if (state_i[0]) begin
            if (!state_i[1]) begin
              state_d.state = IDLE;
              state_d.data_filtered = data_i;
            end
            if (state_i[1] * !state_i[2]) begin
              state_d.state = FIR;
              state_d.data_filtered = data_i;
            end
        end
      end
      
      FIR: begin
        if (!state_i[0]) state_d.state = OFF;
        if (state_i[0]) begin
            if (!state_i[1]) state_d.state = IDLE;
            if (state_i[1] * state_i[2]) state_d.state = IIR;
        end else begin
            state_d.data_filtered = data_i;
        end
      end
      
      
      default: state_d = state_q; // it's always a good idea to add this!
    endcase
  end // next-state logic
  
  
  // the output
  assign data_o = data_i;

endmodule
