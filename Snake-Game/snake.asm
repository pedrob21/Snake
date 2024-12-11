jmp Comecar

;Davi Moreira de Santana - NUSP 15447584
;Lucas Michael Genovese Huss Oliveira - NUSP 15577610
;Marcel Henrique Rodrigues Batista - NUSP 15474421
;Pedro Bernardo Rodrigues Pinto - NUSP 15590042


; 0 branco							0000 0000
; 256 marrom						0001 0000
; 512 verde							0010 0000
; 768 oliva							0011 0000
; 1024 azul marinho					0100 0000
; 1280 roxo							0101 0000
; 1536 teal							0110 0000
; 1792 prata						0111 0000
; 2048 cinza						1000 0000
; 2304 vermelho						1001 0000
; 2560 lima							1010 0000
; 2816 amarelo						1011 0000
; 3072 azul							1100 0000
; 3328 rosa							1101 0000
; 3584 aqua							1110 0000
; 3840 branco						1111 0000


PosicaoCobra: var #1               ; Posição atual da cobra
PosicaoRabo: var #1           ; Posição anterior da cobra
MacasIndex: var #1              ; Índice para o array de posição da comida
MacasPos: var #1                ; Posição atual da comida
LastKey: var #1                ; Última tecla AWSD pressionada, usada para manter o movimento
Length: var #1                 ; Comprimento da cobra
Corpo: var #300            ; Armazena as posições do corpo da cobra

alreadyHavePowerUp: var #1
PowerUpPos: var #1                ; Posição atual do Power Up
PowerUpIndex: var #1              ; Índice para o array de posição do Power Up
PowerUp: var #4

; placar


Unidade: var #1
TenScore: var #1
Centena: var #1


FakeIndex: var #1              
FakePos: var #1


static Unidade, #'0'
static TenScore, #'0'
static Centena, #'0'


Macas: var #1200
Fake: var #1500


Comecar:
    MenuScreen: ; tela de menu inicial
        call ClearScreen      
        loadn r1, #TelaApresentacao00 
        loadn r2, #2816     ; Cor amarela
        call PrintScreen     


    ; Loop do menu
    MenuLoop:
        loadn r3, #13        
        inchar r4            
        cmp r4, r3            
        jeq Inicio         
        jmp MenuLoop         


Inicio:
    call ClearScreen          
    loadn r1, #TelaJogo0      
    loadn r2, #2816            ; Cor amarela
    call PrintScreen           ; Imprime a cena do jogo na cor amarela
    loadn r5, #0               
    store Length, r5
    loadn r5, #0               
    store alreadyHavePowerUp, r5
    loadn r0, #700            
    store PosicaoCobra, r0         ; Armazena a posição na variável
    dec r0
    store Corpo, r0        ; Posição inicial do corpo da cobra
    loadn r0, #'d'             
    store LastKey, r0          ; Armazena em LastKey para manter o movimento a cada ciclo
    call PrintMacas             
    call ResetScore            


GameLoop: ; loop principal do jogo
    call Andar             
    call DrawSnake          
    call Delay
    call triggerPowerUp               
    jmp GameLoop           


TelaMorte:
    call ClearScreen         
    loadn r1, #TelaPosColisao00 ; Endereço onde a cena do menu de morte começa
    loadn r2, #4608           ; Cor vermelha
    call PrintScreen          
    call DisplayScoreTelaMorte


LoopMorte:
    loadn r2, #121             ; Código ASCII da tecla 'y'
    loadn r3, #110             ; Código ASCII da tecla 'n'
    inchar r4                
    cmp r4, r3                 ; Verifica se é 'n'
    jeq endGame               
    cmp r4, r2                 ; Verifica se é 'y'
    jeq Inicio         
    jmp LoopMorte                   


endGame: ; limpa a tela e exibe uma tela de agradecimento
    call ClearScreen        
    call printThankYouScreen
    halt


printThankYouScreen:
    loadn r1, #TelaAgradecimento00
    loadn r2, #2816                ; Cor Amarela
    call PrintScreen
    rts


; Função para desenhar a cobra
DrawSnake:
    push r0   
    push r1
    push r2
    push r3
    push r4
    push r5
    push r6


    loadn r1, #368            ; Usa o caractere 'p' para representar a cobra
    loadn r5, #' '   	       ; Também carrega ' ' para apagar o corpo
    load r0, PosicaoCobra         
    loadn r2, #Corpo      
    loadn r4, #0             
    load r6, Length
    call Delay


    DrawSnakeLoop:
        loadi r3, r2           
        outchar r1, r0        
        outchar r5, r3         ; Apaga a posição anterior
        loadn r1, #2419        ; Define o corpo com o caractere 'i' vermelho
        storei r2, r0          ; Armazena a posição atual no vetor Corpo
        mov r0, r3            
        cmp r4, r6            
        jeq DrawSnakeEnd     
        inc r4
        inc r2
        jmp DrawSnakeLoop


    DrawSnakeEnd:
        store PosicaoRabo, r3 ; Armazena a posição da cauda
        pop r6                
        pop r5
        pop r4
        pop r3
        pop r2
        pop r1
        pop r0
        rts


; Função para verificar colisão
CheckCollision:
    push r0
    push r1
    push r2
    push r3
    push r4
    push r5
    push r6
    push r7


    load r0, PosicaoCobra         ; Carrega a posição da cobra em R0
    loadn r1, #Corpo              ; Carrega o endereço do vetor dos corpos da cobra
    loadn r2, #0                  ; Inicializa o índice para o loop
    load r4, Length               ; Carrega o comprimento da cobra
    loadn r5, #'|'                ; Carrega '|' (paredes)
    load r6, FakePos              ; Carrega a posição fake


    CollisionLoop:
        cmp r2, r4               
        jeq CheckFixedPositions   ; Se terminou o loop, verifica as posições fixas


        loadi r3, r1              
        cmp r0, r3               
        jeq TelaMorte             ; Morre se a cobra tocar em si mesma


        cmp r0, r6               
        jeq TelaMorte             ; Morre se tocar na fake


        inc r2                   
        inc r1                   
        jmp CollisionLoop


    CheckFixedPositions: ; verifica colisões com objetos fixas predefinidas do mapa


        loadn r7, #256
        cmp r0, r7
        jeq TelaMorte             ; Morre se tocar na posição #256


        loadn r7, #580
        cmp r0, r7
        jeq TelaMorte             ; Morre se tocar na posição #580


        loadn r7, #915
        cmp r0, r7
        jeq TelaMorte             ; Morre se tocar na posição #915
        
        loadn r7, #164
        cmp r0, r7
        jeq TelaMorte             ; Morre se tocar na posição #164
        
        loadn r7, #1086
        cmp r0, r7
        jeq TelaMorte             ; Morre se tocar na posição #1086
        


    CollisionEnd:
        pop r7
        pop r6
        pop r5
        pop r4
        pop r3
        pop r2
        pop r1
        pop r0
        rts




