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

module user_top_watch_v4 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic clk,
    /* verilator lint_off UNUSED */
    input logic [3:0] button,
    input logic [9:0] sw,
    /* verilator lint_on UNUSED */
    output logic [9:0] led,
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic blank_hours,
    output logic blank_minutes,
    output logic blank_seconds
);

  // ------------------------
  // Core Functionality
  // ------------------------

  // Seconds
  logic seconds_tick, seconds_edit, seconds_inc, seconds_dec;
  logic [5:0] seconds;
  editable_counter #(
      .N(60),
      .WIDTH(6)
  ) u_seconds (
      .clk(clk),
      .tick(seconds_tick),
      .edit_mode(seconds_edit),
      .inc(seconds_inc),
      .dec(seconds_dec),
      .count(seconds)
  );

  // Minutes
  logic minutes_tick, minutes_edit, minutes_inc, minutes_dec;
  logic [5:0] minutes;
  editable_counter #(
      .N(60),
      .WIDTH(6)
  ) u_minutes (
      .clk(clk),
      .tick(minutes_tick),
      .edit_mode(minutes_edit),
      .inc(minutes_inc),
      .dec(minutes_dec),
      .count(minutes)
  );

  // Hours
  logic hours_tick, hours_edit, hours_inc, hours_dec;
  logic [4:0] hours;
  editable_counter #(
      .N(24),
      .WIDTH(5)
  ) u_hours (
      .clk(clk),
      .tick(hours_tick),
      .edit_mode(hours_edit),
      .inc(hours_inc),
      .dec(hours_dec),
      .count(hours)
  );

  // Derive 1 Hz tick from system clock
  logic rst;
  assign rst = seconds_edit && button[3];
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_divider_1_Hz (
      .clk (clk),
      .run (!rst),
      .tick(seconds_tick)
  );

  assign seconds_edit = mode_enable == 3'b001;
  assign minutes_edit = mode_enable == 3'b010;
  assign hours_edit = mode_enable == 3'b100;
  assign minutes_tick = seconds_disp == 7'd59 & seconds_tick;
  assign hours_tick = minutes_disp == 7'd59 & minutes_tick;

  assign hours_disp = {2'b0, hours};
  assign minutes_disp = {1'b0, minutes};
  assign seconds_disp = {1'b0, seconds};

  assign led = 10'b0;

  // ---------------
  // Mode Selection
  // ---------------

  logic [2:0] mode_enable;
  edit_mode_selector #(
      .HOLD_CYCLES(CYCLES_PER_SECOND)
  ) u_mode_selector (
      .clk(clk),
      .button(button[3]),
      .mode_enable(mode_enable)
  );

  logic pwm_out;
  pwm_generator #(
      .PERIOD_CYCLES(CYCLES_PER_SECOND / 2),
      .DUTY_CYCLES  (CYCLES_PER_SECOND * 0.4)
  ) pwm (
      .clk(clk),
      .rst(button[3]),
      .pwm_out(pwm_out)
  );

  assign blank_seconds = !pwm_out & seconds_edit;
  assign blank_minutes = !pwm_out & minutes_edit;
  assign blank_hours   = !pwm_out & hours_edit;

  // -----------------
  // Edit logic
  // -----------------

  logic inc_pulse, dec_pulse;
  assign seconds_inc = inc_pulse;
  assign seconds_dec = dec_pulse;
  assign minutes_inc = inc_pulse;
  assign minutes_dec = dec_pulse;
  assign hours_inc   = inc_pulse;
  assign hours_dec   = dec_pulse;

  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)
  ) inc_repeat_signal (
      .clk(clk),
      .button(button[1]),
      .pulse(inc_pulse)
  );

  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)
  ) dec_repeat_signal (
      .clk(clk),
      .button(button[0]),
      .pulse(dec_pulse)
  );

endmodule
