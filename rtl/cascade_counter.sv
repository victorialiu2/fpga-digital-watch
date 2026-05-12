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
  initial count2 = '0;
  initial count1 = '0;
  initial count0 = '0;
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

  always_comb begin
    N0Rollover = '0;
    N1Rollover = '0;
    if (enable & count0 >= MaxN0) begin
      N0Rollover = '1;
      if (count1 >= MaxN1) N1Rollover = '1;
    end
  end

endmodule
