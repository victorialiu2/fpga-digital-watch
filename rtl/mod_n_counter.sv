// Has 3 counters, where the seconds counter updates every clk signal,
// the minutes counter updates when the max seconds is reached, and
// the hours counter updates when the max minutes is reached. All counters
// get reset to 0 to when they reach the max amount.
//
// Parameters:
// N_HOURS      - number of hours
// N_MINUTES    - number of minutes
// N_SECONDS    - number of seconds
// W_HOURS      - number of bits for hours
// W_MINUTES    - number of bits for minutes
// W_SECONDS    - number of bits for seconds
//
// Ports:
// clk                - clock signal
// enable             - only increment if enable is set to 1
// hours              - hours counter
// minutes            - minutes counter
// seconds            - seconds counter

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
  logic [WIDTH-1:0] max = WIDTH'(N);

  initial count = '0;

  always_ff @(posedge clk)
    if (rst) count <= '0;
    else if (enable) count <= next_count;

  always_comb
    if (count >= max) next_count = '0;
    else next_count = count + 1'd1;

endmodule
