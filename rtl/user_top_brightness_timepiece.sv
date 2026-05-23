// ------------------------------------------------------------------
// WARNING: This file is used by the automated test suite. Do not
// modify it.
//
// This file also serves as a template for your own designs. To use
// it:
//   1. Copy the entire contents into a new file with a descriptive
//      name.
//   2. Delete the test logic below and replace it with your own
//      code.
//   3. In top_de1_soc, change the module name from user_top to your
//      new module name.
//
//   The board wrapper sets CYCLES_PER_SECOND; use this parameter in
//   your design wherever timing is needed.
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module user_top_brightness_timepiece #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic clk,
    /* verilator lint_off UNUSED */
    input logic [3:0] button,
    input logic [9:0] sw,
    output logic [9:0] led,
    /* verilator lint_on UNUSED */
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic blank_hours,
    output logic blank_minutes,
    output logic blank_seconds
);

  logic dim_hours, dim_minutes, dim_seconds, blank;

  user_top_timepiece_v2 #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_user_top (
      .clk          (clk),
      .button       (button),
      .sw           (sw),
      .led          (led),
      .hours_disp   (hours_disp),
      .minutes_disp (minutes_disp),
      .seconds_disp (seconds_disp),
      .blank_hours  (dim_hours),
      .blank_minutes(dim_minutes),
      .blank_seconds(dim_seconds)
  );

  localparam int PwmPeriod = CYCLES_PER_SECOND / 1_000;
  localparam int PeriodWidth = $clog2(PwmPeriod + 1);
  localparam int Dim = PwmPeriod / 8;
  localparam int Low = PwmPeriod / 4;
  localparam int Medium = PwmPeriod / 2;
  localparam int Full = PwmPeriod;

  logic [PeriodWidth-1:0] duty_cycle;
  logic [1:0] brightness_sw;
  assign brightness_sw = sw[9:8];
  always_comb begin
    unique case (brightness_sw)
      2'b00: duty_cycle = PeriodWidth'(Dim);
      2'b01: duty_cycle = PeriodWidth'(Low);
      2'b11: duty_cycle = PeriodWidth'(Medium);
      2'b10: duty_cycle = PeriodWidth'(Full);
    endcase
  end

  logic [PeriodWidth-1:0] count;
  mod_n_counter #(
      .N(PwmPeriod),
      .WIDTH(PeriodWidth)
  ) pwm (
      .clk(clk),
      .rst('0),
      .enable('1),
      .count(count)
  );

  assign blank = count >= duty_cycle;
  assign blank_hours = blank | dim_hours;
  assign blank_minutes = blank | dim_minutes;
  assign blank_seconds = blank | dim_seconds;

endmodule
