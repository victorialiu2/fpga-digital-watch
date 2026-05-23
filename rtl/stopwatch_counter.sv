// A stopwatch that counts up to 99 minutes, 59 seconds, and 99 centiseconds.
// Can be paused or reset.
//
// Parameters:
// CYCLES_PER_SECOND - clock cycles in a second
//
// Ports:
// clk                  - clock signal
// rst                  - reset signal
// enable               - only increment if enable is set to 1
// minutes [6:0]        - minutes count
// seconds [5:0]        - seconds count
// centiseconds [6:0]   - centiseconds count

`timescale 1ns / 1ps

module stopwatch_counter #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic clk,
    input logic rst,  // Takes priority over enable
    input logic enable,
    output logic [6:0] minutes,
    output logic [5:0] seconds,
    output logic [6:0] centiseconds  // hundredths of a second
);

  logic enable_gen, tick, enable_counter;
  assign enable_gen = !rst & enable;
  assign enable_counter = tick & enable;
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 100)
  ) rate_generator (
      .clk (clk),
      .run (enable_gen),
      .tick(tick)
  );

  cascade_counter #(
      .N2(100),
      .N1(60),
      .N0(100),
      .W2(7),
      .W1(6),
      .W0(7)
  ) counter (
      .clk(clk),
      .rst(rst),
      .enable(enable_counter),
      .count2(minutes),
      .count1(seconds),
      .count0(centiseconds)
  );
endmodule
