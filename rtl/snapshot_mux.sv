// Contains 3 counters, where count0 increases at every clock cycle, count1
// increments at count0 rollover, and count2 increments at count1 rollover.
// Can be paused, or reset.
//
// Parameters:
// N2       - max value of count2 (exclusive)
// N1       - max value of count1 (exclusive)
// N0       - max value of count0 (exclusive)
// W2       - number of bits for count2
// W1       - number of bits for count1
// W0       - number of bits for count0
//
// Ports:
// clk                - clock signal
// enable             - only increment if enable is set to 1
// rst                - reset signal (priority over enable)
// count2             - count2 signal
// count1             - count1 signal
// count0             - count0 signal

`timescale 1ns / 1ps

module snapshot_mux #(
    parameter int WIDTH = 1
) (
    input logic clk,
    input logic hold,
    input logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);

  logic [WIDTH-1:0] snapshot;
  initial snapshot = '0;
  assign q = (hold) ? snapshot : d;
  always_ff @(posedge clk) begin
    if (!hold) snapshot <= d;
  end

endmodule

