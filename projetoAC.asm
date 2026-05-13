; ============================================================
;  GESTAO DE VEICULOS - MASM / EMU8086 (16-bit, DOS)
;  Menu: Utilizador / Admin (com password)
;  Veiculos: Carros e Motas
;  Campos: Marca, Modelo, KMs, Ano, Cor, Preco
; ============================================================

.MODEL SMALL
.STACK 200h

; ============================================================
; CONSTANTES
; ============================================================
CAMPO_TAM   EQU 20      ; tamanho maximo de cada campo de texto
PRECO_TAM   EQU 8       ; tamanho maximo do preco
VEICULO_TAM EQU 108     ; 5*CAMPO_TAM + PRECO_TAM = 108
MAX_VEI     EQU 5       ; maximo de veiculos por tipo

; ============================================================
.DATA
; ============================================================

; --- Mensagens gerais ---
msg_sep     DB "====================================", 13, 10, "$"
msg_titulo  DB "   GESTAO DE VEICULOS", 13, 10, "$"
msg_nl      DB 13, 10, "$"

; --- Menu principal ---
msg_menu_prin DB 13,10
              DB "  [1] Utilizador", 13,10
              DB "  [2] Administrador", 13,10
              DB "  [0] Sair", 13,10
              DB "  Opcao: $"

; --- Login admin ---
msg_pass    DB 13,10,"  Password admin: $"
msg_erro_p  DB 13,10,"  [ERRO] Password incorrecta!", 13,10,"$"
msg_acesso  DB 13,10,"  [OK] Acesso concedido!", 13,10,"$"

; A password do admin (definida aqui)
password    DB "admin123", 0
PASS_LEN    EQU 8

; --- Menus ---
msg_menu_user DB 13,10
              DB "  --- MENU UTILIZADOR ---",13,10
              DB "  [1] Ver Carros",13,10
              DB "  [2] Ver Motas",13,10
              DB "  [0] Voltar",13,10
              DB "  Opcao: $"

msg_menu_adm  DB 13,10
              DB "  --- MENU ADMINISTRADOR ---",13,10
              DB "  [1] Ver Carros",13,10
              DB "  [2] Ver Motas",13,10
              DB "  [3] Adicionar Carro",13,10
              DB "  [4] Adicionar Mota",13,10
              DB "  [5] Editar Carro",13,10
              DB "  [6] Editar Mota",13,10
              DB "  [0] Voltar",13,10
              DB "  Opcao: $"

; --- Labels de exibicao ---
lbl_marca   DB 13,10,"  Marca  : $"
lbl_modelo  DB "  Modelo : $"
lbl_kms     DB "  KMs    : $"
lbl_ano     DB "  Ano    : $"
lbl_cor     DB "  Cor    : $"
lbl_preco   DB "  Preco  : $"
lbl_eur     DB " EUR",13,10,"$"
lbl_vnum    DB 13,10,"  --- Veiculo #$"
lbl_dash    DB " ---",13,10,"$"

; --- Prompts de input ---
prm_marca   DB 13,10,"  Insira Marca  : $"
prm_modelo  DB "  Insira Modelo : $"
prm_kms     DB "  Insira KMs    : $"
prm_ano     DB "  Insira Ano    : $"
prm_cor     DB "  Insira Cor    : $"
prm_preco   DB "  Insira Preco  : $"
prm_idx     DB 13,10,"  Numero (1-5)  : $"

; --- Submenu de edicao de campo ---
msg_menu_edit DB 13,10
              DB "  O que deseja editar?",13,10
              DB "  [1] Marca",13,10
              DB "  [2] Modelo",13,10
              DB "  [3] KMs",13,10
              DB "  [4] Ano",13,10
              DB "  [5] Cor",13,10
              DB "  [6] Preco",13,10
              DB "  [0] Terminar edicao",13,10
              DB "  Opcao: $"

msg_edit_atual DB 13,10,"  Valor actual: $"

; --- Cabecalhos ---
hdr_carros  DB 13,10,"  === LISTA DE CARROS ===",13,10,"$"
hdr_motas   DB 13,10,"  === LISTA DE MOTAS  ===",13,10,"$"

; --- Mensagens de estado ---
msg_vazio   DB "  (Nenhum veiculo registado)",13,10,"$"
msg_ok_add  DB 13,10,"  [OK] Veiculo adicionado!",13,10,"$"
msg_ok_ed   DB 13,10,"  [OK] Veiculo editado!",13,10,"$"
msg_cheio   DB 13,10,"  [ERRO] Lista cheia!",13,10,"$"
msg_inv_op  DB 13,10,"  Opcao invalida.",13,10,"$"
msg_inv_idx DB 13,10,"  Numero invalido.",13,10,"$"
msg_adeus   DB 13,10,"  Ate logo!",13,10,"$"

