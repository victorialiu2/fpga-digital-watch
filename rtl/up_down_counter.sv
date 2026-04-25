// A counter that can incremenet up or down from 0 to a provided max value,
// and pause counting. Range includes the max value.
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

module up_down_counter #(
    parameter int MAX   = 2,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic enable,
    input logic up,
    output logic [WIDTH-1:0] count
);
  logic [WIDTH-1:0] next_count;
  always_ff @(posedge clk) if (enable) count <= next_count;

  // adding ' avoids 32-bit wide default length
  initial count = '0;
  // avoid 32-bit wide int MAX, translate it to Max and explicitly adjust width
  localparam logic [WIDTH-1:0] Max = WIDTH'(MAX);
  always_comb
    if (up)
      if (count < Max) next_count = count + 1'd1;
      else next_count = '0;
    else if (count > '0) next_count = count - 1'd1;
    else next_count = Max;
endmodule
