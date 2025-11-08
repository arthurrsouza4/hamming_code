// Hamming Code Decoder Implementation in SystemVerilog
// This file contains module for Hamming (7,4) decoding.
// by @arthurrsouza4

// Hamming (7,4) Decoder with Single-Bit Error Correction
module hamming_decoder (
    input  logic [6:0] codeword,
    output logic [3:0] data_out
);
    // calculate check bits
    logic [2:0] checkbit;
    assign checkbit[0] = codeword[0] ^ codeword[2] ^ codeword[4] ^ codeword[6]; // C1 = P1 ^ D1 ^ D2 ^ D4
    assign checkbit[1] = codeword[1] ^ codeword[2] ^ codeword[5] ^ codeword[6]; // C2 = P2 ^ D1 ^ D3 ^ D4
    assign checkbit[2] = codeword[3] ^ codeword[4] ^ codeword[5] ^ codeword[6]; // C3 = P3 ^ D2 ^ D3 ^ D4

    // syndrome bits
    logic [2:0] syndrome;
    assign syndrome = {checkbit[2], checkbit[1], checkbit[0]};

    // corrected codeword
    logic [6:0] corrected_codeword;
    
    // error detection and correction
    always_comb begin
        // no error
        corrected_codeword = codeword;
        if (syndrome != 3'b000) begin
            // error detected, correct the bit at position indicated by syndrome
            corrected_codeword[syndrome - 1] = ~codeword[syndrome - 1];
        end
        data_out = {corrected_codeword[6], corrected_codeword[5], corrected_codeword[4], corrected_codeword[2]};
    end

endmodule