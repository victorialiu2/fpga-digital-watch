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

module editable_countdown #(
    parameter int MAX   = 59,
    parameter int WIDTH = 6
) (
    input logic clk,
    input logic clr,
    input logic tick,
    input logic edit_mode,
    input logic inc,
    input logic dec,
    output logic [WIDTH-1:0] count,
    output logic borrow_out
);
  logic enable, up;
  up_down_counter_rst #(
      .MAX  (MAX),
      .WIDTH(WIDTH)
  ) counter (
      .clk(clk),
      .rst(clr),
      .enable(enable),
      .up(up),
      .count(count)
  );

  wire inc_event = edit_mode & inc & !dec & !clr;
  wire dec_event = edit_mode & dec & !inc & !clr;
  wire tick_event = !edit_mode & tick & !clr;

  assign up = inc_event;
  assign enable = inc_event | dec_event | tick_event;

  assign borrow_out = (tick_event & count == 0) ? '1 : '0;
endmodule