; ============================================================
; ARRAYS DE VEICULOS
; Cada veiculo: marca(20) modelo(20) kms(20) ano(20) cor(20) preco(8)
; ============================================================

; --- Carros pre-carregados ---
; Carro 1
c1_marca  DB "Toyota", 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
c1_modelo DB "Corolla", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
c1_kms    DB "45000", 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
c1_ano    DB "2020", 0,   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
c1_cor    DB "Branco", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
c1_preco  DB "18500", 0,  0, 0

; Carro 2
c2_marca  DB "BMW", 0,      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
c2_modelo DB "Serie 3", 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
c2_kms    DB "80000", 0,    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
c2_ano    DB "2018", 0,     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
c2_cor    DB "Preto", 0,    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
c2_preco  DB "24000", 0,    0, 0

; Motas pre-carregadas
; Mota 1
m1_marca  DB "Honda", 0,     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
m1_modelo DB "CB500F", 0,    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
m1_kms    DB "12000", 0,     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
m1_ano    DB "2021", 0,      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
m1_cor    DB "Vermelho", 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
m1_preco  DB "6800", 0,      0, 0, 0, 0

; Mota 2
m2_marca  DB "Yamaha", 0,    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
m2_modelo DB "MT-07", 0,     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
m2_kms    DB "30000", 0,     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
m2_ano    DB "2019", 0,      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
m2_cor    DB "Azul", 0,      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
m2_preco  DB "8200", 0,      0, 0, 0, 0

; --- Arrays dinamicos (MAX_VEI * VEICULO_TAM cada) ---
; Organizados como blocos de 108 bytes por veiculo
arr_carros  DB MAX_VEI * VEICULO_TAM DUP(0)
arr_motas   DB MAX_VEI * VEICULO_TAM DUP(0)

; Contadores
num_carros  DB 0
num_motas   DB 0

; Buffer de input generico
inp_buf     DB 25 DUP(0)
pass_buf    DB 12 DUP(0)

; Variavel temporaria para indice
idx_tmp     DB 0
vei_base    DW 0

; ============================================================
.CODE
; ============================================================

MAIN PROC
    ; Inicializar segmentos
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX

    ; Inicializar arrays com dados de exemplo
    CALL INIT_DADOS

    ; Mostrar titulo
    LEA DX, msg_sep
    MOV AH, 09h
    INT 21h
    LEA DX, msg_titulo
    MOV AH, 09h
    INT 21h
    LEA DX, msg_sep
    MOV AH, 09h
    INT 21h

LOOP_PRINCIPAL:
    LEA DX, msg_menu_prin
    MOV AH, 09h
    INT 21h

    ; Ler opcao
    MOV AH, 01h
    INT 21h
    MOV BL, AL     ; guardar opcao em BL

    ; Consumir Enter
    MOV AH, 01h
    INT 21h

    CMP BL, '0'
    JE SAIR
    CMP BL, '1'
    JE IR_USER
    CMP BL, '2'
    JE IR_ADMIN
    LEA DX, msg_inv_op
    MOV AH, 09h
    INT 21h
    JMP LOOP_PRINCIPAL

IR_USER:
    CALL MENU_UTILIZADOR
    JMP LOOP_PRINCIPAL

IR_ADMIN:
    CALL LOGIN_ADMIN
    CMP AL, 1
    JNE LOOP_PRINCIPAL
    CALL MENU_ADMIN
    JMP LOOP_PRINCIPAL

SAIR:
    LEA DX, msg_adeus
    MOV AH, 09h
    INT 21h
    MOV AX, 4C00h
    INT 21h

MAIN ENDP

