// Outputs a single high pulse when a button is held for a number
// of cycles.
//
// Parameters:
// HOLD_CYCLES  - the duration of hold until held is set to high
//
// Ports:
// clk      - clock signal
// button   - button press signal
// pulse    - pulse signal - is high only one cycle per hold

`timescale 1ns / 1ps

module button_hold_pulse #(
    parameter int HOLD_CYCLES = 50_000_000
) (
    input  logic clk,
    input  logic button,
    output logic pulse
);
  logic held;
  button_hold_detect #(
      .HOLD_CYCLES(HOLD_CYCLES)
  ) u_detect (
      .clk(clk),
      .button(button),
      .held(held)
  );

  rising_edge_detector u_detector (
      .clk(clk),
      .sig_in(held),
      .rise(pulse)
  );

endmodule
