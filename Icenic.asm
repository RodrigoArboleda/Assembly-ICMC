;Icenic - Nao bata no gelo igual ao Titanic
;Rodrigo Cesar Arboleda NºUSP 10416722
;E-Mail:rodrigo.arboleda@usp.br
;ICMC - USP
;V0.2

jmp main
;************************************************ATENCAO:********************************************************************
;TODOS OS COMENTARIOS NA FRENTE DOS "PUSH" SE REFEREM AO Q O REGISTRADOR FAZ NA FUNCAO, A INSTRUCAO PUSH EM SI
;SERVE PARA JOGAR PARA A PILHA O VALOR DO REGISTRADOR E ASSIM SALVAR SEU CONTEUDO
;****************************************************************************************************************************

;Registra o ice que estava antes da renderizacao de tela
;OBS:Isso é usado para otimizar o codigo e evitar q tenhamos q atualizar a tela inteira
iceVelho : var #8
static ice + #0, #325 ; linha 8
static ice + #1, #209 ; linha 5
static ice + #2, #655 ; linha 16
static ice + #3, #582 ; linha 14
static ice + #4, #1027; linha 25
static ice + #5, #430 ; linha 10
static ice + #6, #512 ; linha 12
static ice + #7, #839 ; linha 20

;Registra o ice é gerado depois da renderizacao
ice : var #8
static ice + #0, #325 ; linha 8
static ice + #1, #209 ; linha 5
static ice + #2, #655 ; linha 16
static ice + #3, #582 ; linha 14
static ice + #4, #1027; linha 25
static ice + #5, #390 ; linha 9
static ice + #6, #512 ; linha 12
static ice + #7, #839 ; linha 20

;Registra o navio que estava antes da renderizacao de tela
;OBS:Isso é usado para otimizar o codigo e evitar q tenhamos q atualizar a tela inteira
navioVelho : var #2 
static navio + #0, #1059
static navio + #1, #1099

;Registra o navio é gerado depois da renderizacao
navio : var #2
static navio + #0, #1059
static navio + #1, #1099

;Salva o numero gerado
aleatorio : var #1
static aleatorio + #0, #27


;Registra o quanto soma no contador do delay apos um processo de renderizacao do navio no meio do delay
;OBS: quando move o barco muitas instruçoes sao execultadas e com isso o delay tem q ser arrumado
velocidadeDelay : var #1
static velocidadeDelay + #0, #2000 ;mudar aqui para arrumar o delay quando o navio anda e muda a velocidade do jogo

;Registra o score do jogo
score : var #1
static score + #0, #0

;string de derrota
gameover: string "GAME OVER!"

;strings do menu
menu1: string "UTILIZE AS TECLAS: A D PARA JOGAR"
menu2: string "PRESSIONE QUALQUER TECLA PARA CONTINUAR"







;---- Inicio do Programa Principal -----

