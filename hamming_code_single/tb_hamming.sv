// Testbench para Hamming Code (7,4) com Injecao de Erro
module tb_hamming;

    // Sinais de Teste
    logic [3:0] data_to_encode;
    logic [6:0] encoded_word;
    logic [6:0] corrupted_word;
    logic [3:0] decoded_data;
    logic [2:0] syndrome_internal;

    // Mascara de erro
    logic [6:0] error_mask;

    // Instanciacao dos modulos encoder e decoder
    hamming_encoder u_encoder (
        .data_in  (data_to_encode),
        .codeword (encoded_word)
    );
    hamming_decoder u_decoder (
        .codeword (corrupted_word),
        .data_out (decoded_data)
    );

    // Captura da sindrome interna do decoder para monitoramento
    assign syndrome_internal = u_decoder.syndrome;

    // Processo de teste
    initial begin
        $display("----------------------------------------");
        $display("Iniciando simulacao de injecao de erro...");
        $display("----------------------------------------");
        
        $dumpfile("hamming_error_wave.vcd");
        $dumpvars(0, tb_hamming);
        
        // definicao do dado original a ser codificado
        data_to_encode = 4'b1011;
        
        #10; // Espera o ENCODER
        
        $display(" [1] Dado de Entrada (data_to_encode): %b", data_to_encode);
        $display(" [2] Encoder gerou (encoded_word):     %b", encoded_word);

        // Definicao da mascara de erro

        error_mask = 7'b0010000;    // erro simples na posicao 5 (indice 4)
        // error_mask = 7'b0010100; // erro duplo nas posicoes 3 e 5 (indices 2 e 4)
        // error_mask = 7'b0000000; // sem erro
        
        // Aplicacao do erro
        corrupted_word = encoded_word ^ error_mask;
        
        $display(" [3] Mascara de Erro (error_mask):     %b", error_mask);
        $display(" [4] Palavra Corrompida (corrupted):   %b", corrupted_word);
        
        #10; // Espera o DECODER
        
        $display(" [5] Sindrome calculada (syndrome):    %b", syndrome_internal);
        $display(" [6] Decoder corrigiu (decoded_data):  %b", decoded_data);
        
        // Verificacao Final
        #10;
        if (decoded_data === data_to_encode) begin
            $display("\n>>> SUCESSO! O dado original foi recuperado.");
        end else begin
            $display("\n>>> FALHA! O dado original era %b, mas foi recuperado %b.",
                     data_to_encode, decoded_data);
        end
        
        $display("----------------------------------------");
        $finish; // Termina a simulacao
    end

endmodule