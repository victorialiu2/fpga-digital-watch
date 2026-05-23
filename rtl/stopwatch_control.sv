// the control logic of the stopwatch - switches between 2 planes of states:
//    - live/frozen display
//    - running/paused counter
// Additionally, handles reset logic.
// Assumes input toggle signals are single-cycle pulses.
//
// Parameters: none
//
// Ports:
// clk                - clock signal
// rise_start_stop    - toggle between run/pause state
// rise_lap           - toggle between live/frozen state
// counter_rst        - reset signal
// counter_enable     - run/pause counter state
// lap_hold           - live/frozen state (for lap)

`timescale 1ns / 1ps

module stopwatch_control (
    input  logic clk,
    input  logic rise_start_stop,
    input  logic rise_lap,
    output logic counter_rst,
    output logic counter_enable,
    output logic lap_hold
);

  logic [2:0] state, next_state;
  initial state = 3'b0;
  assign {counter_rst, counter_enable, lap_hold} = state;

  // prevent input signal when both inputs are high
  logic start_stop, lap;
  assign start_stop = rise_start_stop & !rise_lap;
  assign lap = rise_lap & !rise_start_stop;

  // NS logic
  // counter_rst
  assign next_state[2] = (state == 3'b000 & lap) ? 1'b1 : 1'b0;
  // counter_enable
  assign next_state[1] = (start_stop) ? !state[1] : state[1];
  // lap_hold
  assign next_state[0] = (state != 3'b000 & lap) ? !state[0] : state[0];

  always_ff @(posedge clk) begin
    state <= next_state;
  end

endmodule
