// Extended Hamming Code Implementation in SystemVerilog
// This file contains module for Extended Hamming Code (8,4) encoding with single-bit error correction and double-bit error detection.
// by @arthurrsouza4

module hamming_encoder_ext (
    input  logic [3:0] data_in, // (D4, D3, D2, D1)
    output logic [7:0] codeword
);
    // data bits
    logic d1, d2, d3, d4;
    assign d1 = data_in[0];
    assign d2 = data_in[1];
    assign d3 = data_in[2];
    assign d4 = data_in[3];

    // calculate parity bits
    logic p1, p2, p3, p4;
    assign p1 = d1 ^ d2 ^ d4; // P1
    assign p2 = d1 ^ d3 ^ d4; // P2
    assign p3 = d2 ^ d3 ^ d4; // P3
    assign p4 = d1 ^ d2 ^ d3 ^ d4 ^ p1 ^ p2 ^ p3; // Global Parity Bit P4

    // construct codeword
    assign codeword = {p4, d4, d3, d2, p3, d1, p2, p1};

endmodule