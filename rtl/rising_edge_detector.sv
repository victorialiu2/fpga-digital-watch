// Detects a rising edge asynchronous to the input clk. The output is
// reset as soon as the input becomes low, or when the next clock cycle
// comes.
//
// Parameters: none
//
// Ports:
// clk      - clock signal
// sig_in   - input signal
// rise     - output signal

`timescale 1ns / 1ps

module rising_edge_detector (
    input  logic clk,
    input  logic sig_in,
    output logic rise
);
  logic last_sig;
  initial last_sig = '1;

  always_comb begin
    if (!last_sig & sig_in) rise = '1;
    else rise = '0;
  end
  always_ff @(posedge clk) begin
    last_sig <= sig_in;
  end

endmodule