Andar: ; movimentação da cobra
    push r0
    push r1
    push r2
    call Delay
    call RecalculatePosicaoCobra  
    load r0, PosicaoCobra         
    load r2, MacasPos         
    cmp r0, r2
    jeq IncreaseSnake
    load r2, PowerUpPos         
    cmp r0, r2
    jeq decreaseSnake            
    call CheckCollision  


    Andar_Skip:
        pop r2
        pop r1
        pop r0
        rts


RecalculatePosicaoCobra: ; calcula a posição da cobra baseado na tecla pressionada
    push r0
    push r1
    push r2
    push r3
    push r4
    push r5


    load r0, PosicaoCobra        
    inchar r1                 


    loadn r2, #'a'
    cmp r1, r2
    jeq MoveLeft
    ; Verifica se a tecla pressionada foi 'd'
    loadn r2, #'d'
    cmp r1, r2
    jeq MoveRight
    ; Verifica se a tecla pressionada foi 'w'
    loadn r2, #'w'
    cmp r1, r2
    jeq MoveUp
    ; Verifica se a tecla pressionada foi 's'
    loadn r2, #'s'
    cmp r1, r2
    jeq MoveDown


    ; Mantém o movimento na mesma direção
    loadn r2, #'a'
    load r1, LastKey
    cmp r1, r2
    jeq MoveLeft
    loadn r2, #'d'
    load r1, LastKey
    cmp r1, r2
    jeq MoveRight
    loadn r2, #'w'
    load r1, LastKey
    cmp r1, r2
    jeq MoveUp
    loadn r2, #'s'
    load r1, LastKey
    cmp r1, r2
    jeq MoveDown


    RecalculatePos_End: ; finaliza o calculo da posição da cobra
        store PosicaoCobra, r0   
        pop r5
        pop r4
        pop r3
        pop r2
        pop r1
        pop r0
        rts


    MoveLeft:
        loadn r1, #40
        loadn r2, #1
        mod r1, r0, r1        
        cmp r1, r2             
        jeq TelaMorte        
        load r4, LastKey
        loadn r5, #'d'
        cmp r4, r5
        jeq MoveRight
        dec r0                 
        loadn r3, #'a'
        store LastKey, r3
        jmp RecalculatePos_End


    MoveRight:
        loadn r1, #40
        loadn r2, #38
        mod r1, r0, r1        
        cmp r1, r2             
        jeq TelaMorte      
        load r4, LastKey
        loadn r5, #'a'
        cmp r4, r5
        jeq MoveLeft
        inc r0                
        loadn r3, #'d'
        store LastKey, r3
        jmp RecalculatePos_End


    MoveUp:
        loadn r1, #160
        cmp r0, r1            
        jle TelaMorte        
        load r4, LastKey
        loadn r5, #'s'
        cmp r4, r5
        jeq MoveDown
        loadn r1, #40
        sub r0, r0, r1       
        loadn r3, #'w'
        store LastKey, r3
        jmp RecalculatePos_End


    MoveDown:
        loadn r1, #1119
        cmp r0, r1             
        jgr TelaMorte        
        load r4, LastKey
        loadn r5, #'w'
        cmp r4, r5
        jeq MoveUp
        loadn r1, #40
        add r0, r0, r1        
        loadn r3, #'s'
        store LastKey, r3
        jmp RecalculatePos_End


IncreaseSnake: ; aumenta o tamanho da cobra
    push r0
    push r1
    push r2


    call PrintMacas            ; Se a cobra come a comida, imprime outra
    call UpdateScore
    call PrintFake         
    load r0, PosicaoRabo     
    load r2, Length          
    loadn r1, #Corpo
    inc r2                    
    add r1, r1, r2           
    storei r1, r0            
    store Length, r2      


    pop r2
    pop r1
    pop r0
    jmp Andar_Skip


ClearScreen:
    push r0
    push r1


    loadn r0, #1200           ; Define 1200 como o número de posições para limpar na tela
    loadn r1, #' '           


    ClearScreenLoop:
        dec r0               
        outchar r1, r0       
        jnz ClearScreenLoop  


    pop r1
    pop r0
    rts


PrintScreen:
    push r0
    push r3
    push r4
    push r5


    loadn r0, #0              ; Posição inicial deve ser o começo da tela
    loadn r3, #40             ; Passa para a próxima linha
    loadn r4, #41             ; Incremento do ponteiro
    loadn r5, #1200           ; Limite da tela


    PrintScreenLoop:
        call PrintStr         ; Chama a função para imprimir cada pixel
        add r0, r0, r3        ; Incrementa a posição para a próxima linha na tela
        add r1, r1, r4        ; Incrementa o ponteiro para a próxima linha na memória
        cmp r0, r5            ; Verifica se o fim da tela foi alcançado
        jne PrintScreenLoop


    pop r5
    pop r4
    pop r3
    pop r0
    rts


PrintStr:
    push r0
    push r1
    push r2
    push r3
    push r4


    loadn r3, #'\0'           ; Critério de parada


    PrintStrLoop:
        loadi r4, r1          ; Obtém o primeiro caractere
        cmp r4, r3            ; Verifica o critério de parada
        jeq PrintStrExit
        add r4, r2, r4        ; Adiciona a cor
        outchar r4, r0        ; Imprime o caractere na tela
        inc r0                ; Incrementa a posição na tela
        inc r1                ; Incrementa o ponteiro da string
        jmp PrintStrLoop


    PrintStrExit:
        pop r4
        pop r3
        pop r2
        pop r1
        pop r0
        rts


PrintMacas: ; imprime maças
    push r0
    push r1
    push r2
    push r3


    loadn r1, #2368            ; Caractere @ vermelho
    loadn r2, #Macas         
    load r3, MacasIndex     
    add r0, r2, r3            ; Calcula a posição da comida
    loadi r2, r0              
    outchar r1, r2          


    inc r3                   
    store MacasIndex, r3
    store MacasPos, r2


    pop r3
    pop r2
    pop r1
    pop r0
    rts


