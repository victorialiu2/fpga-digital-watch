// A counter that can increment up or down from 0 to a provided max value,
// and pause counting.
//
// Parameters:
// MAX    - the max value in decimal
// WIDTH  - how many binary digits does the max value need
//
// Ports:
// clk                - clock signal
// enable             - only increment if enable is set to 1
// up                 - increment up if up is set to 1, otherwise down
// count [WIDTH-1:0]  - the count output

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

endmodule
