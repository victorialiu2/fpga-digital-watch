// Generates a fixed-frequency and fixed-duty pulse.
//
// Parameters:
// PERIOD_CYCLES    - duration in clock cycles of the period
// DUTY_CYCLES      - duration in clock cycles of the duty
//
// Ports:
// clk      - clock signal
// rst      - reset pulse to start of period
// pwm_out  - output pulse signal

`timescale 1ns / 1ps

module pwm_generator #(
    parameter int PERIOD_CYCLES = 50_000_000,
    parameter int DUTY_CYCLES   = 25_000_000
) (
    input  logic clk,
    input  logic rst,
    output logic pwm_out
);
  localparam int PeriodWidth = $clog2(PERIOD_CYCLES);
  logic [PeriodWidth-1:0] count;
  mod_n_counter #(
      .N(PERIOD_CYCLES),
      .WIDTH(PeriodWidth)
  ) counter (
      .clk(clk),
      .rst(rst),
      .enable('1),
      .count(count)
  );

  always_comb begin
    if (DUTY_CYCLES == 0) pwm_out = '0;
    else if (count <= PeriodWidth'(DUTY_CYCLES - 1)) pwm_out = '1;
    else pwm_out = '0;
  end

endmodule
