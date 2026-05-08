// Reverses the bits of a signal, and passes it through 2 flip-flops
// to synchronise it, with a 2-cycle delay. Used for active-low
// button signals.
//
// Parameters: none
//
// Ports:
// clk      - clock signal
// key_n    - negative input signal
// key_sync - synced & reversed output signal

`timescale 1ns / 1ps

module key_synchroniser (
    input logic clk,
    input logic [3:0] key_n,  // active-low, asynchronous
    output logic [3:0] key_sync  // active-high, synchronous
);
  // explicit initial values - doesn't use initial block
  logic [3:0] state1 = 4'b0;
  logic [3:0] state2 = 4'b0;

  always_ff @(posedge clk) begin
    state2 <= state1;
    state1 <= ~key_n;
  end

  assign key_sync = state2;

endmodule
