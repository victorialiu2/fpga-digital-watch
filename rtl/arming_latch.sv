// A module that imitates an arming latch.
// arm signal sets the output to high.
// disarm signal sets the output to low, and overrides the arm signal.
//
// Parameters: none
//
// Ports:
// clk      - clock signal
// arm      - enable signal
// diarm    - disable signal
// armed    - output signal

`timescale 1ns / 1ps

module arming_latch (
    input  logic clk,
    input  logic arm,
    input  logic disarm,
    output logic armed
);

  initial armed = '0;
  always_ff @(posedge clk) begin
    armed <= armed;
    if (disarm) armed <= '0;
    else if (arm) armed <= '1;
  end

endmodule