PrintFake:
    push r0
    push r1
    push r2
    push r3


    loadn r1, #2603           
    loadn r2, #Fake         
    load r3, FakeIndex     
    add r0, r2, r3            
    loadi r2, r0              
    outchar r1, r2          


    inc r3                   
    store FakeIndex, r3
    store FakePos, r2


    pop r3
    pop r2
    pop r1
    pop r0
    rts


Delay:
    push r0
    push r1


    loadn r1, #200            ; Define o valor inicial do contador externo
    DelayLoop2:
        loadn r0, #600       ; Define o valor inicial do contador interno
    DelayLoop:
        dec r0                ; Decrementa o contador interno
        jnz DelayLoop         ; Se não zero, repete o loop interno
        dec r1                ; Decrementa o contador externo
        jnz DelayLoop2        ; Se não zero, repete o loop externo


    pop r1
    pop r0
    rts




DelayInitScreen:
    push r0
    push r1


    loadn r1, #1000            ; Define o valor inicial do contador externo
    DelayInitLoop2:
        loadn r0, #1200       ; Define o valor inicial do contador interno
    DelayInitLoop:
        dec r0                ; Decrementa o contador interno
        jnz DelayInitLoop         ; Se não zero, repete o loop interno
        dec r1                ; Decrementa o contador externo
        jnz DelayInitLoop2        ; Se não zero, repete o loop externo


    pop r1
    pop r0
    rts


ResetScore:
    loadn r0, #'0'
    store Unidade, r0
    store TenScore, r0
    store Centena, r0
    call UpdateScoreDisplay
    rts


UpdateScore:
    load r0, Unidade   
    loadn r1, #'9'          
    cmp r1, r0
    jeq AddTens


    inc r0
    store Unidade, r0
    jmp UpdateScoreDisplay


AddTens:                   
    loadn r0, #'0'
    store Unidade, r0


    load r0, TenScore
    loadn r1, #'9'       
    cmp r1, r0
    jeq AddHundreds


    inc r0
    store TenScore, r0
    jmp UpdateScoreDisplay


AddHundreds:                
    loadn r0, #'0'
    store TenScore, r0


    load r0, Centena
    loadn r1, #'9'        
    cmp r1, r0
    jeq TelaMorte


    inc r0
    store Centena, r0
    jmp UpdateScoreDisplay


UpdateScoreDisplay:
    load r0, Unidade
    loadn r1, #78
    outchar r0, r1


    load r0, TenScore
    loadn r1, #77
    outchar r0, r1


    load r0, Centena
    loadn r1, #76
    outchar r0, r1


    rts


DisplayScoreTelaMorte:
    load r0, Unidade
    loadn r1, #858          
    outchar r0, r1


    load r0, TenScore
    loadn r1, #857         
    outchar r0, r1


    load r0, Centena
    loadn r1, #856         
    outchar r0, r1

    rts


PrintLifeSavier:
    ; Power up that will reduce the snake length
    push r0
    push r1
    push r2
    push r3

    loadn r1, #2907            ; Caractere '[' amarelo
    loadn r2, #PowerUp         
    load r3, PowerUpIndex     
    add r0, r2, r3            
    loadi r2, r0              
    outchar r1, r2          

    inc r3                   
    store PowerUpIndex, r3
    store PowerUpPos, r2
    loadn r1, #1
    store alreadyHavePowerUp, r1

    pop r3
    pop r2
    pop r1
    pop r0
    rts



decreaseSnake:
    push r0
    push r1
    push r2

    load r0, PosicaoRabo     
    load r2, Length ; Não execute a diminuição caso o tamanho da cobra seja menor que 2

    call UpdateScore
    loadn r1, #0
    store alreadyHavePowerUp, r1          
    loadn r1, #Corpo
    dec r2  
    sub r1, r1, r2           
    storei r1, r0            
    store Length, r2      

    pop r2
    pop r1
    pop r0
    jmp Andar_Skip


triggerPowerUp:
    push r0
    push r1
    push r2
    push r3

    load r3, alreadyHavePowerUp
    loadn r0, #1
    cmp r0, r3
    jeq SkipPowerUp        ; Verifica se existe um power up na tela

    ; Carregar os valores das pontuações
    load r0, Unidade	
    load r1, TenScore
    load r2, Centena

    loadn r3, #'0'        ; ASCII de '0'

    ; Converter caracteres para números
    sub r0, r0, r3        
    sub r1, r1, r3        
    sub r2, r2, r3        

    loadn r3, #10
    mul r1, r1, r3         ; Multiplica as dezenas por 10
    add r0, r0, r1         ; Soma unidade e dezenas

    loadn r3, #100
    mul r2, r2, r3         ; Multiplica as centenas por 100
    add r0, r0, r2         ; Soma centenas ao total

    loadn r3, #0
    cmp r0, r3
    jeq SkipPowerUp     ; Verifica se o score é zero

    ; Verificar múltiplo de 5
    loadn r1, #5
    mod r0, r0, r1         ; Resto da divisão por 5
    loadn r3, #0
    cmp r0, r3
    jne SkipPowerUp        ; Se não for múltiplo de 5, pula


    call PrintLifeSavier   ; Chama o power-up

SkipPowerUp:    
    pop r3
    pop r2
    pop r1
    pop r0
    jmp GameLoop


; tela principal do jogo
TelaJogo0  : string "|======================================|"
TelaJogo1  : string "|MACAS COMIDAS                         |"
TelaJogo2  : string "|--------------------------------------|"
TelaJogo3  : string "|                                      |"
TelaJogo4  : string "|   x                                  |"
TelaJogo5  : string "|                                      |"
TelaJogo6  : string "|               x                      |"
TelaJogo7  : string "|                                      |"
TelaJogo8  : string "|                                      |"
TelaJogo9  : string "|                                      |"
TelaJogo10 : string "|                                      |" 
TelaJogo11 : string "|                                      |"
TelaJogo12 : string "|                                      |"
TelaJogo13 : string "|                                      |"
TelaJogo14 : string "|                   x                  |"
TelaJogo15 : string "|                                      |"
TelaJogo16 : string "|                                      |"
TelaJogo17 : string "|                                      |"
TelaJogo18 : string "|                                      |"
TelaJogo19 : string "|                                      |"
TelaJogo20 : string "|                                      |"
TelaJogo21 : string "|                                      |"
TelaJogo22 : string "|                                  x   |" 
TelaJogo23 : string "|                                      |"
TelaJogo24 : string "|                                      |"
TelaJogo25 : string "|                                      |"
TelaJogo26 : string "|                                      |"
TelaJogo27 : string "|     x                                |"
TelaJogo28 : string "|                                      |"
TelaJogo29 : string "|======================================|"




