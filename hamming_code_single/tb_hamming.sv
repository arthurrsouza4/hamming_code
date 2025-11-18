// automatized testbench for Hamming Code (7,4) - 3 scenarios
// by @arthurrsouza4

module tb_hamming;

    // testbench signals
    logic [3:0] data_to_encode;
    logic [6:0] encoded_word;
    logic [6:0] corrupted_word;
    logic [3:0] decoded_data;
    logic [2:0] syndrome_internal;

    // error mask
    logic [6:0] error_mask;

    // instantiation of encoder and decoder modules
    hamming_encoder u_encoder (
        .data_in  (data_to_encode),
        .codeword (encoded_word)
    );
    hamming_decoder u_decoder (
        .codeword (corrupted_word),
        .data_out (decoded_data)
    );

    // capture internal syndrome
    assign syndrome_internal = u_decoder.syndrome;

    // test process
    initial begin
        $display("----------------------------------------");
        $display("Starting simulation of 3 cases (7,4)...");
        $display("----------------------------------------");
        
        $dumpfile("hamming_scenarios.vcd");
        $dumpvars(0, tb_hamming);
        
        // define the data (Fixed for all tests)
        data_to_encode = 4'b1011;
        
        // wait for the encoder to generate the initial word
        #10; 

        // ====================================================
        // CASE 1: NO ERROR
        // ====================================================
        $display("\n--- CASE 1: NO ERROR ---");
        error_mask = 7'b0000000; // Zeroed mask
        
        // apply the error (in this case, none)
        corrupted_word = encoded_word ^ error_mask;
        #10; // wait for the decoder
        
        // show results
        mostrar_resultados(); 
        verificar_sucesso("No Error");


        // ====================================================
        // CASE 2: 1 ERROR (Should Correct)
        // ====================================================
        $display("\n--- CASE 2: 1 ERROR (Position 5 / Index 4) ---");
        error_mask = 7'b0010000; // Error in bit 4
        
        corrupted_word = encoded_word ^ error_mask;
        #10; // wait for the decoder
        
        mostrar_resultados();
        verificar_sucesso("Single Error");


        // ====================================================
        // CASE 3: 2 ERRORS (Should Fail in Hamming 7,4)
        // ====================================================
        $display("\n--- CASE 3: 2 ERRORS (Positions 3 and 5 / Indices 2 and 4) ---");
        $display("Note: Hamming(7,4) does not support 2 errors. Failure expected.");
        error_mask = 7'b0010100; // errors in bits 4 and 2
        
        corrupted_word = encoded_word ^ error_mask;
        #10; // wait for the decoder
        
        mostrar_resultados();
        verificar_sucesso("Double Error");

        $display("\n----------------------------------------");
        $stop;
    end

    // -------------------------------------------------------
    // AUXILIARY TASKS (To avoid code repetition)
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
        end
    endtask

    // task to check if it worked
    task verificar_sucesso;
        input string nome_caso;
        begin
            if (decoded_data === data_to_encode) begin
                $display(">>> RESULT [%s]: SUCCESS! Data recovered.", nome_caso);
            end else begin
                $display(">>> RESULT [%s]: FAILURE! Original data was %b, recovered %b.", nome_caso, data_to_encode, decoded_data);
            end
        end
    endtask

endmodule