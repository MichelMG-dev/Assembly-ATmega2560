;
; Aluno: Michel de Melo Guimar�es - 202401569852 
;
; Define os endere�os na mem�ria
.equ BASE_ADDR = 0x200    ; Base da tabela de caracteres ASCII
.equ SEQ_ADDR = 0x300     ; In�cio do espa�o para sequ�ncias
.equ END_ADDR = 0x400     ; Fim do espa�o para sequ�ncias
.equ TRIGGER = 0x1C       ; C�digo para iniciar a leitura de sequ�ncia
.equ SAVE_COUNT = 0x1D
.equ CHAR_FREQ = 0x1E
.equ SEQ_END_ADDR = 0x500 ; Endere�o onde armazenamos o ponteiro final da sequ�ncia
.equ CHAR_COUNT = 0x401


.cseg
.org 0x0000
rjmp RESET                ; Ponto de entrada do programa

RESET:
    ; Configura��o inicial
    ldi r16, 0x00
    out DDRC, r16          ; Configura todos os pinos do PORTC como entrada
    ldi r16, 0xFF
    out PORTC, r16         ; Ativa resistores pull-up no PORTC

    ; Inicializar tabela de caracteres ASCII em BASE_ADDR
    ldi r16, HIGH(BASE_ADDR) ; Carrega a parte alta do endere�o base no registrador ZH
    out RAMPZ, r16           ; Configura o registrador de p�gina para a mem�ria IRAM
    ldi r30, LOW(BASE_ADDR)  ; Carrega a parte baixa no registrador ZL
    ldi r31, HIGH(BASE_ADDR) ; Carrega a parte alta no registrador ZH
    
    ; Armazenar caracteres mai�sculos A-Z (0x41-0x5A)
    ldi r16, 0x41            ; Primeiro caractere 'A'
ALPHA_UPPER_LOOP:
    st Z+, r16               ; Armazena o caractere no endere�o atual e incrementa Z
    inc r16                  ; Pr�ximo caractere
    cpi r16, 0x5B            ; Verifica se alcan�ou o fim ('Z' + 1)
    brne ALPHA_UPPER_LOOP    ; Se n�o, repete o loop

    ; Armazenar caracteres min�sculos a-z (0x61-0x7A)
    ldi r16, 0x61            ; Primeiro caractere 'a'
ALPHA_LOWER_LOOP:
    st Z+, r16               ; Armazena o caractere no endere�o atual e incrementa Z
    inc r16                  ; Pr�ximo caractere
    cpi r16, 0x7B            ; Verifica se alcan�ou o fim ('z' + 1)
    brne ALPHA_LOWER_LOOP    ; Se n�o, repete o loop

    ; Armazenar d�gitos 0-9 (0x30-0x39)
    ldi r16, 0x30            ; Primeiro d�gito '0'
DIGIT_LOOP:
    st Z+, r16               ; Armazena o d�gito no endere�o atual e incrementa Z
    inc r16                  ; Pr�ximo d�gito
    cpi r16, 0x3A            ; Verifica se alcan�ou o fim ('9' + 1)
    brne DIGIT_LOOP          ; Se n�o, repete o loop

    ; Armazenar o espa�o em branco (0x20)
    ldi r16, 0x20            ; C�digo ASCII do espa�o em branco
    st Z+, r16               ; Armazena o espa�o em branco

    ; Armazenar o comando <ESC> (0x1B)
    ldi r16, 0x1B            ; C�digo ASCII do <ESC>
    st Z+, r16               ; Armazena o comando <ESC>

    ; Inicia o loop principal
    rjmp MAIN_LOOP

MAIN_LOOP:
    in r16, PIND             ; L� o valor da porta de entrada
    cpi r16, TRIGGER         ; Verifica se o c�digo para iniciar foi recebido
    brne MAIN_LOOP           ; Se n�o, continua no loop

    rcall READ_SEQUENCE      ; Chama a rotina para leitura da sequ�ncia
    rjmp MAIN_LOOP           ; Retorna para o loop principal

