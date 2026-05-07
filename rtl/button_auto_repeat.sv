// When a button is pressed, a single 1-cycle pulse is sent.
// More pulses are sent after the button is held for a number of
// cycles, in a specified interval length.
//
// Parameters:
// HOLD_CYCLES      - length of press until the first pulse in the
//                    cycle is sent
// REPEAT_CYCLES    - interval between subsequent pulses
//
// Ports:
// clk      - clock signal
// button   - button signal
// pulse    - output pulse signal

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
