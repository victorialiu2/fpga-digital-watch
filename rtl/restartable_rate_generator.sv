// Generates a periodic tick, in terms of number of cycles.
// The first tick occurs after run is high for CYCLE_COUNT - 1
// cycles, and each tick after that is CYCLE_COUNT cycles apart.
// When run is low, the entire count is reset, and the next tick
// always occurs after CYCLE_COUNT - 1 cycles.
//
// Parameters:
// CYCLE_COUNT  - number of cycles between ticks
//
// Ports:
// clk  - clock signal
// run  - only generate ticks when run is high. when run is low,
//        the sequence resets
// tick - output pin

`timescale 1ns / 1ps

module restartable_rate_generator #(
    parameter int CYCLE_COUNT = 2
) (
    input  logic clk,
    input  logic run,
    output logic tick
);

  logic tick_qualifier;
  logic running = 1'b0;
  always_ff @(posedge clk) running <= run;
  assign tick = running & tick_qualifier;

  generate
    if (CYCLE_COUNT > 1) begin : g_general
      localparam int CountWidth = $clog2(CYCLE_COUNT);
      logic rst_count;
      logic enable_count;
      logic [CountWidth-1:0] count;
      mod_n_counter #(
          .N(CYCLE_COUNT),
          .WIDTH(CountWidth)
      ) counter (
          .clk(clk),
          .rst(rst_count),
          .enable(enable_count),
          .count(count)
      );
      assign rst_count = !running;
      assign enable_count = running;
      assign tick_qualifier = count == CountWidth'(CYCLE_COUNT - 2);

    end else begin : g_special
      assign tick_qualifier = '1;
    end
  endgenerate

endmodule