; ============================================================
; INIT_DADOS - copia veiculos de exemplo para os arrays
; ============================================================
INIT_DADOS PROC
    PUSH AX
    PUSH CX
    PUSH SI
    PUSH DI

    ; --- Carro 1 ---
    MOV DI, OFFSET arr_carros   ; posicao 0
    MOV SI, OFFSET c1_marca
    MOV CX, CAMPO_TAM
    REP MOVSB
    MOV SI, OFFSET c1_modelo
    MOV CX, CAMPO_TAM
    REP MOVSB
    MOV SI, OFFSET c1_kms
    MOV CX, CAMPO_TAM
    REP MOVSB
    MOV SI, OFFSET c1_ano
    MOV CX, CAMPO_TAM
    REP MOVSB
    MOV SI, OFFSET c1_cor
    MOV CX, CAMPO_TAM
    REP MOVSB
    MOV SI, OFFSET c1_preco
    MOV CX, PRECO_TAM
    REP MOVSB

    ; --- Carro 2 ---
    ; DI ja esta em arr_carros + VEICULO_TAM
    MOV SI, OFFSET c2_marca
    MOV CX, CAMPO_TAM
    REP MOVSB
    MOV SI, OFFSET c2_modelo
    MOV CX, CAMPO_TAM
    REP MOVSB
    MOV SI, OFFSET c2_kms
    MOV CX, CAMPO_TAM
    REP MOVSB
    MOV SI, OFFSET c2_ano
    MOV CX, CAMPO_TAM
    REP MOVSB
    MOV SI, OFFSET c2_cor
    MOV CX, CAMPO_TAM
    REP MOVSB
    MOV SI, OFFSET c2_preco
    MOV CX, PRECO_TAM
    REP MOVSB

    MOV BYTE PTR num_carros, 2

    ; --- Mota 1 ---
    MOV DI, OFFSET arr_motas
    MOV SI, OFFSET m1_marca
    MOV CX, CAMPO_TAM
    REP MOVSB
    MOV SI, OFFSET m1_modelo
    MOV CX, CAMPO_TAM
    REP MOVSB
    MOV SI, OFFSET m1_kms
    MOV CX, CAMPO_TAM
    REP MOVSB
    MOV SI, OFFSET m1_ano
    MOV CX, CAMPO_TAM
    REP MOVSB
    MOV SI, OFFSET m1_cor
    MOV CX, CAMPO_TAM
    REP MOVSB
    MOV SI, OFFSET m1_preco
    MOV CX, PRECO_TAM
    REP MOVSB

    ; --- Mota 2 ---
    MOV SI, OFFSET m2_marca
    MOV CX, CAMPO_TAM
    REP MOVSB
    MOV SI, OFFSET m2_modelo
    MOV CX, CAMPO_TAM
    REP MOVSB
    MOV SI, OFFSET m2_kms
    MOV CX, CAMPO_TAM
    REP MOVSB
    MOV SI, OFFSET m2_ano
    MOV CX, CAMPO_TAM
    REP MOVSB
    MOV SI, OFFSET m2_cor
    MOV CX, CAMPO_TAM
    REP MOVSB
    MOV SI, OFFSET m2_preco
    MOV CX, PRECO_TAM
    REP MOVSB

    MOV BYTE PTR num_motas, 2

    POP DI
    POP SI
    POP CX
    POP AX
    RET
INIT_DADOS ENDP

; ============================================================
; LOGIN_ADMIN
;   Pede password, compara com "admin123"
;   Retorna AL=1 se correcta, AL=0 se errada
; ============================================================
LOGIN_ADMIN PROC
    PUSH BX
    PUSH CX
    PUSH SI
    PUSH DI

    LEA DX, msg_pass
    MOV AH, 09h
    INT 21h

    ; Ler password caracter a caracter (sem echo para simular seguranca)
    LEA DI, pass_buf
    MOV CX, 0          ; contador de chars

LER_PASS:
    MOV AH, 08h        ; read char sem echo
    INT 21h

    CMP AL, 13         ; Enter pressionado?
    JE FIM_LER

    CMP AL, 8          ; Backspace?
    JE BACKSPACE_P

    CMP CX, PASS_LEN   ; limite atingido?
    JGE LER_PASS

    MOV [DI], AL
    INC DI
    INC CX

    ; Mostrar '*' em vez do caracter real
    MOV AH, 02h
    MOV DL, '*'
    INT 21h

    JMP LER_PASS

BACKSPACE_P:
    CMP CX, 0
    JE LER_PASS
    DEC DI
    DEC CX
    MOV BYTE PTR [DI], 0
    ; Apagar o '*' do ecra
    MOV AH, 02h
    MOV DL, 8
    INT 21h
    MOV DL, ' '
    INT 21h
    MOV DL, 8
    INT 21h
    JMP LER_PASS

FIM_LER:
    MOV BYTE PTR [DI], 0   ; terminar string

    ; Verificar comprimento: tem de ser igual a PASS_LEN
    CMP CX, PASS_LEN
    JNE PASS_ERRADA

    ; Comparar pass_buf com password
    LEA SI, pass_buf
    LEA DI, password
    MOV CX, PASS_LEN

COMP_PASS:
    MOV AL, [SI]
    CMP AL, [DI]
    JNE PASS_ERRADA
    INC SI
    INC DI
    LOOP COMP_PASS

    ; Password correcta
    LEA DX, msg_acesso
    MOV AH, 09h
    INT 21h
    MOV AL, 1
    JMP FIM_LOGIN

