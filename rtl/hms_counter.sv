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

module hms_counter #(
    parameter int N_HOURS   = 24,  // number of hours
    parameter int N_MINUTES = 60,  // number of minutes
    parameter int N_SECONDS = 60,  // number of seconds

    // output port widths
    parameter int W_HOURS   = 5,
    parameter int W_MINUTES = 6,
    parameter int W_SECONDS = 6
) (
    input logic clk,
    input logic enable,
    output logic [W_HOURS-1:0] hours,
    output logic [W_MINUTES-1:0] minutes,
    output logic [W_SECONDS-1:0] seconds
);

  logic second_rollover, minute_rollover;
  // the parameter number of x has a range of 0 - (x-1)
  // setting the number outside of the range (including x) can be truncated
  localparam logic [W_MINUTES-1:0] MaxMinutes = W_MINUTES'(N_MINUTES - 1);
  localparam logic [W_SECONDS-1:0] MaxSeconds = W_SECONDS'(N_SECONDS - 1);

  always_comb begin
    second_rollover = 0;
    minute_rollover = 0;
    if (enable & seconds >= MaxSeconds) begin
      second_rollover = 1;
      if (minutes >= MaxMinutes) minute_rollover = 1;
    end
  end

  up_down_counter #(
      .MAX  (N_HOURS - 1),
      .WIDTH(W_HOURS)
  ) u_hour (
      .clk(clk),
      .enable(minute_rollover),
      .up('1),
      .count(hours)
  );

  up_down_counter #(
      .MAX  (N_MINUTES - 1),
      .WIDTH(W_MINUTES)
  ) u_minute (
      .clk(clk),
      .enable(second_rollover),
      .up('1),
      .count(minutes)
  );

  up_down_counter #(
      .MAX  (N_SECONDS - 1),
      .WIDTH(W_SECONDS)
  ) u_second (
      .clk(clk),
      .enable(enable),
      .up('1),
      .count(seconds)
  );

endmodule
