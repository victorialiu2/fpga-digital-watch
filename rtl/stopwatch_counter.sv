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
    parameter int N_MINUTES   = 60,  // number of minutes
    parameter int N_SECONDS   = 60,  // number of seconds
    parameter int N_CENTISECS = 100, // number of centiseconds

    // output port widths
    parameter int W_MINUTES   = 6,
    parameter int W_SECONDS   = 6,
    parameter int W_CENTISECS = 7
) (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [W_MINUTES-1:0] minutes,
    output logic [W_SECONDS-1:0] seconds,
    output logic [W_CENTISECS-1:0] centisecs
);

endmodule
