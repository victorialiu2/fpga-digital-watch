// A simple counter that adds 1 to the current count,
// and wraps back to 0 after it reaches the end of the
// range. The range is [0, N - 1]
//
// Parameters:
// N      - max/modulo number (excluded from range)
// WIDTH  - number of bits needed to store N states
//
// Ports:
// clk      - clock signal
// rst      - reset pin, sets count to 0 when high
// enable   - only increment if enable is set to 1
// count    - holds current count

`timescale 1ns / 1ps

module mod_n_counter #(
    parameter int N = 4,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [WIDTH-1:0] count
);
  logic [WIDTH-1:0] next_count;
  logic [WIDTH-1:0] max = WIDTH'(N - 1);

  initial count = '0;

  always_ff @(posedge clk)
    if (rst) count <= '0;
    else if (enable) count <= next_count;

  always_comb
    if (count >= max) next_count = '0;
    else next_count = count + 1'd1;

endmodule
