// The control logic of the alarm - keeps track of 4 possible internal states:
// - RunTime, AlarmRinging, EditTime, EditAlarm
// and outputs the information the top module needs:
// - edit mode, display and flash toggle, clock tick
//
// Parameters: none
//
// Ports:
// clk                - clock signal

`timescale 1ns / 1ps

module alarm_control (
    input logic clk,
    input logic cycle_time,
    input logic cycle_alarm,
    input logic exit_alarm,
    input logic trigger_alarm,
    output logic [1:0] edit_mode,
    output logic edit_alarm,
    output logic edit_time,
    output logic toggle_display,
    output logic flash_display,
    output logic tick
);

  logic [1:0] state, nextState, editMode, nextEditMode;
  initial begin
    state = RunTime;
    editMode = 2'b00;
  end
  localparam logic [1:0] EditTime = 2'b10, EditAlarm = 2'b11, RunTime = 2'b00, AlarmRing = 2'b01;

  always_ff @(posedge clk) begin
    state <= nextState;
    editMode <= nextEditMode;
  end

  // next state logic
  always_comb begin
    nextState = state;
    unique case (state)
      RunTime: begin
        if (trigger_alarm) nextState = AlarmRing;
        else if (cycle_time) nextState = EditTime;
        else if (cycle_alarm) nextState = EditAlarm;
      end
      AlarmRing: if (exit_alarm) nextState = RunTime;
      EditAlarm: if (editMode == 2'b11 && cycle_alarm) nextState = RunTime;
      EditTime:  if (editMode == 2'b11 && cycle_time) nextState = RunTime;
    endcase
  end

  always_comb begin
    nextEditMode = editMode;
    if ((state == EditTime || state == RunTime) && cycle_time) nextEditMode = editMode + 1'b1;
    else if ((state == EditAlarm || state == RunTime) && cycle_alarm)
      nextEditMode = editMode + 1'b1;
  end

  // output logic
  assign edit_mode = editMode;
  assign edit_alarm = state == EditAlarm;
  assign edit_time = state == EditTime;
  assign toggle_display = (state == EditTime) || (state == RunTime);
  assign flash_display = state == AlarmRing;
  assign tick = state != EditTime;  // clock is always running except when it is being edited

endmodule
