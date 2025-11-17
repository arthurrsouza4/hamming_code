// Extended Hamming Code Implementation in SystemVerilog
// This file contains module for Extended Hamming Code (8,4) decoding with single-bit error correction and double-bit error detection.
// by @arthurrsouza4

module hamming_decoder_ext (
    input  logic [7:0] codeword,
    output logic [3:0] data_out,
    output logic       correctable_error,
    output logic       uncorrectable_error
);
    // calculate syndrome bits
    logic [2:0] syndrome;
    assign syndrome[0] = codeword[0] ^ codeword[2] ^ codeword[4] ^ codeword[6]; // C1 = P1 ^ D1 ^ D2 ^ D4
    assign syndrome[1] = codeword[1] ^ codeword[2] ^ codeword[5] ^ codeword[6]; // C2 = P2 ^ D1 ^ D3 ^ D4
    assign syndrome[2] = codeword[3] ^ codeword[4] ^ codeword[5] ^ codeword[6]; // C3 = P3 ^ D2 ^ D3 ^ D4
    
    // Global parity check C4 = D1 ^ D2 ^ D3 ^ D4 ^ P1 ^ P2 ^ P3 ^ P4
    logic global_parity_error;
    assign global_parity_error = ^codeword;
    
    // determine correctable error
    assign correctable_error = (syndrome != 3'b000) && global_parity_error;
    // determine uncorrectable error
    assign uncorrectable_error = (syndrome != 3'b000) && !global_parity_error;

    // corrected codeword
    logic [7:0] corrected_codeword;
    
    // error detection and correction
    always_comb begin
        // no error or uncorrectable error
        corrected_codeword = codeword;
        if (correctable_error) begin
            // error detected, correct the bit at position indicated by syndrome
            corrected_codeword[syndrome - 1] = ~codeword[syndrome - 1];
        end
        data_out = {corrected_codeword[6:4], corrected_codeword[2]};
    end

endmodule