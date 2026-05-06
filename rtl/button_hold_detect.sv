// Detects when a button has been held for a number of cycles.
//
// Parameters:
// HOLD_CYCLES  - the duration of hold until held is set to high
//
// Ports:
// clk      - clock signal
// button   - button press signal
// held     - output signal

`timescale 1ns / 1ps

module button_hold_detect #(
    parameter int HOLD_CYCLES = 50_000_000
) (
    input  logic clk,
    input  logic button,
    output logic held
);

  localparam int CountMax = HOLD_CYCLES;
  localparam int CountWidth = $clog2(CountMax + 1);

  logic count_rst;
  logic count_enable;
  logic [CountWidth-1:0] count;
  initial held = '0;

  mod_n_counter #(
      .N(CountMax + 1),
      .WIDTH(CountWidth)
  ) u_counter (
      .clk(clk),
      .rst(count_rst),
      .enable(count_enable),
      .count(count)
  );

  assign count_enable = button & !held;
  assign count_rst = !button;

  always_comb
    if (count == CountWidth'(CountMax)) held = '1;
    else held = '0;

endmodule
