// A counter that can increment up or down from 0 to a provided max value,
// and pause counting.
//
// Parameters:
// MAX    - the max value in decimal
// WIDTH  - how many binary digits does the max value need
//
// Ports:
// clk                - clock signal
// enable             - only increment if enable is set to 1
// up                 - increment up if up is set to 1, otherwise down
// count [WIDTH-1:0]  - the count output

`timescale 1ns / 1ps

module button_auto_repeat #(
    parameter int HOLD_CYCLES   = 50_000_000,
    // REPEAT_CYCLES must be smaller than HOLD_CYCLES
    parameter int REPEAT_CYCLES = 5_000_000
) (
    input  logic clk,
    input  logic button,
    output logic pulse
);
  logic rise;
  logic held;
  logic pulse_train;

  assign pulse = rise | (button & pulse_train);

  rising_edge_detector red (
      .clk(clk),
      .sig_in(button),
      .rise(rise)
  );
  button_hold_detect #(
      .HOLD_CYCLES(HOLD_CYCLES - REPEAT_CYCLES + 1)
  ) holdDetector (
      .clk(clk),
      .button(button),
      .held(held)
  );
  restartable_rate_generator #(
      .CYCLE_COUNT(REPEAT_CYCLES)
  ) repeatDetector (
      .clk (clk),
      .run (held),
      .tick(pulse_train)
  );
endmodule