PASS_ERRADA:
    LEA DX, msg_erro_p
    MOV AH, 09h
    INT 21h
    MOV AL, 0

FIM_LOGIN:
    POP DI
    POP SI
    POP CX
    POP BX
    RET
LOGIN_ADMIN ENDP

; ============================================================
; MENU_UTILIZADOR
; ============================================================
MENU_UTILIZADOR PROC
    PUSH AX
    PUSH BX
    PUSH DX

LOOP_USER:
    LEA DX, msg_menu_user
    MOV AH, 09h
    INT 21h

    MOV AH, 01h
    INT 21h
    MOV BL, AL
    MOV AH, 01h
    INT 21h    ; consumir Enter

    CMP BL, '0'
    JE FIM_USER
    CMP BL, '1'
    JE VER_CARROS_U
    CMP BL, '2'
    JE VER_MOTAS_U
    LEA DX, msg_inv_op
    MOV AH, 09h
    INT 21h
    JMP LOOP_USER

VER_CARROS_U:
    MOV AL, 0    ; flag: 0=carros
    CALL LISTAR_VEICULOS
    JMP LOOP_USER

VER_MOTAS_U:
    MOV AL, 1    ; flag: 1=motas
    CALL LISTAR_VEICULOS
    JMP LOOP_USER

FIM_USER:
    POP DX
    POP BX
    POP AX
    RET
MENU_UTILIZADOR ENDP

; ============================================================
; MENU_ADMIN
; ============================================================
MENU_ADMIN PROC
    PUSH AX
    PUSH BX
    PUSH DX

LOOP_ADM:
    LEA DX, msg_menu_adm
    MOV AH, 09h
    INT 21h

    MOV AH, 01h
    INT 21h
    MOV BL, AL
    MOV AH, 01h
    INT 21h    ; consumir Enter

    CMP BL, '0'
    JE FIM_ADM
    CMP BL, '1'
    JE VER_C_A
    CMP BL, '2'
    JE VER_M_A
    CMP BL, '3'
    JE ADD_C_A
    CMP BL, '4'
    JE ADD_M_A
    CMP BL, '5'
    JE EDIT_C_A
    CMP BL, '6'
    JE EDIT_M_A
    LEA DX, msg_inv_op
    MOV AH, 09h
    INT 21h
    JMP LOOP_ADM

VER_C_A:
    MOV AL, 0
    CALL LISTAR_VEICULOS
    JMP LOOP_ADM

VER_M_A:
    MOV AL, 1
    CALL LISTAR_VEICULOS
    JMP LOOP_ADM

ADD_C_A:
    MOV BL, num_carros
    CMP BL, MAX_VEI
    JGE CHEIO_ADM
    MOV AL, 0      ; carros
    CALL ADICIONAR_VEICULO
    JMP LOOP_ADM

ADD_M_A:
    MOV BL, num_motas
    CMP BL, MAX_VEI
    JGE CHEIO_ADM
    MOV AL, 1      ; motas
    CALL ADICIONAR_VEICULO
    JMP LOOP_ADM

EDIT_C_A:
    MOV BL, num_carros
    CMP BL, 0
    JE VAZIO_ADM
    MOV AL, 0
    CALL LISTAR_VEICULOS
    CALL PEDIR_IDX
    CMP AL, 0FFh
    JE IDX_INV_ADM
    MOV idx_tmp, AL
    MOV AL, 0
    CALL EDITAR_VEICULO
    JMP LOOP_ADM

EDIT_M_A:
    MOV BL, num_motas
    CMP BL, 0
    JE VAZIO_ADM
    MOV AL, 1
    CALL LISTAR_VEICULOS
    CALL PEDIR_IDX
    CMP AL, 0FFh
    JE IDX_INV_ADM
    MOV idx_tmp, AL
    MOV AL, 1
    CALL EDITAR_VEICULO
    JMP LOOP_ADM

CHEIO_ADM:
    LEA DX, msg_cheio
    MOV AH, 09h
    INT 21h
    JMP LOOP_ADM

VAZIO_ADM:
    LEA DX, msg_vazio
    MOV AH, 09h
    INT 21h
    JMP LOOP_ADM

IDX_INV_ADM:
    LEA DX, msg_inv_idx
    MOV AH, 09h
    INT 21h
    JMP LOOP_ADM

FIM_ADM:
    POP DX
    POP BX
    POP AX
    RET
MENU_ADMIN ENDP

