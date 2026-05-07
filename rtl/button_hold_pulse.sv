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
