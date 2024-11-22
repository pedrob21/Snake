; ------- TABELA DE CORES -------
; adicione ao caracter para Selecionar a cor correspondente


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

jmp main

main:
    call ImprimeTelaApresentacao


ImprimeTelaApresentacao:
    loadn r0, #TelaApresentacao00
    loadn r1, #1024

    call ImprimeTela
    rts
ImprimeTela:
    loadn r2, #0
    loadn r3, #40
    loadn r4, #41
    loadn r5, #1200

    ImprimeTelaLoop:
        cmp r2, r5
        jeq ImprimeTelaSai
        call ImprimeStr
        add r2, r3, r2
        add r0,r4,r0
        jmp ImprimeTelaLoop
    ImprimeTelaSai:
    rts
ImprimeStr:
    push r0 
    push r1
    push r2
    push r3
    push r4

    loadn r3, #'\0'

	ImprimeStrLoop:	
		loadi r4, r0		
		cmp r4, r3			
		jeq ImprimeStrSai
		add r4, r1, r4		
		outchar r4, r2		
		inc r2				
		inc r0			
		jmp ImprimeStrLoop
	
	ImprimeStrSai:	
	pop r4	; Resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r3
	pop r2
	pop r1
	pop r0
	rts


	
TelaApresentacao00: string "                                        "
TelaApresentacao01: string "                                        "
TelaApresentacao02: string "                                        "
TelaApresentacao03: string "                                        "
TelaApresentacao04: string "                                        "
TelaApresentacao05: string "                                        "
TelaApresentacao06: string "            JOGO CRIADO POR:            "
TelaApresentacao07: string "                                        "
TelaApresentacao08: string "        DAVID                           "
TelaApresentacao09: string "        LUCAS                           "
TelaApresentacao10: string "        PEDRO                           "
TelaApresentacao11: string "       MARCEL HENRIQUE R BATISTA        "
TelaApresentacao12: string "                                        "
TelaApresentacao13: string "                                        "
TelaApresentacao14: string "      ESTE JOGO E O CLASSICO SNAKE      "
TelaApresentacao15: string "                                        "
TelaApresentacao16: string "    OS COMANDO BASICOS DO JOGO SAO:     "
TelaApresentacao17: string "                                        "
TelaApresentacao18: string "        W  - MOVE PARA CIMA             "
TelaApresentacao19: string "        S  - MOVE PARA BAIXO            "
TelaApresentacao20: string "        A  - MOVE PARA ESQUERDA         "
TelaApresentacao21: string "        D  - MOVE PARA DIREITA          "
TelaApresentacao22: string "                                        "
TelaApresentacao23: string "                                        "
TelaApresentacao24: string "            ESPERO QUE GOSTE            "
TelaApresentacao25: string "                                        "
TelaApresentacao26: string "               BOM JOGO!                "
TelaApresentacao27: string "                                        "
TelaApresentacao28: string "  PRECIONE QUALQUER TECLA PARA COMECAR  "
TelaApresentacao29: string "                                        "

░░░░░░░▄▄▄█████▄▄▄░░░░░░░
░░░░░██░░░░░░░░░░░██░░░░░
░░░██░░░░░░░░░░░░░░░██░░░
░░█░░░░░░░░░░░░░░░░░░░█░░
░█░▄▀▀▀▄░░░░░░▄▀▀▀▄░░░░█░
░█▐░░▄██▌░░░░▐░░▄██▌░░░░█
█░▐▄▄███▌░░░░▐▄▄███▌░░░░█
█░░░░░░░░░░░░░░░░░░░░░░░█
█░░▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄░░░░█
█░░░█▒▒▒▒▒▒▒▒▒▒▒▒▒▒█░░░░█
░█░░█▒▒VAI CORINTHIANS!▒█
░░█░░█▒▒▒▒▒░░░░░░▒█░░░░█░
░░░█░░█▒▒▒░░░░░░░█░░░██░░
░░░░██░▀▀▀▀▀▀▀▀▀▀░░░█░░░░
░░░░░░▀▀▀▀██████▀▀▀▀░░░░░