; ============================================================
; LISTAR_VEICULOS
;   AL = 0 -> carros   AL = 1 -> motas
; ============================================================
LISTAR_VEICULOS PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    CMP AL, 0
    JE LISTAR_CARROS_L

    ; Motas
    LEA DX, hdr_motas
    MOV AH, 09h
    INT 21h
    MOV BL, num_motas
    MOV SI, OFFSET arr_motas
    JMP LISTAR_LOOP

LISTAR_CARROS_L:
    LEA DX, hdr_carros
    MOV AH, 09h
    INT 21h
    MOV BL, num_carros
    MOV SI, OFFSET arr_carros

LISTAR_LOOP:
    CMP BL, 0
    JE LISTAR_VAZIO

    MOV CL, 0      ; indice actual (0-based)

CADA_VEICULO:
    CMP CL, BL
    JGE FIM_LISTAR

    ; Imprimir "  --- Veiculo #N ---"
    LEA DX, lbl_vnum
    MOV AH, 09h
    INT 21h
    MOV AH, 02h
    MOV DL, CL
    ADD DL, '1'
    INT 21h
    LEA DX, lbl_dash
    MOV AH, 09h
    INT 21h

    ; Imprimir Marca
    LEA DX, lbl_marca
    MOV AH, 09h
    INT 21h
    CALL PRINT_CAMPO   ; SI avanca CAMPO_TAM
    LEA DX, msg_nl
    MOV AH, 09h
    INT 21h

    ; Imprimir Modelo
    LEA DX, lbl_modelo
    MOV AH, 09h
    INT 21h
    CALL PRINT_CAMPO
    LEA DX, msg_nl
    MOV AH, 09h
    INT 21h

    ; Imprimir KMs
    LEA DX, lbl_kms
    MOV AH, 09h
    INT 21h
    CALL PRINT_CAMPO
    LEA DX, msg_nl
    MOV AH, 09h
    INT 21h

    ; Imprimir Ano
    LEA DX, lbl_ano
    MOV AH, 09h
    INT 21h
    CALL PRINT_CAMPO
    LEA DX, msg_nl
    MOV AH, 09h
    INT 21h

    ; Imprimir Cor
    LEA DX, lbl_cor
    MOV AH, 09h
    INT 21h
    CALL PRINT_CAMPO
    LEA DX, msg_nl
    MOV AH, 09h
    INT 21h

    ; Imprimir Preco
    LEA DX, lbl_preco
    MOV AH, 09h
    INT 21h
    CALL PRINT_CAMPO_PRECO
    LEA DX, lbl_eur
    MOV AH, 09h
    INT 21h

    INC CL
    JMP CADA_VEICULO

LISTAR_VAZIO:
    LEA DX, msg_vazio
    MOV AH, 09h
    INT 21h

FIM_LISTAR:
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
LISTAR_VEICULOS ENDP

; ============================================================
; PRINT_CAMPO
;   Imprime string null-terminated a partir de SI (max CAMPO_TAM)
;   SI avanca CAMPO_TAM bytes
; ============================================================
PRINT_CAMPO PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV CX, CAMPO_TAM

PRINT_CHAR_C:
    CMP CX, 0
    JE FIM_PRINT_C
    MOV AL, [SI]
    TEST AL, AL
    JZ FIM_PRINT_C
    MOV AH, 02h
    MOV DL, AL
    INT 21h
    INC SI
    DEC CX
    JMP PRINT_CHAR_C

FIM_PRINT_C:
    ; Avancar SI para o proximo campo (zerar o resto)
    ; CX contem os bytes restantes
    ; SI = SI + CX
    ADD SI, CX     ; saltar para o fim do campo

    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_CAMPO ENDP

; ============================================================
; PRINT_CAMPO_PRECO  (igual mas PRECO_TAM)
; ============================================================
PRINT_CAMPO_PRECO PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV CX, PRECO_TAM

PRINT_CHAR_P:
    CMP CX, 0
    JE FIM_PRINT_P
    MOV AL, [SI]
    TEST AL, AL
    JZ FIM_PRINT_P
    MOV AH, 02h
    MOV DL, AL
    INT 21h
    INC SI
    DEC CX
    JMP PRINT_CHAR_P

FIM_PRINT_P:
    ADD SI, CX

    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_CAMPO_PRECO ENDP

; ============================================================
; LER_CAMPO
;   Le input para [DI], max BX bytes
;   Substitui Enter por 0, zera o resto
; ============================================================
LER_CAMPO PROC
    ; BX = tamanho maximo do campo
    ; DI = ponteiro destino (avanca BX bytes no fim)
    PUSH AX
    PUSH CX
    PUSH SI

    ; SI = ponteiro de escrita (anda junto com DI durante a leitura)
    ; Usamos SI como cursor de escrita para evitar [DI+CX]
    MOV SI, DI     ; SI aponta para inicio do campo
    MOV CX, 0      ; numero de chars lidos ate agora