TelaApresentacao00: string "                                        "
TelaApresentacao01: string "                                        "
TelaApresentacao02: string "                                        "
TelaApresentacao03: string "                                        "
TelaApresentacao04: string "                                        "
TelaApresentacao05: string "                                        "
TelaApresentacao06: string "            JOGO CRIADO POR:            "
TelaApresentacao07: string "                                        "
TelaApresentacao08: string "             DAVI MOREIRA               "
TelaApresentacao09: string "             LUCAS MICHAEL              "
TelaApresentacao10: string "            PEDRO BERNARDO              "
TelaApresentacao11: string "            MARCEL HENRIQUE             "
TelaApresentacao12: string "                                        "
TelaApresentacao13: string "                                        "
TelaApresentacao14: string "                                        "
TelaApresentacao15: string "                                        "
TelaApresentacao16: string "                COMANDOS:               "
TelaApresentacao17: string "                                        "
TelaApresentacao18: string "        W  - MOVE PARA CIMA             "
TelaApresentacao19: string "        S  - MOVE PARA BAIXO            "
TelaApresentacao20: string "        A  - MOVE PARA ESQUERDA         "
TelaApresentacao21: string "        D  - MOVE PARA DIREITA          "
TelaApresentacao22: string "                                        "
TelaApresentacao23: string "       NEM *TUDO* EH O QUE PARECE       "
TelaApresentacao24: string "           CUIDADO COM OS x E +         "
TelaApresentacao25: string "                                        "
TelaApresentacao26: string "               BOM JOGO!                "
TelaApresentacao27: string "                                        "
TelaApresentacao28: string "       PRESSIONE ENTER PARA COMECAR     "
TelaApresentacao29: string "                                        "
; tela de final do jogo


TelaPosColisao00: string "                                        "
TelaPosColisao01: string "                                        "
TelaPosColisao02: string "                                        "
TelaPosColisao03: string "                                        "
TelaPosColisao04: string "                                        "
TelaPosColisao05: string "                                        "
TelaPosColisao06: string "                                        "
TelaPosColisao07: string "                                        "
TelaPosColisao08: string "                                        "
TelaPosColisao09: string "                                        "
TelaPosColisao10: string "                                        "
TelaPosColisao11: string "                                        "
TelaPosColisao12: string "              VOCE PERDEU!!!            "
TelaPosColisao13: string "                                        "
TelaPosColisao14: string "                                        "
TelaPosColisao15: string "                                        "
TelaPosColisao16: string "     DESEJA JOGAR NOVAMENTE?  <Y/N>     "
TelaPosColisao17: string "                                        "
TelaPosColisao18: string "                                        "
TelaPosColisao19: string "                                        "
TelaPosColisao20: string "                                        "
TelaPosColisao21: string "     VOCE COMEU:    MACAS               "
TelaPosColisao22: string "                                        "
TelaPosColisao23: string "                                        "
TelaPosColisao24: string "                                        "
TelaPosColisao25: string "                                        "
TelaPosColisao26: string "                                        "
TelaPosColisao27: string "                                        "
TelaPosColisao28: string "                                        "
TelaPosColisao29: string "                                        "


TelaAgradecimento00: string "                                        "
TelaAgradecimento01: string "                                        "
TelaAgradecimento02: string "                                        "
TelaAgradecimento03: string "                                        "
TelaAgradecimento04: string "                                        "
TelaAgradecimento05: string "                                        "
TelaAgradecimento06: string "                                        "
TelaAgradecimento07: string "                                        "
TelaAgradecimento08: string "                                        "
TelaAgradecimento09: string "                                        "
TelaAgradecimento10: string "                                        "
TelaAgradecimento11: string "                                        "
TelaAgradecimento12: string "           OBRIGADO POR JOGAR!!!        "
TelaAgradecimento13: string "                                        "
TelaAgradecimento14: string "                                        "
TelaAgradecimento15: string "                                        "
TelaAgradecimento16: string "                                        "
TelaAgradecimento17: string "                                        "
TelaAgradecimento18: string "                                        "
TelaAgradecimento19: string "                                        "
TelaAgradecimento20: string "                                        "
TelaAgradecimento21: string "                                        "
TelaAgradecimento22: string "                                        "
TelaAgradecimento23: string "                                        "
TelaAgradecimento24: string "                                        "
TelaAgradecimento25: string "                                        "
TelaAgradecimento26: string "                                        "
TelaAgradecimento27: string "                                        "
TelaAgradecimento28: string "                                        "
TelaAgradecimento29: string "                                        "

static PowerUp + #0, #265
static PowerUp + #1, #331
static PowerUp + #2, #515
static PowerUp + #3, #1047

static Fake + #0, #577
static Fake + #1, #1238
static Fake + #2, #244
static Fake + #3, #662
static Fake + #4, #496
static Fake + #5, #1128
static Fake + #6, #817
static Fake + #7, #1117
static Fake + #8, #1113
static Fake + #9, #601
static Fake + #10, #490
static Fake + #11, #655
static Fake + #12, #215
static Fake + #13, #420
static Fake + #14, #580
static Fake + #15, #215
static Fake + #16, #317
static Fake + #17, #648
static Fake + #18, #769
static Fake + #19, #690
static Fake + #20, #971
static Fake + #21, #802
static Fake + #22, #883
static Fake + #23, #434
static Fake + #24, #305
static Fake + #25, #1036
static Fake + #26, #427
static Fake + #27, #498
static Fake + #28, #379
static Fake + #29, #571
static Fake + #30, #1118
static Fake + #31, #885
static Fake + #32, #1029
static Fake + #33, #1008
static Fake + #34, #257
static Fake + #35, #233
static Fake + #36, #602
static Fake + #37, #521
static Fake + #38, #951
static Fake + #39, #791
static Fake + #40, #241
static Fake + #41, #667
static Fake + #42, #447
static Fake + #43, #617
static Fake + #44, #1111
static Fake + #45, #920
static Fake + #46, #980
static Fake + #47, #440
static Fake + #48, #649
static Fake + #49, #290
static Fake + #50, #768


