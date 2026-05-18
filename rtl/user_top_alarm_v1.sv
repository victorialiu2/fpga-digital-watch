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

module user_top_alarm_v1 #(
    /* verilator lint_off UNUSED */
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic clk,
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

  assign led = '0;

  logic [4:0] hours, alarm_hours;
  logic [5:0] minutes, alarm_minutes, seconds, alarm_seconds;

  // ------------------
  // state logic
  // ------------------
  logic tick;
  logic trigger_alarm;
  assign trigger_alarm = (hours == alarm_hours) && (minutes == alarm_minutes) && (seconds == alarm_seconds);

  // edit logic
  logic inc, dec, edit_alarm, edit_time;
  localparam logic [1:0] NoEdit = 2'b00;
  logic [1:0] edit_mode, edit_mode_alarm, edit_mode_time;
  assign edit_mode_alarm = (edit_alarm) ? edit_mode : NoEdit;
  assign edit_mode_time = (edit_time) ? edit_mode : NoEdit;
  assign inc = pressed_3;
  assign dec = pressed_2;

  // display logic
  logic toggle_display, flash_display, pwm_out;
  always_comb begin
    hours_disp   = (toggle_display) ? {2'b0, hours} : {2'b0, alarm_hours};
    minutes_disp = (toggle_display) ? {1'b0, minutes} : {1'b0, alarm_minutes};
    seconds_disp = (toggle_display) ? {1'b0, seconds} : {1'b0, alarm_seconds};
    if (flash_display) begin
      {blank_hours, blank_minutes, blank_seconds} = {pwm_out, pwm_out, pwm_out};
    end else begin
      {blank_hours, blank_minutes, blank_seconds} = 3'b0;
    end
  end

  editable_hms_counter alarm_counter (
      .clk(clk),
      .tick('0),
      .edit_mode(edit_mode_alarm),
      .inc(inc),
      .dec(dec),
      .hours(alarm_hours),
      .minutes(alarm_minutes),
      .seconds(alarm_seconds)
  );

  editable_hms_counter time_counter (
      .clk(clk),
      .tick(tick),
      .edit_mode(edit_mode_time),
      .inc(inc),
      .dec(dec),
      .hours(hours),
      .minutes(minutes),
      .seconds(seconds)
  );

  logic pressed_0, pressed_1, pressed_2, pressed_3;
  rising_edge_detector red_button_0 (
      .clk(clk),
      .sig_in(button[0]),
      .rise(pressed_0)
  );
  rising_edge_detector red_button_1 (
      .clk(clk),
      .sig_in(button[1]),
      .rise(pressed_1)
  );
  rising_edge_detector red_button_2 (
      .clk(clk),
      .sig_in(button[2]),
      .rise(pressed_2)
  );
  rising_edge_detector red_button_3 (
      .clk(clk),
      .sig_in(button[3]),
      .rise(pressed_3)
  );

  alarm_control alarmControl (
      .clk(clk),
      .cycle_time(pressed_1),
      .cycle_alarm(pressed_0),
      .exit_alarm(pressed_0),
      .trigger_alarm(trigger_alarm),
      .edit_mode(edit_mode),
      .edit_alarm(edit_alarm),
      .edit_time(edit_time),
      .toggle_display(toggle_display),
      .flash_display(flash_display),
      .tick(tick)
  );

  pwm_generator pwm (
      .clk(clk),
      .rst(reset_flash),
      .pwm_out(pwm_out)
  );

  logic reset_flash;
  rising_edge_detector red_flash_reset (
      .clk(clk),
      .sig_in(flash_display),
      .rise(reset_flash)
  );
endmodule