LER_LOOP:
    CMP CX, BX
    JGE LER_STRIP

    MOV AH, 01h
    INT 21h        ; ler char com echo

    CMP AL, 13     ; Enter?
    JE LER_STRIP
    CMP AL, 8      ; Backspace?
    JE LER_BACK

    ; Guardar char em [SI] e avancar SI
    MOV [SI], AL
    INC SI
    INC CX
    JMP LER_LOOP

LER_BACK:
    CMP CX, 0
    JE LER_LOOP
    DEC SI
    DEC CX
    MOV BYTE PTR [SI], 0   ; apagar o char guardado
    ; Apagar visualmente: backspace, espaco, backspace
    MOV AH, 02h
    MOV DL, ' '
    INT 21h
    MOV DL, 8
    INT 21h
    JMP LER_LOOP

LER_STRIP:
    ; Zerar do cursor SI ate DI+BX (fim do campo)
    ; SI ja esta na posicao certa apos a leitura
LER_ZERO:
    MOV AX, DI
    ADD AX, BX     ; AX = endereco do fim do campo
    CMP SI, AX
    JGE FIM_LER_CAMPO
    MOV BYTE PTR [SI], 0
    INC SI
    JMP LER_ZERO

FIM_LER_CAMPO:
    ; Avancar DI para o proximo campo
    ADD DI, BX

    POP SI
    POP CX
    POP AX
    RET
LER_CAMPO ENDP

; ============================================================
; PEDIR_CAMPOS_VEICULO
;   DI = ptr destino, le todos os 6 campos
; ============================================================
PEDIR_CAMPOS PROC
    PUSH DX
    PUSH BX

    LEA DX, prm_marca
    MOV AH, 09h
    INT 21h
    MOV BX, CAMPO_TAM
    CALL LER_CAMPO

    LEA DX, prm_modelo
    MOV AH, 09h
    INT 21h
    MOV BX, CAMPO_TAM
    CALL LER_CAMPO

    LEA DX, prm_kms
    MOV AH, 09h
    INT 21h
    MOV BX, CAMPO_TAM
    CALL LER_CAMPO

    LEA DX, prm_ano
    MOV AH, 09h
    INT 21h
    MOV BX, CAMPO_TAM
    CALL LER_CAMPO

    LEA DX, prm_cor
    MOV AH, 09h
    INT 21h
    MOV BX, CAMPO_TAM
    CALL LER_CAMPO

    LEA DX, prm_preco
    MOV AH, 09h
    INT 21h
    MOV BX, PRECO_TAM
    CALL LER_CAMPO

    POP BX
    POP DX
    RET
PEDIR_CAMPOS ENDP

; ============================================================
; ADICIONAR_VEICULO
;   AL = 0 carros, AL = 1 motas
; ============================================================
ADICIONAR_VEICULO PROC
    PUSH AX
    PUSH BX
    PUSH DI
    PUSH DX

    CMP AL, 0
    JE CALC_CARRO_ADD

    ; Motas
    MOV BL, num_motas
    MOV BH, 0
    MOV AX, VEICULO_TAM
    MUL BX
    MOV DI, OFFSET arr_motas
    ADD DI, AX
    CALL PEDIR_CAMPOS
    INC num_motas
    JMP ADD_OK

CALC_CARRO_ADD:
    MOV BL, num_carros
    MOV BH, 0
    MOV AX, VEICULO_TAM
    MUL BX
    MOV DI, OFFSET arr_carros
    ADD DI, AX
    CALL PEDIR_CAMPOS
    INC num_carros

ADD_OK:
    LEA DX, msg_ok_add
    MOV AH, 09h
    INT 21h

    POP DX
    POP DI
    POP BX
    POP AX
    RET
ADICIONAR_VEICULO ENDP

; ============================================================
; PEDIR_IDX
;   Le numero de 1-5, retorna 0-based em AL
;   Se invalido retorna AL=0FFh
; ============================================================
PEDIR_IDX PROC
    PUSH BX
    PUSH DX

    LEA DX, prm_idx
    MOV AH, 09h
    INT 21h

    MOV AH, 01h
    INT 21h
    MOV BL, AL

    ; Consumir Enter
    MOV AH, 01h
    INT 21h

    CMP BL, '1'
    JB IDX_INV
    CMP BL, '5'
    JA IDX_INV

    SUB BL, '1'    ; 0-based
    MOV AL, BL
    JMP FIM_IDX