static Macas + #0, #536
static Macas + #1, #1097
static Macas + #2, #1020
static Macas + #3, #620
static Macas + #4, #451
static Macas + #5, #1078
static Macas + #6, #772
static Macas + #7, #1047
static Macas + #8, #976
static Macas + #9, #565
static Macas + #10, #490
static Macas + #11, #515
static Macas + #12, #175
static Macas + #13, #350
static Macas + #14, #510
static Macas + #15, #165
static Macas + #16, #275
static Macas + #17, #605
static Macas + #18, #726
static Macas + #19, #654
static Macas + #20, #938
static Macas + #21, #766
static Macas + #22, #841
static Macas + #23, #391
static Macas + #24, #163
static Macas + #25, #990
static Macas + #26, #388
static Macas + #27, #450
static Macas + #28, #331
static Macas + #29, #534
static Macas + #30, #1038
static Macas + #31, #847
static Macas + #32, #989
static Macas + #33, #968
static Macas + #34, #216
static Macas + #35, #194
static Macas + #36, #567
static Macas + #37, #485
static Macas + #38, #913
static Macas + #39, #751
static Macas + #40, #207
static Macas + #41, #628
static Macas + #42, #407
static Macas + #43, #572
static Macas + #44, #1051
static Macas + #45, #885
static Macas + #46, #945
static Macas + #47, #402
static Macas + #48, #607
static Macas + #49, #258
static Macas + #50, #725
static Macas + #51, #550
static Macas + #52, #463
static Macas + #53, #291
static Macas + #54, #949
static Macas + #55, #431
static Macas + #56, #796
static Macas + #57, #643
static Macas + #58, #794
static Macas + #59, #979
static Macas + #60, #1014
static Macas + #61, #975
static Macas + #62, #300
static Macas + #63, #267
static Macas + #64, #1056
static Macas + #65, #710
static Macas + #66, #481
static Macas + #67, #1048
static Macas + #68, #314
static Macas + #69, #532
static Macas + #70, #763
static Macas + #71, #542
static Macas + #72, #1023
static Macas + #73, #1044
static Macas + #74, #555
static Macas + #75, #354
static Macas + #76, #386
static Macas + #77, #340
static Macas + #78, #478
static Macas + #79, #994
static Macas + #80, #797
static Macas + #81, #665
static Macas + #82, #382
static Macas + #83, #269
static Macas + #84, #337
static Macas + #85, #557
static Macas + #86, #1104
static Macas + #87, #943
static Macas + #88, #948
static Macas + #89, #728
static Macas + #90, #822
static Macas + #91, #531
static Macas + #92, #624
static Macas + #93, #881
static Macas + #94, #409
static Macas + #95, #1063
static Macas + #96, #283
static Macas + #97, #983
static Macas + #98, #972
static Macas + #99, #525
static Macas + #100, #958
static Macas + #101, #365
static Macas + #102, #929
static Macas + #103, #577
static Macas + #104, #831
static Macas + #105, #708
static Macas + #106, #818
static Macas + #107, #771
static Macas + #108, #201
static Macas + #109, #435
static Macas + #110, #593
static Macas + #111, #294
static Macas + #112, #677
static Macas + #113, #215
static Macas + #114, #462
static Macas + #115, #1010
static Macas + #116, #816
static Macas + #117, #564
static Macas + #118, #753
static Macas + #119, #211
static Macas + #120, #658
static Macas + #121, #325
static Macas + #122, #898
static Macas + #123, #579
static Macas + #124, #210
static Macas + #125, #649
static Macas + #126, #568
static Macas + #127, #1087
static Macas + #128, #196
static Macas + #129, #422
static Macas + #130, #830
static Macas + #131, #1036
static Macas + #132, #357
static Macas + #133, #326
static Macas + #134, #805
static Macas + #135, #584
static Macas + #136, #276
static Macas + #137, #547
static Macas + #138, #987
static Macas + #139, #798
static Macas + #140, #695
static Macas + #141, #874
static Macas + #142, #1019
static Macas + #143, #1102
static Macas + #144, #379
static Macas + #145, #511
static Macas + #146, #433
static Macas + #147, #1109
static Macas + #148, #1107
static Macas + #149, #928
static Macas + #150, #457
static Macas + #151, #651
static Macas + #152, #735
static Macas + #153, #894
static Macas + #154, #780
static Macas + #155, #1108
static Macas + #156, #214
static Macas + #157, #349
static Macas + #158, #946
static Macas + #159, #854
static Macas + #160, #604
static Macas + #161, #705
static Macas + #162, #459
static Macas + #163, #686
static Macas + #164, #370
static Macas + #165, #282
static Macas + #166, #343
static Macas + #167, #917
static Macas + #168, #569
static Macas + #169, #251
static Macas + #170, #1029
static Macas + #171, #896
static Macas + #172, #701
static Macas + #173, #832
static Macas + #174, #259
static Macas + #175, #204
static Macas + #176, #638
static Macas + #177, #714
static Macas + #178, #985
static Macas + #179, #295
static Macas + #180, #668
static Macas + #181, #627
static Macas + #182, #891
static Macas + #183, #452
static Macas + #184, #234
static Macas + #185, #642
static Macas + #186, #523
static Macas + #187, #845
static Macas + #188, #1100
static Macas + #189, #869
static Macas + #190, #302
static Macas + #191, #746
static Macas + #192, #792
static Macas + #193, #1061
static Macas + #194, #363
static Macas + #195, #614
static Macas + #196, #587
static Macas + #197, #310
static Macas + #198, #915
static Macas + #199, #1012
static Macas + #200, #426
static Macas + #201, #663
static Macas + #202, #712
static Macas + #203, #212
static Macas + #204, #802
static Macas + #205, #730
static Macas + #206, #487
static Macas + #207, #807
static Macas + #208, #1004
static Macas + #209, #1002
static Macas + #210, #1083
static Macas + #211, #414
static Macas + #212, #857
static Macas + #213, #873
static Macas + #214, #1067
static Macas + #215, #248
static Macas + #216, #471
static Macas + #217, #747
static Macas + #218, #1094
static Macas + #219, #436
static Macas + #220, #174
static Macas + #221, #1082
static Macas + #222, #806
static Macas + #223, #856
static Macas + #224, #438
static Macas + #225, #997
static Macas + #226, #942
static Macas + #227, #432
static Macas + #228, #860
static Macas + #229, #739
static Macas + #230, #924
static Macas + #231, #506
static Macas + #232, #226
static Macas + #233, #693
static Macas + #234, #886
static Macas + #235, #764
static Macas + #236, #289
static Macas + #237, #956
static Macas + #238, #644
static Macas + #239, #770
static Macas + #240, #795
static Macas + #241, #205
static Macas + #242, #190
static Macas + #243, #901
static Macas + #244, #425
static Macas + #245, #573
static Macas + #246, #1071
static Macas + #247, #698
static Macas + #248, #844
static Macas + #249, #423
static Macas + #250, #922
static Macas + #251, #926
static Macas + #252, #724
static Macas + #253, #344
static Macas + #254, #941
static Macas + #255, #824
static Macas + #256, #317
static Macas + #257, #419
static Macas + #258, #801
static Macas + #259, #252
static Macas + #260, #641
static Macas + #261, #509
static Macas + #262, #397
static Macas + #263, #223
static Macas + #264, #316
static Macas + #265, #472
static Macas + #266, #892
static Macas + #267, #1049
static Macas + #268, #167
static Macas + #269, #288
static Macas + #270, #1089
static Macas + #271, #884
static Macas + #272, #862
static Macas + #273, #466
static Macas + #274, #890
static Macas + #275, #378
static Macas + #276, #995
static Macas + #277, #396
static Macas + #278, #1001
static Macas + #279, #522
static Macas + #280, #571
static Macas + #281, #870
static Macas + #282, #303
static Macas + #283, #533
static Macas + #284, #264
static Macas + #285, #323
static Macas + #286, #262
static Macas + #287, #721
static Macas + #288, #691
static Macas + #289, #619
static Macas + #290, #909
static Macas + #291, #424
static Macas + #292, #286
static Macas + #293, #808
static Macas + #294, #364
static Macas + #295, #756
static Macas + #296, #220
static Macas + #297, #1081
static Macas + #298, #273
static Macas + #299, #758
static Macas + #300, #322
static Macas + #301, #415
static Macas + #302, #304
static Macas + #303, #1033
static Macas + #304, #384
static Macas + #305, #878
static Macas + #306, #166
static Macas + #307, #1116
static Macas + #308, #1091
static Macas + #309, #733
static Macas + #310, #1084
static Macas + #311, #952
static Macas + #312, #998
static Macas + #313, #306
static Macas + #314, #249
static Macas + #315, #1065
static Macas + #316, #1103
static Macas + #317, #675
static Macas + #318, #514
static Macas + #319, #442
static Macas + #320, #966
static Macas + #321, #963
static Macas + #322, #526
static Macas + #323, #1030
static Macas + #324, #313
static Macas + #325, #189
static Macas + #326, #969
static Macas + #327, #305
static Macas + #328, #1034
static Macas + #329, #430
static Macas + #330, #934
static Macas + #331, #652
static Macas + #332, #329
static Macas + #333, #173
static Macas + #334, #366
static Macas + #335, #496
static Macas + #336, #347
static Macas + #337, #561
static Macas + #338, #597
static Macas + #339, #855
static Macas + #340, #583
static Macas + #341, #702
static Macas + #342, #842
static Macas + #343, #1011
static Macas + #344, #461
static Macas + #345, #804
static Macas + #346, #346
static Macas + #347, #437
static Macas + #348, #540
static Macas + #349, #476
static Macas + #350, #837
static Macas + #351, #455
static Macas + #352, #387
static Macas + #353, #1054
static Macas + #354, #676
static Macas + #355, #636
static Macas + #356, #1095
static Macas + #357, #954
static Macas + #358, #743
static Macas + #359, #342
static Macas + #360, #351
static Macas + #361, #947
static Macas + #362, #441
static Macas + #363, #556
static Macas + #364, #825
static Macas + #365, #817
static Macas + #366, #779
static Macas + #367, #964
static Macas + #368, #381
static Macas + #369, #473
static Macas + #370, #301
static Macas + #371, #241
static Macas + #372, #828
static Macas + #373, #809
static Macas + #374, #1027
static Macas + #375, #263
static Macas + #376, #810
static Macas + #377, #925
static Macas + #378, #231
static Macas + #379, #867
static Macas + #380, #464
static Macas + #381, #731
static Macas + #382, #608
static Macas + #383, #255
static Macas + #384, #546
static Macas + #385, #734
static Macas + #386, #1117
static Macas + #387, #421
static Macas + #388, #673
static Macas + #389, #394
static Macas + #390, #410
static Macas + #391, #937
static Macas + #392, #871
static Macas + #393, #566
static Macas + #394, #1111
static Macas + #395, #260
static Macas + #396, #689
static Macas + #397, #477
static Macas + #398, #356
static Macas + #399, #398
static Macas + #400, #609
static Macas + #401, #1058
static Macas + #402, #447
static Macas + #403, #281
static Macas + #404, #377
static Macas + #405, #1070
static Macas + #406, #406
static Macas + #407, #781
static Macas + #408, #229
static Macas + #409, #492
static Macas + #410, #601
static Macas + #411, #988
static Macas + #412, #1021
static Macas + #413, #537
static Macas + #414, #615
static Macas + #415, #1092
static Macas + #416, #467
static Macas + #417, #973
static Macas + #418, #843
static Macas + #419, #375
static Macas + #420, #711
static Macas + #421, #367
static Macas + #422, #933
static Macas + #423, #238
static Macas + #424, #697
static Macas + #425, #541
static Macas + #426, #1016
static Macas + #427, #411
static Macas + #428, #1113
static Macas + #429, #272
static Macas + #430, #393
static Macas + #431, #202
static Macas + #432, #1042
static Macas + #433, #594
static Macas + #434, #744
static Macas + #435, #1064
static Macas + #436, #581
static Macas + #437, #1101
static Macas + #438, #270
static Macas + #439, #591
static Macas + #440, #768
static Macas + #441, #740
static Macas + #442, #986
static Macas + #443, #195
static Macas + #444, #332
static Macas + #445, #932
static Macas + #446, #257
static Macas + #447, #254
static Macas + #448, #836
static Macas + #449, #852
static Macas + #450, #1118
static Macas + #451, #783
static Macas + #452, #670
static Macas + #453, #502
static Macas + #454, #660
static Macas + #455, #246
static Macas + #456, #188
static Macas + #457, #418
static Macas + #458, #713
static Macas + #459, #1090
static Macas + #460, #528
static Macas + #461, #951
static Macas + #462, #392
static Macas + #463, #803
static Macas + #464, #598
static Macas + #465, #848
static Macas + #466, #521
static Macas + #467, #448
static Macas + #468, #187
static Macas + #469, #774
static Macas + #470, #612
static Macas + #471, #784
static Macas + #472, #328
static Macas + #473, #232
static Macas + #474, #454
static Macas + #475, #685
static Macas + #476, #769
static Macas + #477, #1003
static Macas + #478, #978
static Macas + #479, #782
static Macas + #480, #980
static Macas + #481, #390
static Macas + #482, #475
static Macas + #483, #911
static Macas + #484, #887
static Macas + #485, #741
static Macas + #486, #443
static Macas + #487, #1096
static Macas + #488, #1068
static Macas + #489, #266
static Macas + #490, #529
static Macas + #491, #338
static Macas + #492, #1017
static Macas + #493, #570
static Macas + #494, #465
static Macas + #495, #961
static Macas + #496, #633
static Macas + #497, #897
static Macas + #498, #875
static Macas + #499, #895
static Macas + #500, #355
static Macas + #501, #750
static Macas + #502, #709
static Macas + #503, #773
static Macas + #504, #683
static Macas + #505, #324
static Macas + #506, #967
static Macas + #507, #850
static Macas + #508, #191
static Macas + #509, #914
static Macas + #510, #1106
static Macas + #511, #469
static Macas + #512, #403
static Macas + #513, #737
static Macas + #514, #664
static Macas + #515, #228
static Macas + #516, #757
static Macas + #517, #429
static Macas + #518, #687
static Macas + #519, #265
static Macas + #520, #893
static Macas + #521, #866
static Macas + #522, #268
static Macas + #523, #586
static Macas + #524, #549
static Macas + #525, #504
static Macas + #526, #791
static Macas + #527, #877
static Macas + #528, #562
static Macas + #529, #1060
static Macas + #530, #846
static Macas + #531, #197
static Macas + #532, #858
static Macas + #533, #524
static Macas + #534, #376
static Macas + #535, #299
static Macas + #536, #1015
static Macas + #537, #775
static Macas + #538, #706
static Macas + #539, #1073
static Macas + #540, #456
static Macas + #541, #787
static Macas + #542, #1035
static Macas + #543, #965
static Macas + #544, #408
static Macas + #545, #287
static Macas + #546, #330
static Macas + #547, #551
static Macas + #548, #617
static Macas + #549, #851
static Macas + #550, #827
static Macas + #551, #380
static Macas + #552, #900
static Macas + #553, #244
static Macas + #554, #352
static Macas + #555, #790
static Macas + #556, #602
static Macas + #557, #755
static Macas + #558, #716
static Macas + #559, #176
static Macas + #560, #284
static Macas + #561, #180
static Macas + #562, #1037
static Macas + #563, #935
static Macas + #564, #907
static Macas + #565, #548
static Macas + #566, #245
static Macas + #567, #247
static Macas + #568, #530
static Macas + #569, #630
static Macas + #570, #315
static Macas + #571, #694
static Macas + #572, #369
static Macas + #573, #218
static Macas + #574, #235
static Macas + #575, #991
static Macas + #576, #219
static Macas + #577, #1007
static Macas + #578, #427
static Macas + #579, #939
static Macas + #580, #493
static Macas + #581, #474
static Macas + #582, #483
static Macas + #583, #236
static Macas + #584, #575
static Macas + #585, #503
static Macas + #586, #1110
static Macas + #587, #953
static Macas + #588, #646
static Macas + #589, #762
static Macas + #590, #460
static Macas + #591, #974
static Macas + #592, #341
static Macas + #593, #1066
static Macas + #594, #667
static Macas + #595, #611
static Macas + #596, #703
static Macas + #597, #655
static Macas + #598, #230
static Macas + #599, #271
static Macas + #600, #930
static Macas + #601, #821
static Macas + #602, #692
static Macas + #603, #789
static Macas + #604, #1105
static Macas + #605, #899
static Macas + #606, #865
static Macas + #607, #811
static Macas + #608, #179
static Macas + #609, #833
static Macas + #610, #707
static Macas + #611, #992
static Macas + #612, #458
static Macas + #613, #786
static Macas + #614, #736
static Macas + #615, #908
static Macas + #616, #616
static Macas + #617, #554
static Macas + #618, #1008
static Macas + #619, #576
static Macas + #620, #977
static Macas + #621, #1041
static Macas + #622, #696
static Macas + #623, #372
static Macas + #624, #729
static Macas + #625, #1072
static Macas + #626, #669
static Macas + #627, #345
static Macas + #628, #912
static Macas + #629, #516
static Macas + #630, #335
static Macas + #631, #318
static Macas + #632, #1032
static Macas + #633, #931
static Macas + #634, #508
static Macas + #635, #1024
static Macas + #636, #468
static Macas + #637, #767
static Macas + #638, #563
static Macas + #639, #637
static Macas + #640, #585
static Macas + #641, #761
static Macas + #642, #916
static Macas + #643, #666
static Macas + #644, #512
static Macas + #645, #820
static Macas + #646, #626
static Macas + #647, #1077
static Macas + #648, #927
static Macas + #649, #362
static Macas + #650, #1031
static Macas + #651, #653
static Macas + #652, #1052
static Macas + #653, #906
static Macas + #654, #498
static Macas + #655, #486
static Macas + #656, #1088
static Macas + #657, #835
static Macas + #658, #1099
static Macas + #659, #224
static Macas + #660, #859
static Macas + #661, #348
static Macas + #662, #723
static Macas + #663, #172
static Macas + #664, #727
static Macas + #665, #513
static Macas + #666, #168
static Macas + #667, #1006
static Macas + #668, #416
static Macas + #669, #444
static Macas + #670, #982
static Macas + #671, #596
static Macas + #672, #777
static Macas + #673, #1098
static Macas + #674, #227
static Macas + #675, #754
static Macas + #676, #290
static Macas + #677, #242
static Macas + #678, #923
static Macas + #679, #621
static Macas + #680, #311
static Macas + #681, #588
static Macas + #682, #405
static Macas + #683, #785
static Macas + #684, #1074
static Macas + #685, #374
static Macas + #686, #1086
static Macas + #687, #327
static Macas + #688, #622
static Macas + #689, #905
static Macas + #690, #539
static Macas + #691, #420
static Macas + #692, #936
static Macas + #693, #297
static Macas + #694, #518
static Macas + #695, #815
static Macas + #696, #181
static Macas + #697, #552
static Macas + #698, #169
static Macas + #699, #984
static Macas + #700, #1022
static Macas + #701, #589
static Macas + #702, #491
static Macas + #703, #250
static Macas + #704, #237
static Macas + #705, #657
static Macas + #706, #631
static Macas + #707, #645
static Macas + #708, #274
static Macas + #709, #580
static Macas + #710, #682
static Macas + #711, #955
static Macas + #712, #823
static Macas + #713, #333
static Macas + #714, #413
static Macas + #715, #312
static Macas + #716, #849
static Macas + #717, #674
static Macas + #718, #192
static Macas + #719, #185
static Macas + #720, #1043
static Macas + #721, #595
static Macas + #722, #225
static Macas + #723, #868
static Macas + #724, #389
static Macas + #725, #590
static Macas + #726, #1059
static Macas + #727, #650
static Macas + #728, #217
static Macas + #729, #629
static Macas + #730, #1026
static Macas + #731, #940
static Macas + #732, #981
static Macas + #733, #904
static Macas + #734, #748
static Macas + #735, #634
static Macas + #736, #970
static Macas + #737, #678
static Macas + #738, #962
static Macas + #739, #902
static Macas + #740, #206
static Macas + #741, #864
static Macas + #742, #648
static Macas + #743, #717
static Macas + #744, #1085
static Macas + #745, #495
static Macas + #746, #353
static Macas + #747, #883
static Macas + #748, #417
static Macas + #749, #882
static Macas + #750, #198
static Macas + #751, #178
static Macas + #752, #1069
static Macas + #753, #164
static Macas + #754, #412
static Macas + #755, #1075
static Macas + #756, #186
static Macas + #757, #863
static Macas + #758, #428
static Macas + #759, #358
static Macas + #760, #889
static Macas + #761, #944
static Macas + #762, #578
static Macas + #763, #778
static Macas + #764, #950
static Macas + #765, #309
static Macas + #766, #704
static Macas + #767, #545
static Macas + #768, #752
static Macas + #769, #1005
static Macas + #770, #368
static Macas + #771, #921
static Macas + #772, #957
static Macas + #773, #625
static Macas + #774, #715
static Macas + #775, #993
static Macas + #776, #277
static Macas + #777, #500
static Macas + #778, #700
static Macas + #779, #829
static Macas + #780, #308
static Macas + #781, #261
static Macas + #782, #910
static Macas + #783, #208
static Macas + #784, #623
static Macas + #785, #293	
static Macas + #786, #732
static Macas + #787, #876
static Macas + #788, #1114
static Macas + #789, #745
static Macas + #790, #404
static Macas + #791, #853
static Macas + #792, #497
static Macas + #793, #819
static Macas + #794, #1093
static Macas + #795, #221
static Macas + #796, #632
static Macas + #797, #278
static Macas + #798, #765
static Macas + #799, #484
static Macas + #800, #1050
static Macas + #801, #170
static Macas + #802, #535
static Macas + #803, #813
static Macas + #804, #749
static Macas + #805, #171
static Macas + #806, #861
static Macas + #807, #647
static Macas + #808, #656
static Macas + #809, #385
static Macas + #810, #494
static Macas + #811, #1057
static Macas + #812, #517
static Macas + #813, #718
static Macas + #814, #610
static Macas + #815, #243
static Macas + #816, #253
static Macas + #817, #1009
static Macas + #818, #162
static Macas + #819, #543
static Macas + #820, #690
static Macas + #821, #826
static Macas + #822, #445
static Macas + #823, #738
static Macas + #824, #184
static Macas + #825, #872
static Macas + #826, #505
static Macas + #827, #1013
static Macas + #828, #453
static Macas + #829, #659
static Macas + #830, #1025
static Macas + #831, #574
static Macas + #832, #499
static Macas + #833, #538
static Macas + #834, #213
static Macas + #835, #1018
static Macas + #836, #681
static Macas + #837, #298
static Macas + #838, #371
static Macas + #839, #592
static Macas + #840, #1045
static Macas + #841, #699
static Macas + #842, #373
static Macas + #843, #544
static Macas + #844, #812
static Macas + #845, #788
static Macas + #846, #285
static Macas + #847, #401
static Macas + #848, #553
static Macas + #849, #292
static Macas + #850, #482
static Macas + #851, #606
static Macas + #852, #209
static Macas + #853, #618
static Macas + #854, #793
static Macas + #855, #776
static Macas + #856, #307
static Macas + #857, #161
static Macas + #858, #635
static Macas + #859, #193
static Macas + #860, #334
static Macas + #861, #395
static Macas + #862, #662
static Macas + #863, #688
static Macas + #864, #446
static Macas + #865, #182
static Macas + #866, #971
static Macas + #867, #507
static Macas + #868, #203
static Macas + #869, #918
static Macas + #870, #1062
static Macas + #871, #488
static Macas + #872, #834
static Macas + #873, #603
static Macas + #874, #661
static Macas + #875, #222
static Macas + #876, #177
static Macas + #877, #383
static Macas + #878, #1028
static Macas + #879, #888
static Macas + #880, #336
static Macas + #881, #672
static Macas + #882, #256
static Macas + #883, #470
static Macas + #884, #434
static Macas + #885, #558
static Macas + #886, #501
static Macas + #887, #1055
static Macas + #888, #321
static Macas + #889, #449
static Macas + #890, #1112
static Macas + #891, #489
static Macas + #892, #722
static Macas + #893, #1046
static Macas + #894, #361
static Macas + #895, #1076
static Macas + #896, #814
static Macas + #897, #527
static Macas + #898, #339
static Macas + #899, #296
static Macas + #900, #838
static Macas + #901, #903
static Macas + #902, #742
static Macas + #903, #1053
static Macas + #904, #582
static Macas + #905, #671
static Macas + #906, #613
static Macas + #907, #233
static Macas + #908, #996
static Macas + #909, #183
static Macas + #910, #1115
static Macas + #911, #684