main:
	inchar r0
	nop
	inchar r0
	nop
	
	call DesenhaMenu 	 ; desenha o menu do jogo antes dele comecar
	call EsperaTecla  	 ; espera q o jogador digite alguma tecla para continuar. OBS:A teclad n é usada para nada
	call DesenhaFundo 	 ; desenha o fundo inteiro de acordo com o definido na funcao. OBS:Tal funcao foi desenvolvida para otimizar o codigo e impedir q o mesmo tenha q desenhar o fundo toda a vez
	fundoGerado:		 ; a partir deste ponto o codigo n desenha o fundo inteiro novamente
		
		call LimpaTela       ; limpa a tela, esta funcao apaga os antigos naivos e ices ****ATENCAO:Pode ocasionar flickering(tela piscando), cuido ao utilizar esta funcao
		
		loadn r1, #10
		mod r1, r0, r1
		cmp r1, r2			; if (mod(c/10)==0
		ceq LetecladoEAnda	; Chama Rotina de movimentacao da Nave
	
		loadn r1, #20
		mod r1, r0, r1
		cmp r1, r2		; if (mod(c/30)==0
		ceq ProximoQuadro	; Chama Rotina de movimentacao do Alien
	
		loadn r1, #2
		mod r1, r0, r1
		cmp r1, r2		; if (mod(c/2)==0
		ceq Desenha	; Chama Rotina de movimentacao do Tiro
		
		loadn r1, #8
		mod r1, r0, r1
		cmp r1, r2		; if (mod(c/2)==0
		ceq AtulizaVelocidade
		
		call VerificaBatida  ; verifica se o navio bateu, OBS SE BATER O CODIGO PARA
		
		call Delay
		inc r0 	;c++
		jmp fundoGerado

	jmp fundoGerado 	 ; cria o loop do jogo
	
;---- Fim do Programa Principal -----
	
;---- Inicio das Subrotinas -----


EsperaTecla:
	push r0 ; entrada do teclado
	push r1 ; comparacao para saber se algo foi digitado
	loadn r1, #255 ; OBS: quando nenhuma tecla é digitada se retorna 255

EsperaTeclaLoop:
	inchar r0  ; le o q esta no teclado
	cmp r0, r1 ; verifica se algo foi digitado
	jeq EsperaTeclaLoop ; caso nao, volta para o loop

EsperaTeclaSai:	
	pop r0  ; restaura registrador
	pop r1  ; restaura registrador
	rts		; retorna para onde foi chamada a funcao

DesenhaMenu:
	call DesenhaFundo ; O fundo ainda n foi gerado para o jogo, sendo assim criado para o menu 
					  ; *****ATENCAO: n utilazar esta funcao durante execucao do jogo em si, MUITO LENTA

	push r0 ; endereco da string 1
	push r1 ; local onde sera mostra a mensagem
	push r2 ; guarda a letra q sera enviada a tela
	push r3 ; criteiro de parada para a impresao da string (\0)
	loadn r0, #menu1 ; carrega o end da string
	loadi r2, r0 	 ; carrega em r2 a primeira letra
	loadn r1, #563 	 ; carrega o alinhamento OBS: mudar alinhamento aqui da string do menu
	loadn r3, #'\0'  ; carrega criteiro de parada da string (\0)

DesenhaMenuLoop1:
	outchar r2, r1 ; envia para a tela uma letra
	inc r0		   ; vai para o proximo endereco da string, logo proxima letra
	inc r1		   ; vai para o proximo local a ser impresso na tela (atuliza a posicao da tela)
	loadi r2, r0   ; carrega a proxima letra
	cmp r3, r2	   ; verifica se a string acabou
	jeq DesenhaMenuLoop2 ; se acabou sai
	jmp DesenhaMenuLoop1 ; se n continua

DesenhaMenuLoop2:
	loadn r0, #menu2 ; carrega o endereco da proxima string do menu
	loadi r2, r0	 ; carrega a primera letra da string2 do menu
	loadn r1, #641	 ; carrega o valor do alinhamento da string2

DesenhaMenuLoop3:
	outchar r2, r1 ; envia para a tela uma letra
	inc r0		   ; vai para o proximo endereco da string, logo proxima letra
	inc r1		   ; vai para o proximo local a ser impresso na tela (atuliza a posicao da tela)
	loadi r2, r0   ; carrega a proxima letra
	cmp r3, r2	   ; verifica se a string acabou
	jeq DesenhaMenuSai   ; se acabou sai
	jmp DesenhaMenuLoop3 ; se n continua

DesenhaMenuSai:
	pop r3 ; restaura o registrador
	pop r2 ; restaura o registrador
	pop r1 ; restaura o registrador
	pop r0 ; restaura o registrador
	rts


DesenhaFundo:
	push r0 ; desenho do fundo
	push r1 ; contador do loop
	push r2 ; tamanho do fundo OBS: A tela tem 1200 caracteres (40x30)

	loadn r0, #3198 ; carrega o valor da caracter a ser colocado no fundo
	loadn r1, #0    ; zera o contador do loop
	loadn r2, #1200 ; coloca o criterio de parada, q é a ultima posicao da tela

DesenhaFundoLoop:
	outchar r0, r1 ; envia para a tela uma letra
	nop
	nop
	
	inc r1		   ; vai para o proximo local a ser impresso na tela (atuliza a posicao da tela)
	cmp r1, r2     ; verifica se a tela acabou
	jeq DesenhaFundoSai  ; se acabou sai
	jmp DesenhaFundoLoop ; se n continua

DesenhaFundoSai:
	pop r2 ; restaura o registrador
	pop r1 ; restaura o registrador
	pop r0 ; restaura o registrador
	rts


Perdeu:
	push r0 ; endereco da string q sera impressa
	push r1 ; local na tela onde a string sera mostrada
	push r2 ; primeira letra da string
	push r3 ; criterio de parada da string (\0)
	push r4 ; score do jogo
	push r5 ; carrega o valor 10, que sera utilizado em contas para calcular os digitos do score
	push r6 ; sera utilizado para calcular os digitos do score
	push r7 ; carrega o valor q deve ser somado a um numero para ter seu correspondente em char

	loadn r0, #gameover ; carrega primeiro end da string
	loadn r1, #655      ; carrega a posicao na tela
	loadn r3, #'\0'     ; criteiro de parada da string
	loadi r2, r0	    ; carrega a primeira letra da string
	load r4, score      ; carrega o valor do score q esta na memoria
	loadn r5, #10 		; carrega o 10 q sera utilizado em diversas contas
	loadn r7, #48       ; carrega o valo q deve ser somado a um numero para ter seu correspondente em char

PerdeuLoop:
	outchar r2, r1 ; envia para a tela uma letra
	nop
	nop
	
	inc r0		   ; vai para o proximo endereco da string, logo proxima letra
	inc r1		   ; vai para o proximo local a ser impresso na tela (atuliza a posicao da tela)
	loadi r2, r0   ; carrega a proxima letra
	cmp r3, r2	   ; verifica se a tela acabou
	jeq PerdeuSocore ; se acabou sai
	jmp PerdeuLoop   ; se n continua

;a seguir sera mostrado o score na tela
PerdeuSocore:
	;OBS: A intrucao 'shiftr0', com o valor '3' pode se usada para substituir a 'div' e obter resultado SEMELHANTE, ATENCAO: utilize dessa obs somente se precisar de 
	;desempenho extremo, pois o numero mostrado n sera exato

	;Digito 1
	loadn r1, #699 ; carrega a posicao do primeiro digito na tela
	mod r6, r4, r5 ; pega o primeiro digito
	add r6, r6, r7 ; gera seu char
	outchar r6, r1 ; mostra na tela

	;Digito 2
	dec r1		   ; proxima posicao da tela para o proximo digito OBS: diminui 1 pq esta andando para tras, a funcao imprime do menos significativo pro mais sig.
	div r4, r4, r5 ; elimina o primeiro digito
	mod r6, r4, r5 ; pega o atual primeiro digito
	add r6, r6, r7 ; gera seu char
	outchar r6, r1 ; mostra na tela

	;digito 3
	dec r1		   ; proxima posicao da tela para o proximo digito 
	div r4, r4, r5 ; elimina o primeiro digito
	mod r6, r4, r5 ; pega o atual primeiro digito
	add r6, r6, r7 ; gera seu char
	outchar r6, r1 ; mostra na tela

	;digito 4
	dec r1 		   ; proxima posicao da tela para o proximo digito 
	div r4, r4, r5 ; elimina o primeiro digito
	mod r6, r4, r5 ; pega o atual primeiro digito
	add r6, r6, r7 ; gera seu char
	outchar r6, r1 ; mostra na tela

	;digito 5
	dec r1		   ; proxima posicao da tela para o proximo digito 
	div r4, r4, r5 ; elimina o primeiro digito
	mod r6, r4, r5 ; pega o atual primeiro digito
	add r6, r6, r7 ; gera seu char
	outchar r6, r1 ; mostra na tela


PerdeuSai:
	pop r6 ; restaura o registrador
	pop r5 ; restaura o registrador
	pop r4 ; restaura o registrador
	pop r3 ; restaura o registrador
	pop r2 ; restaura o registrador
	pop r1 ; restaura o registrador
	pop r0 ; restaura o registrador

	halt ; *****PARA O PROGRAMA


VerificaBatida:
	push r0 ; guarda a coordenada da parte de cima do navio
	push r1 ; guarda a coordenada da parte de baixo do navio
	push r2 ; guarda a coordenada do de um ice
	push r3 ; guarda enderecos na funcao, tento navio quanto ice
	push r4 ; contador
	push r5 ; guadar o numero de ices no jogo

	loadn r3, #navio ; carrega o endereco do naivo
	loadi r0, r3     ; carrega a coordenada de cima do navio
	inc r3           ; vai para a coordenada de baixo
	loadi r1, r3     ; carrega a coordenada de baixo do navio

	loadn r3, #ice   ; carrega o end do primeiro ice
	
	loadn r4, #0     ; zera o contador
	
	loadn r5, #8     ; carrega quantos ices tem no jogo

VerificaBatidaLoop:
	loadi r2, r3 ; carrega a coordenada do ice para se verificar
	cmp r0, r2   ; verifica batida
	jeq Perdeu   ; se bateu
	cmp r1, r2   ; verifica batida, parte de baixo do navio
	jeq Perdeu   ; se bateu

	inc r3       ; muda o end para o proximo ice
	inc r4       ; conta um, para saber quantos ja foram processador
	cmp r4, r5   ; verifica se acabou
	jeq VerificaBatidaSai ; se acabou sai
	jmp VerificaBatidaLoop ; se n, continua

VerificaBatidaSai:
	pop r5 ; restaura o registrador
	pop r4 ; restaura o registrador
	pop r3 ; restaura o registrador
	pop r2 ; restaura o registrador
	pop r1 ; restaura o registrador
	pop r0 ; restaura o registrador
	rts

LetecladoEAnda:
	push r0 ; guarda tecla lida
	push r1 ; contador para o delay
	push r2 ; armazena a letra 'a' para comparar
	push r3 ; armazena a letra 'd' para comparar
	
	loadn r2, #97 ; carrega a letra 'a'
	loadn r3, #100 ; carrega a letra 'd'

LetecladoEAndaExc:
	inchar r0					; le o q esta no teclado
	cmp r0, r2					; verifica se o navio deve andar para a esquerda
	ceq NavioEsquerda 			; caso sim, chama uma funcao para andar ele para  a esquerda OBS: esta funcao ja ajusta o contador por conta do custo da operacao
	cmp r0, r3                  ; verifica se o navio deve andar para a direita
	ceq NavioDireita 			; se sim, chama a funcao para andar ele para a direita OBS: esta funcao ja ajusta o contador por conta do custo da operacao

LetecladoEAndaSai:
	pop r3 ; restaura o registrador
	pop r2 ; restaura o registrador
	pop r1 ; restaura o registrador
	pop r0 ; restaura o registrador
	rts


VoltaNavioE:
	; **************ATENCAO: ESTA SUBROTINA (VoltaNavioE) N PRESERVA OS REGISTRADORES, N USAR ELA SEPARADAMENTE
	inc r1 ; anda a parte de cima do navio de volta a posicao original
	inc r2 ; anda a parte de baixo do navio de volta a posicao original
	rts

NavioEsquerda:
	push r0 ; armazena o end do navio na memoria
	push r1 ; armazena a coordenada da parte de cima do navio
	push r2 ; armazena a coordenada da parte de baixo do navio
	push r4 ; armazena o maximo q o navio pode ir para cima
	push r5 ; valor do numero aleatorio
	push r6 ; guarda o endereco do navio velho

	loadn r0, #navio ; carrega o endereco do navio
	loadn r4, #1039  ; maximo q pode ir para a esquerda
	loadn r6, #navioVelho ; carrega o endereco do navio velho

NavioEsquerdaLoop:
	loadi r1, r0 ; carrega a parte de cima do navio
	inc r0	     ; vai para o proximo end do navio
	loadi r2, r0 ; carrega a parte de baixo do navio
	dec r0       ; volta para o primeiro end do navio

	storei r6, r1 ; registra a parte de cima do navio, no navio velho
	inc r6        ; vai para o proximo end do navio velho
	storei r6, r2 ; registra a parte de baixo do navio, no navio velho

	dec r1		  ; anda a parte de cima para a esquerda
	dec r2		  ; anda a parte de baixo para a esquerda

	cmp r1, r4      ; verifica se passou da tela
	cel VoltaNavioE ; se sim, volta a posicao original

	load r5, aleatorio  ; carrega o valor do numero aleatorio
	add r5, r5, r1      ; gera o proximo aleatorio com base na posisao do barco OBS: É utilizado soma, pois ao se estourar o limite do numero o simulador n volta pro 0 (procesador volta por 0) 
	store aleatorio, r5 ; grava o novo numero na memoria


	storei r0, r1  ; registra a nova posicao do navio, parte de cima
	inc r0 		   ; vai para o proximo end do navio
	storei r0, r2  ; registra a nova posicao do naivo, parte de baixo

NavioEsquerdaSai:
	pop r6 ; restaura o registrador
	pop r5 ; restaura o registrador
	pop r4 ; restaura o registrador
	pop r2 ; restaura o registrador
	pop r1 ; restaura o registrador
	pop r0 ; restaura o registrador
	call LimpaTelaEDesenhaSoBarco ; apaga o navio antigo e gera um novo
	add r1, r1, r4 ; soma o custa da rotina no delay
	rts


VoltaNavioD:
	; **************ATENCAO: ESTA SUBROTINA (VoltaNavioD) N PRESERVA OS REGISTRADORES, N USAR ELA SEPARADAMENTE
	dec r1 ; anda a parte de cima do navio de volta a posicao original
	dec r2 ; anda a parte de baixo do navio de volta a posicao original
	rts

NavioDireita:
	push r0 ; armazena o end do navio na memoria
	push r1 ; armazena a coordenada da parte de cima do navio
	push r2 ; armazena a coordenada da parte de baixo do navio
	push r4 ; armazena o maximo q o navio pode ir para cima
	push r5 ; valor do numero aleatorio
	push r6 ; guarda o endereco do navio velho

	loadn r0, #navio ; carrega o endereco do navio
	loadn r4, #1080  ; maximo q pode ir para a direita
	loadn r6, #navioVelho ; carrega o endereco do navio velho

NavioDireitaLoop:
	loadi r1, r0 ; carrega a parte de cima do navio
	inc r0       ; vai para o proximo end do navio
	loadi r2, r0 ; carrega a parte de baixo do navio
	dec r0       ; volta para o primeiro end do navio

	storei r6, r1 ; registra a parte de cima do navio, no navio velho
	inc r6        ; vai para o proximo end do navio velho
	storei r6, r2 ; registra a parte de baixo do navio, no navio velho

	inc r1        ; anda a parte de cima para a esquerda
	inc r2        ; anda a parte de baixo para a esquerda

	cmp r1, r4      ; verifica se passou da tela
	ceg VoltaNavioD ; se sim, volta a posicao original

	load r5, aleatorio  ; carrega o valor do numero aleatorio
	add r5, r5, r1      ; gera o proximo aleatorio com base na posisao do barco OBS: É utilizado soma, pois ao se estourar o limite do numero o simulador n volta pro 0 (procesador volta por 0) 
	store aleatorio, r5 ; grava o novo numero na memoria

	storei r0, r1  ; registra a nova posicao do navio, parte de cima
	inc r0 		   ; vai para o proximo end do navio
	storei r0, r2  ; registra a nova posicao do naivo, parte de baixo

NavioDireitaSai:
	pop r6 ; restaura o registrador
	pop r5 ; restaura o registrador
	pop r4 ; restaura o registrador
	pop r2 ; restaura o registrador
	pop r1 ; restaura o registrador
	pop r0 ; restaura o registrador
	call LimpaTelaEDesenhaSoBarco ; apaga o navio antigo e gera um novo
	add r1, r1, r4 ; soma o custa da rotina no delay
	rts

LimpaTelaEDesenhaSoBarco:
	push r0 ; armazena end do navio velho e depois novo
	push r1 ; armazena navio cima
	push r2 ; armazena navio baixo
	push r3 ; armazena caracter navio cima
	push r4 ; armazena caracter navio baixo
	push r5 ; armazena caracter do fundo da tela

	loadn r0, #navioVelho ; carrega o end navio velho a ser apagado
	loadn r3, #2084 ; carrega caracte da parte de cima do navio
	loadn r4, #2085 ; carrega caracter da parte de baixo do navio
	loadn r5, #3198 ; carrega caracter q sera colocado no fundo

	;------------------parte de apagar tela----------------------
	loadi r1, r0          ; carrega parte de cima do navio a ser apagado
	inc r0                ; vai para o proximo end
	loadi r2, r0          ; carrega parte de baixo a ser apagada

	outchar r5, r1        ; apaga parte de cima do navio
	outchar r5, r2        ; apaga parte de baixo do navio

	;-----------------parte de desenho------------------------
	loadn r0, #navio ; carrega o end da memoria do navio

	loadi r1, r0     ; carrega coordenada da parte de cima do navio
	inc r0           ; muda para o proximo end do navio
	loadi r2, r0     ; carrega coordenada da parte de baixo do navio

	outchar r3, r1 ; desenha na tela a parte de cima do navio
	outchar r4, r2 ; desenha na tela a parte de baixo do navio

	pop r5 ; restaura o registrador
	pop r4 ; restaura o registrador
	pop r3 ; restaura o registrador
	pop r2 ; restaura o registrador
	pop r1 ; restaura o registrador
	pop r0 ; restaura o registrador
	rts



MudaIce:
	; r2 esta com a coordenada do ice
	push r3 ; endereco do score
	push r4 ; valor score
	; r5 esta com o numero aleatorio
	push r6 ; quando o maximo da primeira linha

	load r4, score ; carrega o score atual
	loadn r6, #40  ; o maximo q pode ter na primeira linha

	add r2, r2, r5 ; soma com o numero aleatorio
	mod r2, r2, r6 ; coloca o ice na primeira linha
	add r5, r5, r2 ; gera um outro numero aleatorio

	inc r4 ; soma um no score
	store score, r4 ; grava score na memoria

	pop r6 ; restaura o registrador
	pop r4 ; restaura o registrador
	pop r3 ; restaura o registrador
	rts


ProximoQuadro:
	push r0 ; end do ice na memoria
	push r1 ; contador de ices processados
	push r2 ; guarda a coordenada do ice
	push r3 ; guarda o quanto precisa somar para mudar de linha
	push r4 ; criterio de reset do ice, valor maximo da tela
	push r5 ; Guada o numero aleatorio
	push r6 ; end do iceVelho
	push r7

	loadn r0, #ice  ; carrega  o end do ice
	loadn r1, #0    ; zera o contador
	loadn r4, #1200 ; criterio de parada (a tela tem 1200 espacos)
	load r5, aleatorio ; carrega o valor do numero aleatorio
	loadn r6, #iceVelho ; carrega o end da memoria do ice velho
	loadn r7, #8    ; numero de ices a serem processados

ProximoQuadroLoop:
	loadi r2, r0   ; carrega r2 com coordenada do ice
	storei r6, r2  ; salva o ice antigo
	loadn r3, #40  ; quanto soma para mudar de linha
	add r2, r2, r3 ; faz a soma, muda de linha o ice
	cmp r2, r4     ; verifica se saiu da dela
	ceg MudaIce    ; se saiu ele é mandado para outra linha
	storei r0, r2  ; salva a nova coordena do ice na memoria
	inc r0         ; muda para o end do proximo ice
	inc r1         ; conta 1 ice processado
	inc r6         ; muda para o proximo end do ice velho
	
	cmp r1, r7     ; verifica se todos os ices forom processadors
	jeq ProximoQuadroSai ; se sim, sai

	jmp ProximoQuadroLoop ; se n, continua


ProximoQuadroSai:
	pop r7 ; restaura o registrador
	pop r6 ; restaura o registrador
	pop r5 ; restaura o registrador
	pop r4 ; restaura o registrador
	pop r3 ; restaura o registrador
	pop r2 ; restaura o registrador
	pop r1 ; restaura o registrador
	pop r0 ; restaura o registrador
	rts



LimpaTela:
	push r0 ; guarda o caracter do fundo
	push r1 ; contador
	push r2 ; criterio de parada, numero de ices a serem processados
	push r3 ; endereco do navio velho e depois do ice velho
	push r4 ; coordenada do objeto a ser apagado

	loadn r0, #3198 ; carrega o valor do caracter de fundo
	loadn r1, #0    ; zera o contador
	loadn r2, #8    ; carrega o numero de ices para se processar
	loadn r3, #navioVelho ; carrega o endereco do navio velho

LimpaTelaLoop:
	loadi r4, r3 ; carrega a coordenadada do navio
	outchar r0, r4 ; apaga o navio cima
	inc r3         ; vai apara o proximo end da memoria
	loadi r4, r3   ; carrega a coordenada para ser apagada
	outchar r0, r4 ; apaga o navio baixo
	loadn r3, #iceVelho ; carrega o end do icevelho para ser apagado

LimpaTelaLoop2:
	loadi r4, r3   ; carrega a coordenada do proximo ice
	outchar r0, r4 ; apaga o ice
	inc r1         ; conta 1 ice apagado
	inc r3         ; vai para o proximo end do ice a ser apagado
	cmp r1, r2     ; compara se todos os ices foram apagados
	jeq LimpaTelaSai ; se sim sai
	jmp LimpaTelaLoop2 ; se n continua

LimpaTelaSai:
	pop r4 ; restaura o registrador
	pop r3 ; restaura o registrador
	pop r2 ; restaura o registrador
	pop r1 ; restaura o registrador
	pop r0 ; restaura o registrador
	rts

Desenha:
	push r0 ; guarda o end do navio
	push r1 ; guarda o end do ice
	push r3 ; guarda o carcter do navio
	push r4 ; guarda o carcter 2 do navio
	push r5 ; guarda o desenho do ice
	push r6 ; guarda onde vai imprimir

	loadn r0, #navio ; carrega o end do navio
	loadn r1, #ice   ; carrega o end do navio
	loadn r3, #2084  ; caracter 1 do navio
	loadn r4, #2085  ; caracter 2 do navio
	loadn r5, #'#'   ; caracter do ice

DesenhaLoop:
	;navio
	loadi r6, r0 ; carrega a parte de cima do navio
	outchar r3, r6 ; desenha na tela
	nop
	nop
	inc r0 ;vai para o proximo end
	loadi r6, r0 ; carreda a parte de baixo
	outchar r4, r6 ; desenha na tela
	nop
	nop

	;ice 1
	loadi r6, r1   ; carrega a coordenada do ice a ser desenhado
	outchar r5, r6 ; desenha
	inc r1         ; vai para o end do proximo ice
	nop
	nop
	
	;ice 2
	loadi r6, r1   ; carrega a coordenada do ice a ser desenhado
	outchar r5, r6 ; desenha
	inc r1         ; vai para o end do proximo ice
	nop
	nop
	
	;ice 3
	loadi r6, r1   ; carrega a coordenada do ice a ser desenhado
	outchar r5, r6 ; desenha
	inc r1         ; vai para o end do proximo ice
	nop
	nop
	
	;ice 4
	loadi r6, r1   ; carrega a coordenada do ice a ser desenhado
	outchar r5, r6 ; desenha
	inc r1         ; vai para o end do proximo ice
	nop
	nop
	
	;ice 5
	loadi r6, r1   ; carrega a coordenada do ice a ser desenhado
	outchar r5, r6 ; desenha
	inc r1         ; vai para o end do proximo ice
	nop
	nop
	
	;ice 6
	loadi r6, r1   ; carrega a coordenada do ice a ser desenhado
	outchar r5, r6 ; desenha
	inc r1         ; vai para o end do proximo ice
	nop
	nop
	
	;ice 7
	loadi r6, r1   ; carrega a coordenada do ice a ser desenhado
	outchar r5, r6 ; desenha
	inc r1         ; vai para o end do proximo ice
	nop
	nop
	
	;ice 8
	loadi r6, r1   ; carrega a coordenada do ice a ser desenhado
	outchar r5, r6 ; desenha
	nop
	nop
	
DesenhaSai:
	pop r6 ; restaura o registrador
	pop r5 ; restaura o registrador
	pop r4 ; restaura o registrador
	pop r3 ; restaura o registrador
	pop r1 ; restaura o registrador
	pop r0 ; restaura o registrador
	rts
	
Delay:
						;Utiliza Push e Pop para nao afetar os Ristradores do programa principal
	push r0
	push r1
	
	loadn r1, #2  ; a
   
   Delay_volta2:				;Quebrou o contador acima em duas partes (dois loops de decremento)
	load r0, velocidadeDelay	; b
   
   Delay_volta: 
	dec r0					; (4*a + 6)b = 1000000  == 1 seg  em um clock de 1MHz
	jnz Delay_volta	
	dec r1
	jnz Delay_volta2
	
	pop r1
	pop r0
	
	rts

AtulizaVelocidade:
	push r0
	push r1
	push r2
	
	load r0, velocidadeDelay
	loadn r1, #5
	loadn r2, #300
	
	sub r0, r0, r1
	
	cmp r0, r2
	
	jel AtulizaVelocidadeMax
	
	store velocidadeDelay, r0
	
AtulizaVelocidadeMax:	
	
	pop r2
	pop r1
	pop r0
	
	rts