// A counter that can increment up or down from 0 to a provided max value,
// pause counting. The increment can happen in 2 modes: via a tick signal,
// or inc and dec signal, depending on the edit mode. Unlike editable_counter.sv,
// this decrements on a tick, and can be reset.
//
// Parameters:
// MAX      - The maximum count value, range: [0, Max])
// WIDTH    - how many binary digits does N need
//
// Ports:
// clk                  - clock signal
// clr                  - clear signal
// tick                 - tick signal (used in mode 1)
// edit_mode            - edit mode signal, toggle between the 2 modes
// inc                  - increment (used in mode 2)
// dec                  - decrement (used in mdoe 2)
// count [WIDTH-1:0]    - the count output
// borrow_out           - is high if the subtraction requires borrowing a 10
//                        (on count == 0)


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
