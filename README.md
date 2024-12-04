# Assembly-2560
Trabalho de Assembly para o microcontrolador ATmega2560 (Arduino), disciplina Arquitetura de Computadores 2024.2

## Escopo:

O código deverá ser elaborado em linguagem de montagem (*assembly*), de forma a ser testado utilizando-se o Assembler do Atmega2560 do MicroChip Studio, considerando o que segue:

1. Armazenar uma **tabela de caracteres alfanuméricos (maiúsculas, minúsculas e dígitos)** na memória IRAM do Atmega2560, no padrão ASCII, a partir do endereço 0x200. Armazenar também o código ASCII do **espaço em branco (0x20)**. Armazenar também o código correspondente ao comando **`<ESC>` (0x1B)**.

2. Caso seja disponibilizado em uma porta de entrada o **código 0x1C**, ler uma sequência de caracteres em uma porta de entrada, usando a instrução `IN`, criando uma **tabela de sequência de caracteres**. Quando for lida o caractere `<ESC>` o programa deverá interromper a leitura. Os dados lidos devem ser armazenados em um espaço limitado de memória entre **0x300 a 0x400**. Poderão ser lidas várias sequências de caracteres diferentes, ocupando o espaço destinado ainda disponível. Quando for alcançado o limite do espaço a leitura deverá ser interrompida. Cada sequência de caracteres deve ser finalizada por um marcador de espaço em branco, que ocupa uma posição de endereço antes da próxima sequência. Caso o caractere disponibilizado na entrada não seja válido, ler um novo caractere em loop até a entrada apresentar um caractere válido.

3. Caso seja disponibilizado em uma porta de entrada o **código 0x1D**, determinar o número de caracteres presentes na **tabela de sequência de caracteres**. Armazenar o resultado no endereço de memória 0x401, apresentando também o resultado em uma porta de saída, utilizando uma instrução `OUT`.

4. Caso seja disponibilizado em uma porta de entrada o **código 0x1E**, ler um novo byte correspondente a um caractere em uma porta de entrada e contar o número de vezes que o caractere está presente na **tabela de sequência de caracteres**. Armazenar o resultado no endereço de memória 0x402. Verificar se o caractere de entrada é válido. Caso o caractere disponibilizado na entrada não seja válido, ler um novo caractere em loop até a entrada apresentar um caractere válido.
 
6. Cada operação realizada deverá, além de armazenar o resultado nas posições de memória indicada, apresentar em uma porta de saída.
