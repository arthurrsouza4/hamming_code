// automatized testbench for Extended Hamming Code eH(8,4) - 3 scenarios
// by @arthurrsouza4 (adapted)

module tb_hamming_ext;

    // testbench signals
    logic [3:0] data_to_encode;
    logic [7:0] encoded_word;    
    logic [7:0] corrupted_word;    
    logic [3:0] decoded_data;
    logic [2:0] syndrome_internal;
    
    // New status signals for Extended Hamming
    logic correctable_error;
    logic uncorrectable_error;

    // error mask
    logic [7:0] error_mask;

    // instantiation of extended encoder and decoder modules
    hamming_encoder_ext u_encoder (
        .data_in  (data_to_encode),
        .codeword (encoded_word)
    );
    
    hamming_decoder_ext u_decoder (
        .codeword (corrupted_word),
        .data_out (decoded_data),
        .correctable_error   (correctable_error),
        .uncorrectable_error (uncorrectable_error)
    );

    // capture internal syndrome
    assign syndrome_internal = u_decoder.syndrome;

    // test process
    initial begin
        $display("----------------------------------------");
        $display("Starting simulation of 3 cases eH(8,4)...");
        $display("----------------------------------------");
        
        $dumpfile("hamming_ext_scenarios.vcd");
        $dumpvars(0, tb_hamming_ext);
        
        // define the data (Fixed for all tests)
        data_to_encode = 4'b1010;
        
        // wait for the encoder to generate the initial word
        #10; 

        // ====================================================
        // CASE 1: NO ERROR
        // ====================================================
        $display("\n--- CASE 1: NO ERROR ---");
        error_mask = 8'b00000000; // zeroed mask
        
        // apply the error (none)
        corrupted_word = encoded_word ^ error_mask;
        #10; // wait for the decoder
        
        // show results and verify (Expected Type: 0 = No Error)
        mostrar_resultados(); 
        verificar_sucesso("No Error", 0);


        // ====================================================
        // CASE 2: 1 ERROR (Should Correct)
        // ====================================================
        $display("\n--- CASE 2: 1 ERROR (Position 5 / Index 4) ---");
        error_mask = 8'b00010000; // error in bit 4
        
        corrupted_word = encoded_word ^ error_mask;
        #10; // wait for the decoder
        
        // verify (Expected Type: 1 = Correctable)
        mostrar_resultados();
        verificar_sucesso("Single Error", 1);


        // ====================================================
        // CASE 3: 2 ERRORS (Should Detect as Uncorrectable)
        // ====================================================
        $display("\n--- CASE 3: 2 ERRORS (Positions 3 and 5 / Indices 2 and 4) ---");
        $display("Note: eH(8,4) cannot fix this, but MUST detect it.");
        error_mask = 8'b00010100; // errors in bits 4 and 2
        
        corrupted_word = encoded_word ^ error_mask;
        #10; // wait for the decoder
        
        // verify (Expected Type: 2 = Uncorrectable)
        mostrar_resultados();
        verificar_sucesso("Double Error", 2);

        $display("\n----------------------------------------");
        $stop;
    end

    // -------------------------------------------------------
    // AUXILIARY TASKS
    // -------------------------------------------------------
    
    // task to print the current values
    task mostrar_resultados;
        begin
            $display(" [1] Input:       %b", data_to_encode);
            $display(" [2] Encoded:     %b", encoded_word);
            $display(" [3] Mask:        %b", error_mask);
            $display(" [4] Corrupted:   %b", corrupted_word);
            $display(" [5] Syndrome:    %b", syndrome_internal);
            $display(" [6] Decoded Out: %b", decoded_data);
            $display(" [7] Status: Correctable = %b | Uncorrectable = %b", correctable_error, uncorrectable_error);
        end
    endtask

    // task to check if it worked based on EXPECTED SCENARIO
    // expected_type: 0 = No Error, 1 = Correctable, 2 = Uncorrectable
    task verificar_sucesso;
        input string nome_caso;
        input integer expected_type;
        begin
            // Scenario 0: Expect Perfect Match, No Error Flags
            if (expected_type == 0) begin
                if (decoded_data === data_to_encode && !correctable_error && !uncorrectable_error)
                    $display(">>> RESULT [%s]: SUCCESS! Data recovered perfectly.", nome_caso);
                else
                    $display(">>> RESULT [%s]: FAILURE! Unexpected error flags or data mismatch.", nome_caso);
            end
            
            // Scenario 1: Expect Perfect Match, Correctable Flag = 1
            else if (expected_type == 1) begin
                if (decoded_data === data_to_encode && correctable_error && !uncorrectable_error)
                    $display(">>> RESULT [%s]: SUCCESS! Single error corrected.", nome_caso);
                else
                    $display(">>> RESULT [%s]: FAILURE! Correction failed.", nome_caso);
            end

            // Scenario 2: Expect UNCORRECTABLE Flag = 1 (Data mismatch is allowed/expected)
            else if (expected_type == 2) begin
                if (uncorrectable_error && !correctable_error)
                    $display(">>> RESULT [%s]: SUCCESS! Double error detected successfully.", nome_caso);
                else
                    $display(">>> RESULT [%s]: FAILURE! Double error NOT detected properly.", nome_caso);
            end
        end
    endtask

endmodule