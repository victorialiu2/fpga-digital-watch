// Has 3 counters, where the seconds counter updates every clk signal,
// the minutes counter updates when the max seconds is reached, and
// the hours counter updates when the max minutes is reached. All counters
// get reset to 0 to when they reach the max amount. Can be edited.
// Edit mode of each number is cycled through edit_mode 2-bit signal.
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
// clk                      - clock signal
// tick                     - tick signal (run as normal)
// edit_mode [1:0]          - edit mode signal (00: no edit, 01: edit seconds,
//                            10: edit minutes, 11: edit_hours)
// inc                      - increment signal
// dec                      - decrement signal
// hours [W_HOURS-1:0]      - hours counter
// minutes [W_MINUTES-1:0]  - minutes counter
// seconds [W_SECONDS-1:0]  - seconds counter

`timescale 1ns / 1ps

module editable_hms_counter #(
    parameter int N_HOURS   = 24,  // number of hours
    parameter int N_MINUTES = 60,  // number of minutes
    parameter int N_SECONDS = 60,  // number of seconds

    // output port widths
    parameter int W_HOURS   = 5,
    parameter int W_MINUTES = 6,
    parameter int W_SECONDS = 6
) (
    input logic clk,
    input logic tick,
    input logic [1:0] edit_mode,
    input logic inc,
    input logic dec,
    output logic [W_HOURS-1:0] hours,
    output logic [W_MINUTES-1:0] minutes,
    output logic [W_SECONDS-1:0] seconds
);

  logic second_rollover, minute_rollover;
  localparam logic [W_MINUTES-1:0] MaxMinutes = W_MINUTES'(N_MINUTES - 1);
  localparam logic [W_SECONDS-1:0] MaxSeconds = W_SECONDS'(N_SECONDS - 1);

  logic hours_edit, minutes_edit, seconds_edit;
  assign hours_edit = edit_mode == 2'b11;
  assign minutes_edit = edit_mode == 2'b10;
  assign seconds_edit = edit_mode == 2'b01;
  assign second_rollover = tick && (seconds == MaxSeconds);
  assign minute_rollover = second_rollover && (minutes == MaxMinutes);

  editable_counter #(
      .N(N_HOURS),
      .WIDTH(W_HOURS)
  ) u_hour (
      .clk(clk),
      .tick(minute_rollover),
      .edit_mode(hours_edit),
      .inc(inc),
      .dec(dec),
      .count(hours)
  );

  editable_counter #(
      .N(N_MINUTES),
      .WIDTH(W_MINUTES)
  ) u_minute (
      .clk(clk),
      .tick(second_rollover),
      .edit_mode(minutes_edit),
      .inc(inc),
      .dec(dec),
      .count(minutes)
  );

  editable_counter #(
      .N(N_SECONDS),
      .WIDTH(W_SECONDS)
  ) u_second (
      .clk(clk),
      .tick(tick),
      .edit_mode(seconds_edit),
      .inc(inc),
      .dec(dec),
      .count(seconds)
  );

endmodule
