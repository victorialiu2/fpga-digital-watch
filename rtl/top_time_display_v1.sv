// A digital clock that stores the time (in seconds, minutes, hours)
// of a single 24hr cycle. The speed can be changed to 4 settings.
// The output is displayed on 6 seven-segment displays.
//
// Parameters:
// CYCLES_PER_SECOND    - the frequency of the input clock signal
//
// Ports:
// CLOCK_50 - input clock signal
// SW       - switch input, gives 4 choices of clock speed (1Hz, 25Hz, 1kHz, 50MHz)
// HEX5     - 1 of 6 SSEGs, shows the tens digit of the hour
// HEX4     - 2 of 6 SSEGs, shows the ones digit of the hour
// HEX3     - 3 of 6 SSEGs, shows the tens digit of the minute
// HEX2     - 4 of 6 SSEGs, shows the ones digit of the minute
// HEX1     - 5 of 6 SSEGs, shows the tens digit of the second
// HEX0     - 6 of 6 SSEGs, shows the ones digit of the second

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
  // clock speeds
  logic clk25Hz, clk1kHz, clk1Hz, hmsClk;
  // binary values
  logic [4:0] hours;
  logic [5:0] minutes;
  logic [5:0] seconds;
  // BDCs
  logic [3:0] hoursTens;
  logic [3:0] hoursOnes;
  logic [3:0] minutesTens;
  logic [3:0] minutesOnes;
  logic [3:0] secondsTens;
  logic [3:0] secondsOnes;
  // set clock speed
  always_comb
    unique case (SW)
      2'b00: hmsClk = clk1Hz;
      2'b01: hmsClk = clk25Hz;
      2'b10: hmsClk = clk1kHz;
      2'b11: hmsClk = CLOCK_50;
    endcase

  hms_counter hms (
      .clk(CLOCK_50),
      .enable(hmsClk),
      .hours(hours),
      .minutes(minutes),
      .seconds(seconds)
  );

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) rg50MHz (
      .clk (CLOCK_50),
      .run ('1),
      .tick(clk1Hz)
  );
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 1_000)
  ) rg1kHz (
      .clk (CLOCK_50),
      .run ('1),
      .tick(clk1kHz)
  );
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 25)
  ) rg25Hz (
      .clk (CLOCK_50),
      .run ('1),
      .tick(clk25Hz)
  );
  binary_to_bcd bcdS (
      .bin ({1'b0, seconds}),
      .tens(secondsTens),
      .ones(secondsOnes)
  );
  binary_to_bcd bcdM (
      .bin ({1'b0, minutes}),
      .tens(minutesTens),
      .ones(minutesOnes)
  );
  binary_to_bcd bcdH (
      .bin ({2'b0, hours}),
      .tens(hoursTens),
      .ones(hoursOnes)
  );
  seven_segment ssegH1 (
      .digit(hoursTens),
      .blank('0),
      .segments(HEX5)
  );
  seven_segment ssegH2 (
      .digit(hoursOnes),
      .blank('0),
      .segments(HEX4)
  );
  seven_segment ssegM1 (
      .digit(minutesTens),
      .blank('0),
      .segments(HEX3)
  );
  seven_segment ssegM2 (
      .digit(minutesOnes),
      .blank('0),
      .segments(HEX2)
  );
  seven_segment ssegS1 (
      .digit(secondsTens),
      .blank('0),
      .segments(HEX1)
  );
  seven_segment ssegS2 (
      .digit(secondsOnes),
      .blank('0),
      .segments(HEX0)
  );

endmodule