READ_SEQUENCE:
    ; Verificar se existe uma posi��o salva para o ponteiro Z
    ldi r30, LOW(SEQ_END_ADDR)  ; Carrega a parte baixa do endere�o onde est� armazenado o ponteiro final
    ldi r31, HIGH(SEQ_END_ADDR) ; Carrega a parte alta do endere�o onde est� armazenado o ponteiro final
    ld r16, Z+                ; Carrega o valor armazenado do ponteiro final

    ; Se o ponteiro final estiver salvo, continua de onde parou
    cpi r16, 0xFF             ; Verifica se o valor armazenado � 0xFF (n�o existe valor salvo)
    ;breq RESET_POINTER        ; Se n�o houver valor salvo, reinicia o ponteiro

    ; Recupera o ponteiro final salvo (parte baixa e parte alta)
    ldi r30, LOW(SEQ_ADDR)    ; Parte baixa do endere�o de sequ�ncia
    ldi r31, HIGH(SEQ_ADDR)   ; Parte alta do endere�o de sequ�ncia
    ld r16, Z+                ; Carrega o endere�o salvo na mem�ria

    ; Se o ponteiro foi salvo, atualiza o ponteiro Z
    out RAMPZ, r16            ; Atualiza o ponteiro Z
    rjmp READ_CHAR            ; Come�a a leitura



READ_CHAR:
    in r16, PIND              ; L� um caractere da entrada
    cpi r16, 0x1B             ; Verifica se � <ESC>
    breq END_SEQUENCE         ; Se sim, termina a sequ�ncia

	in r16, PIND
	cpi r16, SAVE_COUNT
	breq STORE_NUM_CHAR

	in r16, PIND
	cpi r16, CHAR_FREQ
	breq FREQ_CHAR

    ; Verifica se o caractere � v�lido
    cpi r16, 0x20             ; Caracteres v�lidos come�am em 0x20
    brlo READ_CHAR            ; Se menor que 0x20, ignora e l� outro
    cpi r16, 0x7B             ; Caracteres v�lidos terminam em 0x7F
    brsh READ_CHAR            ; Se maior ou igual a 0x7F, ignora e l� outro

	
	inc r22
	out PINC, r16
    st Z+, r16                ; Armazena o caractere na mem�ria e incrementa Z

    ; Verifica se a mem�ria atingiu o limite de END_ADDR
    cpi r30, LOW(END_ADDR)    ; Verifica se a parte baixa do ponteiro Z atingiu o limite
    brne READ_CHAR            ; Se n�o, continua lendo
    cpi r31, HIGH(END_ADDR)   ; Verifica se a parte alta do ponteiro Z atingiu o limite
    brne READ_CHAR            ; Se n�o, continua lendo

	

STORE_NUM_CHAR:
	sts CHAR_COUNT, r22
	mov r18, r22
	out DDRC, R18
	out PORTC, R18	
	ret

END_SEQUENCE:
	ldi r16, 0x20           ; Finaliza a sequ�ncia com espa�o em branco
    st Z+, r16
    ret                       ; Retorna da sub-rotina

;FREQUENCIA DE CARACTER

FREQ_CHAR:
    in r17, PINA            ; L� o caractere de entrada
    cpi r17, 0x20           ; Verifica se � v�lido (>= 0x20)
    brlo FREQ_CHAR          ; Se menor, continua esperando
    cpi r17, 0x7B           ; Verifica se � v�lido (< 0x7F)
    brsh FREQ_CHAR          ; Se maior ou igual, continua esperando

    ldi r26, LOW(SEQ_ADDR)  ; Inicializa o ponteiro X com SEQ_ADDR
    ldi r27, HIGH(SEQ_ADDR) ; Parte alta do endere�o inicial da sequ�ncia

    clr r20                 ; Zera o contador de frequ�ncia

FREQ_CHAR_LOOP:
    ld r21, X+              ; L� o pr�ximo caractere da sequ�ncia
    cpi r21, 0x20           ; Verifica se � o delimitador de fim (0x20)
    breq FREQ_CHAR_DONE     ; Se sim, finaliza o loop

    cp r17, r21             ; Compara o caractere de entrada com o da sequ�ncia
    brne FREQ_CHAR_LOOP     ; Se diferente, continua o loop

    inc r20                 ; Incrementa o contador
    rjmp FREQ_CHAR_LOOP     ; Retorna ao in�cio do loop

FREQ_CHAR_DONE:
    sts 0x402, r20          ; Armazena o contador no endere�o 0x402
    out PORTC, r20          ; Apresenta o resultado no PORTC
    ret                     ; Retorna da sub-rotina






