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

module user_top_timer_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
`ifdef FORMAL
    output logic probe_running,
    output logic [2:0] probe_mode_enable,
`endif
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

`ifdef FORMAL
  assign probe_running = running;
  assign probe_mode_enable = mode_enable;
`endif

  // running state logic

  logic running, next_running, toggle_running;
  rising_edge_detector red (
      .clk(clk),
      .sig_in(button[0]),
      .rise(toggle_running)
  );

  initial running = '0;
  always_comb begin
    // if hours is about to wrap to 23, that means the counter has reached 0:0:0
    if (wrap) next_running = '0;
    else if (toggle_running) next_running = !running;
    else next_running = running;
  end

  always_ff @(posedge clk) begin
    running <= next_running;
  end

  // edit logic
  logic
      inc_pulse,
      dec_pulse,
      seconds_inc,
      seconds_dec,
      minutes_inc,
      minutes_dec,
      hours_inc,
      hours_dec,
      seconds_edit,
      minutes_edit,
      hours_edit;
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

  assign seconds_edit = mode_enable == 3'b001;
  assign minutes_edit = mode_enable == 3'b010;
  assign hours_edit   = mode_enable == 3'b100;

  // Count logic

  logic [4:0] hours;
  logic [5:0] minutes, seconds;
  logic hours_tick, minutes_tick, seconds_tick, wrap;
  assign wrap = (hours == 0) && (minutes == 0) && (seconds == 0);

  editable_countdown #(
      .MAX  (24),
      .WIDTH(5)
  ) hours_counter (
      .clk(clk),
      .clr('0),
      .tick(hours_tick),
      .edit_mode(hours_edit),
      .inc(hours_inc),
      .dec(hours_dec),
      .count(hours),
      .borrow_out()
  );

  editable_countdown #(
      .MAX  (60),
      .WIDTH(6)
  ) minutes_counter (
      .clk(clk),
      .clr('0),
      .tick(minutes_tick),
      .edit_mode(minutes_edit),
      .inc(minutes_inc),
      .dec(minutes_dec),
      .count(minutes),
      .borrow_out(hours_tick)
  );

  editable_countdown #(
      .MAX  (60),
      .WIDTH(6)
  ) seconds_counter (
      .clk(clk),
      .clr('0),
      .tick(seconds_tick),
      .edit_mode(seconds_edit),
      .inc(seconds_inc),
      .dec(seconds_dec),
      .count(seconds),
      .borrow_out(minutes_tick)
  );

  // Derive 1 Hz tick from system clock
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) rate_gen (
      .clk (clk),
      .run (running),
      .tick(seconds_tick)
  );

  assign hours_disp   = {2'b0, hours};
  assign minutes_disp = {1'b0, minutes};
  assign seconds_disp = {1'b0, seconds};

  // mode selection logic

  logic [2:0] mode_enable;
  logic enable_edit;
  assign enable_edit = !running & button[3];
  edit_mode_selector #(
      .HOLD_CYCLES(CYCLES_PER_SECOND)
  ) edit_mode (
      .clk(clk),
      .button(enable_edit),
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

  assign blank_seconds = !pwm_out && mode_enable == 3'b001;
  assign blank_minutes = !pwm_out && mode_enable == 3'b010;
  assign blank_hours = !pwm_out && mode_enable == 3'b100;
  assign led = 10'b0;

endmodule
