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

module top_time_display_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic CLOCK_50,
    input logic [1:0] SW,
    output logic [6:0] HEX5,
    output logic [6:0] HEX4,
    output logic [6:0] HEX3,
    output logic [6:0] HEX2,
    output logic [6:0] HEX1,
    output logic [6:0] HEX0
);
  localparam int MaxH = 24, MaxM = 60, MaxS = 60;
  localparam int WidH = 5, WidM = 6, WidS = 6;
  localparam int WidBCD = 4;  // width of binary-coded decimal digit

  hms_counter #(
      .N_HOURS  (MaxH),
      .N_MINUTES(MaxM),
      .N_SECONDS(MaxS),
      .W_HOURS  (WidH),
      .W_MINUTES(WidM),
      .W_SECONDS(WidS)
  ) hms (
      .clk(CLOCK_50),
      .enable('1),
      .hours(hours),
      .minutes(minutes),
      .seconds(seconds)
  );
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) rateGenS (
      .clk (),
      .run (),
      .tick()
  );
  restartable_rate_generator #(
      .CYCLE_COUNT()
  ) rateGenM (
      .clk (),
      .run (),
      .tick()
  );
  restartable_rate_generator #(
      .CYCLE_COUNT()
  ) rateGenH (
      .clk (),
      .run (),
      .tick()
  );
  binary_to_bcd bcdS (
      .bin (hours),
      .tens(hoursTens),
      .ones(hoursOnes)
  );
  binary_to_bcd bcdM (
      .bin (minutes),
      .tens(minutesTens),
      .ones(minutesOnes)
  );
  binary_to_bcd bcdH (
      .bin (hours),
      .tens(hoursTens),
      .ones(hoursOnes)
  );
  seven_segment #(
      .ACTIVE_LOW('1)
  ) ssegH1 (
      .digit(hoursTens),
      .blank('0),
      .segments(HEX5)
  );
  seven_segment #(
      .ACTIVE_LOW('1)
  ) ssegH2 (
      .digit(hoursOnes),
      .blank('0),
      .segments(HEX4)
  );
  seven_segment #(
      .ACTIVE_LOW('1)
  ) ssegM1 (
      .digit(minutesTens),
      .blank('0),
      .segments(HEX3)
  );
  seven_segment #(
      .ACTIVE_LOW('1)
  ) ssegM2 (
      .digit(minutesOnes),
      .blank('0),
      .segments(HEX2)
  );
  seven_segment #(
      .ACTIVE_LOW('1)
  ) ssegS1 (
      .digit(secondsTens),
      .blank('0),
      .segments(HEX1)
  );
  seven_segment #(
      .ACTIVE_LOW('1)
  ) ssegS2 (
      .digit(secondsOnes),
      .blank('0),
      .segments(HEX0)
  );

  // binary values
  logic [WidH-1:0] hours;
  logic [WidM-1:0] minutes;
  logic [WidS-1:0] seconds;
  // BDCs
  logic [WidBCD-1:0] hoursTens;
  logic [WidBCD-1:0] hoursOnes;
  logic [WidBCD-1:0] minutesTens;
  logic [WidBCD-1:0] minutesOnes;
  logic [WidBCD-1:0] secondsTens;
  logic [WidBCD-1:0] secondsOnes;
  // cycle speed
  logic [25:0] tickRate;
  always_comb
    unique case (SW)
      2'b00: tickRate = 26'(CYCLES_PER_SECOND);
      2'b01: tickRate = 26'd2_000_000;
      2'b10: tickRate = 26'd50_000;
      2'b11: tickRate = '1;
    endcase
endmodule
