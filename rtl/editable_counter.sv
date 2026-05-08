// A counter that can increment up or down from 0 to a provided max value,
// pause counting. The increment can happen in 2 modes: via a tick signal,
// or inc and dec signal, depending on the edit mode.
//
// Parameters:
// N      - The maximum count value (exclusive, range: [0, N-1])
// WIDTH  - how many binary digits does N need
//
// Ports:
// clk                  - clock signal
// tick                 - tick signal (used in mode 1)
// edit_mode            - edit mode signal, toggle between the 2 modes
// inc                  - increment (used in mode 2)
// dec                  - decrement (used in mdoe 2)
// count [WIDTH-1:0]    - the count output

`timescale 1ns / 1ps

module editable_counter #(
    parameter int N = 60,
    parameter int WIDTH = 6
) (
    input logic clk,
    input logic tick,  // Count increments on tick when edit_mode is low
    input logic edit_mode,
    input logic inc,  // Count increments by one when edit_mode is high
    input logic dec,  // Count decrements by one when edit_mode is high
    output logic [WIDTH-1:0] count
);

  logic enable;
  logic up;
  up_down_counter #(
      .MAX  (N - 1),
      .WIDTH(WIDTH)
  ) u_counter (
      .clk(clk),
      .enable(enable),
      .up(up),
      .count(count)
  );

  wire inc_event = edit_mode && inc && !dec;
  wire dec_event = edit_mode && dec && !inc;
  wire tick_event = !edit_mode && tick;

  assign up = inc_event | tick_event;
  assign enable = inc_event | dec_event | tick_event;

endmodule
