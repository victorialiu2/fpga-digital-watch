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
// rst                - reset signal (priority over enable)
// enable             - only increment if enable is set to 1
// count2 [W2-1:0]    - count2 signal
// count1 [W1-1:0]    - count1 signal
// count0 [W0-1:0]    - count0 signal

`timescale 1ns / 1ps

module cascade_counter #(
    parameter int N2 = 3,
    parameter int N1 = 4,
    parameter int N0 = 5,
    // Output port widths
    parameter int W2 = 2,
    parameter int W1 = 2,
    parameter int W0 = 3
) (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [W2-1:0] count2,
    output logic [W1-1:0] count1,
    output logic [W0-1:0] count0
);
  localparam logic [W1-1:0] MaxN1 = W1'(N1 - 1);
  localparam logic [W0-1:0] MaxN0 = W0'(N0 - 1);
  logic N0Rollover, N1Rollover;

  mod_n_counter #(
      .N(N2),
      .WIDTH(W2)
  ) counterN2 (
      .clk(clk),
      .rst(rst),
      .enable(N1Rollover),
      .count(count2)
  );

  mod_n_counter #(
      .N(N1),
      .WIDTH(W1)
  ) counterN1 (
      .clk(clk),
      .rst(rst),
      .enable(N0Rollover),
      .count(count1)
  );

  mod_n_counter #(
      .N(N0),
      .WIDTH(W0)
  ) counterN0 (
      .clk(clk),
      .rst(rst),
      .enable(enable),
      .count(count0)
  );

  assign N0Rollover = enable & (count0 == MaxN0);
  assign N1Rollover = N0Rollover & (count1 == MaxN1);

endmodule