IDX_INV:
    MOV AL, 0FFh

FIM_IDX:
    POP DX
    POP BX
    RET
PEDIR_IDX ENDP

; ============================================================
; EDITAR_VEICULO
;   AL = 0 carros, AL = 1 motas
;   idx_tmp = indice 0-based (ja validado pelo caller)
;
;   Fluxo:
;     1. Calcula DI = base do veiculo seleccionado
;     2. Guarda DI em vei_base
;     3. Loop: mostra submenu, o utilizador escolhe o campo
;        a editar, pede o novo valor so para esse campo
;     4. [0] sai do loop
; ============================================================
EDITAR_VEICULO PROC
    PUSH AX
    PUSH BX
    PUSH DI
    PUSH DX

    ; --- Calcular DI = endereco do veiculo a editar ---
    MOV BL, idx_tmp
    MOV BH, 0

    CMP AL, 0
    JE CALC_BASE_CARRO

    ; Motas
    MOV AX, VEICULO_TAM
    MUL BX
    MOV DI, OFFSET arr_motas
    ADD DI, AX
    JMP EDIT_LOOP

CALC_BASE_CARRO:
    MOV AX, VEICULO_TAM
    MUL BX
    MOV DI, OFFSET arr_carros
    ADD DI, AX

    ; --- DI aponta para o inicio do veiculo ---
    ; Guardar base em vei_base para poder voltar a ela
EDIT_LOOP:
    MOV vei_base, DI

    ; Mostrar submenu de edicao
    LEA DX, msg_menu_edit
    MOV AH, 09h
    INT 21h

    ; Ler opcao
    MOV AH, 01h
    INT 21h
    MOV BL, AL
    MOV AH, 01h   ; consumir Enter
    INT 21h

    CMP BL, '0'
    JE EDIT_FIM
    CMP BL, '1'
    JE EDIT_MARCA
    CMP BL, '2'
    JE EDIT_MODELO
    CMP BL, '3'
    JE EDIT_KMS
    CMP BL, '4'
    JE EDIT_ANO
    CMP BL, '5'
    JE EDIT_COR
    CMP BL, '6'
    JE EDIT_PRECO
    ; opcao invalida - repetir
    LEA DX, msg_inv_op
    MOV AH, 09h
    INT 21h
    MOV DI, vei_base
    JMP EDIT_LOOP

EDIT_MARCA:
    ; Mostrar valor actual da Marca (offset 0)
    MOV DI, vei_base
    MOV SI, DI
    LEA DX, msg_edit_atual
    MOV AH, 09h
    INT 21h
    CALL PRINT_CAMPO_SI_ONLY
    LEA DX, msg_nl
    MOV AH, 09h
    INT 21h
    ; Pedir novo valor
    LEA DX, prm_marca
    MOV AH, 09h
    INT 21h
    MOV DI, vei_base
    MOV BX, CAMPO_TAM
    CALL LER_CAMPO
    JMP EDIT_OK_CAMPO

EDIT_MODELO:
    MOV DI, vei_base
    MOV SI, DI
    ADD SI, CAMPO_TAM      ; offset 1*CAMPO_TAM = Modelo
    LEA DX, msg_edit_atual
    MOV AH, 09h
    INT 21h
    CALL PRINT_CAMPO_SI_ONLY
    LEA DX, msg_nl
    MOV AH, 09h
    INT 21h
    LEA DX, prm_modelo
    MOV AH, 09h
    INT 21h
    MOV DI, vei_base
    ADD DI, CAMPO_TAM      ; DI aponta para Modelo
    MOV BX, CAMPO_TAM
    CALL LER_CAMPO
    JMP EDIT_OK_CAMPO

EDIT_KMS:
    MOV DI, vei_base
    MOV SI, DI
    ADD SI, CAMPO_TAM
    ADD SI, CAMPO_TAM      ; offset 2*CAMPO_TAM = KMs
    LEA DX, msg_edit_atual
    MOV AH, 09h
    INT 21h
    CALL PRINT_CAMPO_SI_ONLY
    LEA DX, msg_nl
    MOV AH, 09h
    INT 21h
    LEA DX, prm_kms
    MOV AH, 09h
    INT 21h
    MOV DI, vei_base
    ADD DI, CAMPO_TAM
    ADD DI, CAMPO_TAM      ; DI aponta para KMs
    MOV BX, CAMPO_TAM
    CALL LER_CAMPO
    JMP EDIT_OK_CAMPO

