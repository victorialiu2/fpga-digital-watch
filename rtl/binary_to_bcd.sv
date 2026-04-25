// Convert binary number between 0-99 to binary-coded decimal format.
//
// Parameters: none
//
// Ports:
// bin [6:0]    - binary input, 0-99
// tens [3:0]   - decimal tens digit (BCD)
// ones [3:0]   - decimal ones digit (BCD)

`timescale 1ns / 1ps

module binary_to_bcd (
    input  logic [6:0] bin,   // binary input, 0-99
    output logic [3:0] tens,  // decimal tens digit (BCD)
    output logic [3:0] ones   // decimal ones digit (BCD)
);
  assign tens = 4'(bin / 7'd10);
  assign ones = 4'(bin % 7'd10);
endmodule
