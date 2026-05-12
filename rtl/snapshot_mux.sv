// A 2x1 multiplexer that assigns the output to the input when hold is low,
// and when hold is high, it assigns the output to the input of the previous
// clock cycle.
//
// Parameters:
// WIDTH - how many bits the I and O signals need
//
// Ports:
// clk                - clock signal
// hold               - hold signal (mux switch)
// d                  - input signal
// q                  - output signal

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