EDIT_ANO:
    MOV DI, vei_base
    MOV SI, DI
    ADD SI, CAMPO_TAM
    ADD SI, CAMPO_TAM
    ADD SI, CAMPO_TAM      ; offset 3*CAMPO_TAM = Ano
    LEA DX, msg_edit_atual
    MOV AH, 09h
    INT 21h
    CALL PRINT_CAMPO_SI_ONLY
    LEA DX, msg_nl
    MOV AH, 09h
    INT 21h
    LEA DX, prm_ano
    MOV AH, 09h
    INT 21h
    MOV DI, vei_base
    ADD DI, CAMPO_TAM
    ADD DI, CAMPO_TAM
    ADD DI, CAMPO_TAM      ; DI aponta para Ano
    MOV BX, CAMPO_TAM
    CALL LER_CAMPO
    JMP EDIT_OK_CAMPO

EDIT_COR:
    MOV DI, vei_base
    MOV SI, DI
    ADD SI, CAMPO_TAM
    ADD SI, CAMPO_TAM
    ADD SI, CAMPO_TAM
    ADD SI, CAMPO_TAM      ; offset 4*CAMPO_TAM = Cor
    LEA DX, msg_edit_atual
    MOV AH, 09h
    INT 21h
    CALL PRINT_CAMPO_SI_ONLY
    LEA DX, msg_nl
    MOV AH, 09h
    INT 21h
    LEA DX, prm_cor
    MOV AH, 09h
    INT 21h
    MOV DI, vei_base
    ADD DI, CAMPO_TAM
    ADD DI, CAMPO_TAM
    ADD DI, CAMPO_TAM
    ADD DI, CAMPO_TAM      ; DI aponta para Cor
    MOV BX, CAMPO_TAM
    CALL LER_CAMPO
    JMP EDIT_OK_CAMPO

EDIT_PRECO:
    MOV DI, vei_base
    MOV SI, DI
    ADD SI, CAMPO_TAM
    ADD SI, CAMPO_TAM
    ADD SI, CAMPO_TAM
    ADD SI, CAMPO_TAM
    ADD SI, CAMPO_TAM      ; offset 5*CAMPO_TAM = Preco
    LEA DX, msg_edit_atual
    MOV AH, 09h
    INT 21h
    CALL PRINT_CAMPO_PRECO_SI_ONLY
    LEA DX, msg_nl
    MOV AH, 09h
    INT 21h
    LEA DX, prm_preco
    MOV AH, 09h
    INT 21h
    MOV DI, vei_base
    ADD DI, CAMPO_TAM
    ADD DI, CAMPO_TAM
    ADD DI, CAMPO_TAM
    ADD DI, CAMPO_TAM
    ADD DI, CAMPO_TAM      ; DI aponta para Preco
    MOV BX, PRECO_TAM
    CALL LER_CAMPO
    JMP EDIT_OK_CAMPO

EDIT_OK_CAMPO:
    LEA DX, msg_ok_ed
    MOV AH, 09h
    INT 21h
    ; Voltar ao submenu para editar mais campos
    MOV DI, vei_base
    JMP EDIT_LOOP

EDIT_FIM:
    POP DX
    POP DI
    POP BX
    POP AX
    RET
EDITAR_VEICULO ENDP

; ============================================================
; PRINT_CAMPO_SI_ONLY
;   Imprime campo a partir de SI (max CAMPO_TAM)
;   NAO avanca SI (apenas para mostrar valor actual)
; ============================================================
PRINT_CAMPO_SI_ONLY PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    MOV CX, CAMPO_TAM

PCSO_LOOP:
    CMP CX, 0
    JE PCSO_FIM
    MOV AL, [SI]
    TEST AL, AL
    JZ PCSO_FIM
    MOV AH, 02h
    MOV DL, AL
    INT 21h
    INC SI
    DEC CX
    JMP PCSO_LOOP

PCSO_FIM:
    POP SI
    POP DX
    POP CX
    POP AX
    RET
PRINT_CAMPO_SI_ONLY ENDP

; ============================================================
; PRINT_CAMPO_PRECO_SI_ONLY
;   Igual mas PRECO_TAM, NAO avanca SI
; ============================================================
PRINT_CAMPO_PRECO_SI_ONLY PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    MOV CX, PRECO_TAM

PCSOP_LOOP:
    CMP CX, 0
    JE PCSOP_FIM
    MOV AL, [SI]
    TEST AL, AL
    JZ PCSOP_FIM
    MOV AH, 02h
    MOV DL, AL
    INT 21h
    INC SI
    DEC CX
    JMP PCSOP_LOOP

PCSOP_FIM:
    POP SI
    POP DX
    POP CX
    POP AX
    RET
PRINT_CAMPO_PRECO_SI_ONLY ENDP

END MAIN
