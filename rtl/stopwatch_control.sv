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
  initial {counter_rst, counter_enable, lap_hold} = 3'b0;

  // prevent input signal when both inputs are high
  logic start_stop, lap;
  assign start_stop = rise_start_stop & !rise_lap;
  assign lap = rise_lap & !rise_start_stop;

  logic stopped_and_live;
  assign stopped_and_live = !counter_enable & !lap_hold;

  always_ff @(posedge clk) begin
    counter_enable <= (start_stop) ? !counter_enable : counter_enable;
    lap_hold <= (lap & !stopped_and_live) ? !lap_hold : lap_hold;
    counter_rst <= (lap & stopped_and_live) ? '1 : '0;
  end

endmodule
