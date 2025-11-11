// testbench for Hamming Code Extended eH(8,4) with Error Injection

module tb_hamming_ext;

    // test Signals
    logic [3:0] data_to_encode; // (D4, D3, D2, D1)
    logic [7:0] encoded_word; // (P4, D4, D3, D2, P3, D1, P2, P1)
    logic [7:0] corrupted_word; // error injected codeword
    logic [3:0] decoded_data; // decoded data output
    logic [2:0] syndrome_internal; // internal syndrome of the decoder
    logic       correctable_error; // indicates correctable error
    logic       uncorrectable_error; // indicates uncorrectable error

    // error mask
    logic [7:0] error_mask;

    // encoder and decoder module instantiation
    hamming_encoder_ext u_encoder_ext (
        .data_in  (data_to_encode),
        .codeword (encoded_word)
    );
    hamming_decoder_ext u_decoder_ext (
        .codeword (corrupted_word),
        .data_out (decoded_data),
        .correctable_error (correctable_error),
        .uncorrectable_error (uncorrectable_error)
    );

    // internal syndrome capture for monitoring
    assign syndrome_internal = u_decoder_ext.syndrome;

    // test process
    initial begin
        $display("----------------------------------------");
        $display("Iniciando simulacao de injecao de erro...");
        $display("----------------------------------------");
        
        $dumpfile("hamming_error_wave.vcd");
        $dumpvars(0, tb_hamming_ext);
        
        // definicao do dado original a ser codificado
        data_to_encode = 4'b1011;
        
        #10; // wait for ENCODER
        
        $display(" [1] Dado de Entrada (data_to_encode): %b", data_to_encode);
        $display(" [2] Encoder gerou (encoded_word):     %b", encoded_word);

        // error mask definition

        // error_mask = 8'b00010000; // simple error
        error_mask = 8'b00101000; // double error 
        // error_mask = 8'b00000000; // no error

        // error application
        corrupted_word = encoded_word ^ error_mask;

        $display(" [3] Error Mask (error_mask):          %b", error_mask);
        $display(" [4] Corrupted Word (corrupted):       %b", corrupted_word);
        
        #10; // wait for DECODER
        
        $display(" [5] Calculated Syndrome (syndrome):   %b", syndrome_internal);
        $display(" [6] Global Parity Error: Correctable= %b, Uncorrectable= %b", correctable_error, uncorrectable_error);
        $display(" [7] Decoder Corrected (decoded_data): %b", decoded_data);

        // final verification
        #10;

        if (decoded_data === data_to_encode && !correctable_error && !uncorrectable_error) begin
            $display("\n>>> SUCCESS! No errors, the original data was recovered.");
        end else if (decoded_data === data_to_encode && correctable_error && !uncorrectable_error) begin
            $display("\n>>> SUCCESS! One error, the original data was recovered.");
        end else if (decoded_data !== data_to_encode && !correctable_error && uncorrectable_error) begin
            $display("\n>>> SUCCESS! Two errors detected, the original data was %b, but was recovered as %b.", data_to_encode, decoded_data);
        end else begin
            $display("\n>>> FAILURE! The original data %b was NOT recovered, got %b instead.", data_to_encode, decoded_data);
        end
        
        $display("----------------------------------------");
        $stop; // end the simulation
    end

endmodule