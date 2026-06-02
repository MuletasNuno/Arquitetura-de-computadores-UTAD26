; ============================================================
;  GESTAO DE VEICULOS - MASM / EMU8086 (16-bit, DOS)
;  Menu: Utilizador / Admin (com password)
;  Veiculos: Carros e Motas
;  Campos: Marca, Modelo, KMs, Ano, Cor, Preco, Cilindrada
; ============================================================

.MODEL SMALL
.STACK 200h

; ============================================================
; CONSTANTES
; ============================================================
CAMPO_TAM    EQU 20      ; tamanho de cada campo de texto
PRECO_TAM    EQU 8       ; tamanho do campo preco
CIL_TAM      EQU 8       ; tamanho do campo cilindrada
;

VEICULO_TAM  EQU 116
MAX_VEI      EQU 5       ; maximo de veiculos por tipo (aumentar se for preciso, mas o codigo depois demora muito a carregar) se aumentar nao esquecer de aumentar na opcao de escolher o carro que esta de 1-5

; Offsets dentro de um veiculo
OFF_MARCA    EQU 0
OFF_MODELO   EQU 20
OFF_KMS      EQU 40
OFF_ANO      EQU 60
OFF_COR      EQU 80
OFF_PRECO    EQU 100
OFF_CIL      EQU 108

; Tamanho total do bloco de dados gravado em ficheiro
DADOS_CAB    EQU 2
DADOS_CARR   EQU MAX_VEI * VEICULO_TAM
DADOS_MOTA   EQU MAX_VEI * VEICULO_TAM
DADOS_TOT    EQU DADOS_CAB + DADOS_CARR + DADOS_MOTA

; ============================================================
.DATA
; ============================================================

; --- Mensagens gerais ---
msg_sep      DB "====================================", 13, 10, "$"
msg_titulo   DB "   GESTAO DE VEICULOS", 13, 10, "$"
msg_nl       DB 13, 10, "$"

; --- Menu principal ---
msg_menu_prin DB 13,10
              DB "  [1] Utilizador", 13,10
              DB "  [2] Administrador", 13,10
              DB "  [0] Sair", 13,10
              DB "  Opcao: $"

; --- Login admin ---
msg_pass     DB 13,10,"  Password admin: $"
msg_erro_p   DB 13,10,"  [ERRO] Password incorrecta!", 13,10,"$"
msg_acesso   DB 13,10,"  [OK] Acesso concedido!", 13,10,"$"

password     DB "123456", 0
PASS_LEN     EQU 6

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
              DB "  [7] Eliminar Carro",13,10
              DB "  [8] Eliminar Mota",13,10
              DB "  [0] Voltar",13,10
              DB "  Opcao: $"

; --- Labels de exibicao ---
lbl_marca    DB 13,10,"  Marca       : $"
lbl_modelo   DB "  Modelo      : $"
lbl_kms      DB "  KMs         : $"
lbl_ano      DB "  Ano         : $"
lbl_cor      DB "  Cor         : $"
lbl_preco    DB "  Preco       : $"
lbl_cil      DB "  Cilindrada  : $"
lbl_eur      DB " EUR",13,10,"$"
lbl_cc       DB " cc",13,10,"$"
lbl_vnum     DB 13,10,"  --- Veiculo #$"
lbl_dash     DB " ---",13,10,"$"

; --- Prompts de input ---
prm_marca    DB 13,10,"  Insira Marca      : $"
prm_modelo   DB "  Insira Modelo     : $"
prm_kms      DB "  Insira KMs        : $"
prm_ano      DB "  Insira Ano        : $"
prm_cor      DB "  Insira Cor        : $"
prm_preco    DB "  Insira Preco      : $"
prm_cil      DB "  Insira Cilindrada : $"
prm_idx      DB 13,10,"  Numero (1-5)      : $"

; --- Submenu de edicao ---
msg_menu_edit DB 13,10
              DB "  O que deseja editar?",13,10
              DB "  [1] Marca",13,10
              DB "  [2] Modelo",13,10
              DB "  [3] KMs",13,10
              DB "  [4] Ano",13,10
              DB "  [5] Cor",13,10
              DB "  [6] Preco",13,10
              DB "  [7] Cilindrada",13,10
              DB "  [0] Terminar edicao",13,10
              DB "  Opcao: $"

msg_edit_atual DB 13,10,"  Valor actual: $"

; --- Cabecalhos ---
hdr_carros   DB 13,10,"  === LISTA DE CARROS ===",13,10,"$"
hdr_motas    DB 13,10,"  === LISTA DE MOTAS  ===",13,10,"$"

; --- Mensagens de estado ---
msg_vazio    DB "  (Nenhum veiculo registado)",13,10,"$"
msg_ok_add   DB 13,10,"  [OK] Veiculo adicionado!",13,10,"$"
msg_ok_ed    DB 13,10,"  [OK] Campo editado!",13,10,"$"
msg_cheio    DB 13,10,"  [ERRO] Lista cheia!",13,10,"$"
msg_inv_op   DB 13,10,"  Opcao invalida.",13,10,"$"
msg_inv_idx  DB 13,10,"  Numero invalido.",13,10,"$"
msg_adeus    DB 13,10,"  Ate logo!",13,10,"$"
msg_ok_del   DB 13,10,"  [OK] Veiculo eliminado!",13,10,"$"

; --- ASCII art do carro ---
msg_carro    DB 13,10
             DB "                  __..-======-------..__",13,10
             DB "              . '    ______    ___________`.",13,10
             DB "            .' .--. '.-----.`. `.-----.-----`.",13,10
             DB "           / .'   | ||      `.`  \     \     \",13,10
             DB "         .' /     | ||        \  \_____\_____\__________[_]",13,10
             DB "        /   `-----' |`---------\  .'                       \",13,10
             DB "       /============|============\-------------------.._____|",13,10
             DB "    .-`---.         |-==.        |'.__________________  =====|-._",13,10
             DB "  .'        `.      |            |      .--------.    _` ====|  _ .",13,10
             DB " /     __     \     |            |   .'           `. [_] `.==| [_] \",13,10
             DB "[   .`    `.  |     |            | .'     .---.     \      \=|     |",13,10
             DB "|  | / .-. \  |_____\___________/_/     .'---. `.    |     | |     |",13,10
             DB " `-'| | O | `.`------------------'.....'/ .-. \ |    |       ___.--'",13,10
             DB "LGB  \ `-' / /   `._.'                 | | O | |'___...----''___.--'",13,10
             DB "      `._.'.'                           \ `-' / [___...----''_.'",13,10
             DB "                                         `._.'.'",13,10
             DB 13,10,"$"

; --- Mensagens de ficheiro ---
msg_dat_ok   DB 13,10,"  [OK] Dados gravados em VEICULOS.DAT",13,10,"$"
msg_dat_load DB 13,10,"  [OK] Dados carregados de VEICULOS.DAT",13,10,"$"
msg_dat_novo DB 13,10,"  [INFO] VEICULOS.DAT nao encontrado. A usar dados de exemplo.",13,10,"$"
msg_dat_err  DB 13,10,"  [AVISO] Erro ao gravar VEICULOS.DAT.",13,10,"$"

; Nome do ficheiro de dados
fname        DB "VEICULOS.DAT", 0

; Handle do ficheiro (word)
fhandle      DW 0

; ============================================================
; DADOS DE EXEMPLO (pre-carregados se .DAT nao existir)
; ============================================================

; Carro 1 - Toyota Corolla
c1_marca  DB "Toyota",  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
c1_modelo DB "Corolla", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
c1_kms    DB "45000",   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
c1_ano    DB "2020",    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
c1_cor    DB "Branco",  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
c1_preco  DB "18500",   0, 0, 0
c1_cil    DB "1800",    0, 0, 0, 0

; Carro 2 - BMW Serie 3
c2_marca  DB "BMW",     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
c2_modelo DB "Serie 3", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
c2_kms    DB "80000",   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
c2_ano    DB "2018",    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
c2_cor    DB "Preto",   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
c2_preco  DB "24000",   0, 0, 0
c2_cil    DB "2000",    0, 0, 0, 0

; Mota 1 - Honda CB500F
m1_marca  DB "Honda",   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
m1_modelo DB "CB500F",  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
m1_kms    DB "12000",   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
m1_ano    DB "2021",    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
m1_cor    DB "Vermelho",0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
m1_preco  DB "6800",    0, 0, 0, 0
m1_cil    DB "471",     0, 0, 0, 0, 0

; Mota 2 - Yamaha MT-07
m2_marca  DB "Yamaha",  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
m2_modelo DB "MT-07",   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
m2_kms    DB "30000",   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
m2_ano    DB "2019",    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
m2_cor    DB "Azul",    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
m2_preco  DB "8200",    0, 0, 0, 0
m2_cil    DB "689",     0, 0, 0, 0, 0

; ============================================================
; ARRAYS DE VEICULOS
; ============================================================
arr_carros   DB MAX_VEI * VEICULO_TAM DUP(0)
arr_motas    DB MAX_VEI * VEICULO_TAM DUP(0)

num_carros   DB 0
num_motas    DB 0

; Buffers auxiliares
pass_buf     DB 12 DUP(0)
idx_tmp      DB 0
vei_base     DW 0

; ============================================================
.CODE
; ============================================================

MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX

    CALL CARREGAR_DADOS

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

    MOV AH, 01h
    INT 21h
    MOV BL, AL
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
    LEA DX, msg_carro
    MOV AH, 09h
    INT 21h
    LEA DX, msg_adeus
    MOV AH, 09h
    INT 21h
    MOV AX, 4C00h
    INT 21h

MAIN ENDP

; ============================================================
; CARREGAR_DADOS
; ============================================================
CARREGAR_DADOS PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV AX, 3D00h
    LEA DX, fname
    INT 21h
    JC DAT_NAO_EXISTE

    MOV fhandle, AX

    MOV BX, fhandle
    LEA DX, num_carros
    MOV CX, 2
    MOV AH, 3Fh
    INT 21h
    JC FECHAR_E_EXEMPLO

    LEA DX, arr_carros
    MOV CX, DADOS_CARR
    MOV AH, 3Fh
    INT 21h
    JC FECHAR_E_EXEMPLO

    LEA DX, arr_motas
    MOV CX, DADOS_MOTA
    MOV AH, 3Fh
    INT 21h
    JC FECHAR_E_EXEMPLO

    MOV AH, 3Eh
    MOV BX, fhandle
    INT 21h

    LEA DX, msg_dat_load
    MOV AH, 09h
    INT 21h
    JMP FIM_CARR

FECHAR_E_EXEMPLO:
    MOV AH, 3Eh
    MOV BX, fhandle
    INT 21h

DAT_NAO_EXISTE:
    LEA DX, msg_dat_novo
    MOV AH, 09h
    INT 21h
    CALL INIT_DADOS

FIM_CARR:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
CARREGAR_DADOS ENDP

; ============================================================
; GRAVAR_DADOS
; ============================================================
GRAVAR_DADOS PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV AX, 3C00h
    MOV CX, 0
    LEA DX, fname
    INT 21h
    JC GRAVAR_ERRO

    MOV fhandle, AX

    MOV BX, fhandle
    LEA DX, num_carros
    MOV CX, 2
    MOV AH, 40h
    INT 21h
    JC GRAVAR_FECHAR_ERR

    LEA DX, arr_carros
    MOV CX, DADOS_CARR
    MOV AH, 40h
    INT 21h
    JC GRAVAR_FECHAR_ERR

    LEA DX, arr_motas
    MOV CX, DADOS_MOTA
    MOV AH, 40h
    INT 21h
    JC GRAVAR_FECHAR_ERR

    MOV AH, 3Eh
    MOV BX, fhandle
    INT 21h

    LEA DX, msg_dat_ok
    MOV AH, 09h
    INT 21h
    JMP FIM_GRAVAR

GRAVAR_FECHAR_ERR:
    MOV AH, 3Eh
    MOV BX, fhandle
    INT 21h

GRAVAR_ERRO:
    LEA DX, msg_dat_err
    MOV AH, 09h
    INT 21h

FIM_GRAVAR:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
GRAVAR_DADOS ENDP

; ============================================================
; INIT_DADOS
; ============================================================
INIT_DADOS PROC
    PUSH AX
    PUSH CX
    PUSH SI
    PUSH DI

    ; --- Carro 1 ---
    MOV DI, OFFSET arr_carros
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
    MOV SI, OFFSET c1_cil
    MOV CX, CIL_TAM
    REP MOVSB

    ; --- Carro 2 ---
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
    MOV SI, OFFSET c2_cil
    MOV CX, CIL_TAM
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
    MOV SI, OFFSET m1_cil
    MOV CX, CIL_TAM
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
    MOV SI, OFFSET m2_cil
    MOV CX, CIL_TAM
    REP MOVSB

    MOV BYTE PTR num_motas, 2

    POP DI
    POP SI
    POP CX
    POP AX
    RET
INIT_DADOS ENDP

; ============================================================
; LOGIN_ADMIN  - retorna AL=1 se correcta, AL=0 se errada
; ============================================================
LOGIN_ADMIN PROC
    PUSH BX
    PUSH CX
    PUSH SI
    PUSH DI

    LEA DX, msg_pass
    MOV AH, 09h
    INT 21h

    LEA DI, pass_buf
    MOV CX, 0

LER_PASS:
    MOV AH, 08h
    INT 21h
    CMP AL, 13
    JE FIM_LER
    CMP AL, 8
    JE BACKSPACE_P
    CMP CX, PASS_LEN
    JGE LER_PASS
    MOV [DI], AL
    INC DI
    INC CX
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
    MOV AH, 02h
    MOV DL, 8
    INT 21h
    MOV DL, ' '
    INT 21h
    MOV DL, 8
    INT 21h
    JMP LER_PASS

FIM_LER:
    MOV BYTE PTR [DI], 0
    CMP CX, PASS_LEN
    JNE PASS_ERRADA

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
    INT 21h

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
    MOV AL, 0
    CALL LISTAR_VEICULOS
    JMP LOOP_USER

VER_MOTAS_U:
    MOV AL, 1
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
    INT 21h

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
    CMP BL, '7'
    JE DEL_C_A
    CMP BL, '8'
    JE DEL_M_A
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
    MOV AL, 0
    CALL ADICIONAR_VEICULO
    CALL GRAVAR_DADOS
    JMP LOOP_ADM

ADD_M_A:
    MOV BL, num_motas
    CMP BL, MAX_VEI
    JGE CHEIO_ADM
    MOV AL, 1
    CALL ADICIONAR_VEICULO
    CALL GRAVAR_DADOS
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
    CALL GRAVAR_DADOS
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
    CALL GRAVAR_DADOS
    JMP LOOP_ADM

DEL_C_A:
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
    CALL ELIMINAR_VEICULO
    CALL GRAVAR_DADOS
    JMP LOOP_ADM

DEL_M_A:
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
    CALL ELIMINAR_VEICULO
    CALL GRAVAR_DADOS
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
; LISTAR_VEICULOS  (AL=0 carros, AL=1 motas)
; ============================================================
LISTAR_VEICULOS PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    CMP AL, 0
    JE LIST_CARROS

    LEA DX, hdr_motas
    MOV AH, 09h
    INT 21h
    MOV BL, num_motas
    MOV SI, OFFSET arr_motas
    JMP LIST_LOOP

LIST_CARROS:
    LEA DX, hdr_carros
    MOV AH, 09h
    INT 21h
    MOV BL, num_carros
    MOV SI, OFFSET arr_carros

LIST_LOOP:
    CMP BL, 0
    JE LIST_VAZIO

    MOV CL, 0

CADA_VEI:
    CMP CL, BL
    JGE FIM_LIST

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

    LEA DX, lbl_marca
    MOV AH, 09h
    INT 21h
    CALL PRINT_CAMPO
    LEA DX, msg_nl
    MOV AH, 09h
    INT 21h

    LEA DX, lbl_modelo
    MOV AH, 09h
    INT 21h
    CALL PRINT_CAMPO
    LEA DX, msg_nl
    MOV AH, 09h
    INT 21h

    LEA DX, lbl_kms
    MOV AH, 09h
    INT 21h
    CALL PRINT_CAMPO
    LEA DX, msg_nl
    MOV AH, 09h
    INT 21h

    LEA DX, lbl_ano
    MOV AH, 09h
    INT 21h
    CALL PRINT_CAMPO
    LEA DX, msg_nl
    MOV AH, 09h
    INT 21h

    LEA DX, lbl_cor
    MOV AH, 09h
    INT 21h
    CALL PRINT_CAMPO
    LEA DX, msg_nl
    MOV AH, 09h
    INT 21h

    LEA DX, lbl_preco
    MOV AH, 09h
    INT 21h
    CALL PRINT_CAMPO_PRECO
    LEA DX, lbl_eur
    MOV AH, 09h
    INT 21h

    LEA DX, lbl_cil
    MOV AH, 09h
    INT 21h
    CALL PRINT_CAMPO_CIL
    LEA DX, lbl_cc
    MOV AH, 09h
    INT 21h

    INC CL
    JMP CADA_VEI

LIST_VAZIO:
    LEA DX, msg_vazio
    MOV AH, 09h
    INT 21h

FIM_LIST:
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
LISTAR_VEICULOS ENDP

; ============================================================
; PRINT_CAMPO     
; ============================================================
PRINT_CAMPO PROC
    PUSH AX
    PUSH CX
    PUSH DX
    MOV CX, CAMPO_TAM
PPC_L:
    CMP CX, 0
    JE PPC_F
    MOV AL, [SI]
    TEST AL, AL
    JZ PPC_F
    MOV AH, 02h
    MOV DL, AL
    INT 21h
    INC SI
    DEC CX
    JMP PPC_L
PPC_F:
    ADD SI, CX
    POP DX
    POP CX
    POP AX
    RET
PRINT_CAMPO ENDP

; ============================================================
; PRINT_CAMPO_PRECO
; ============================================================
PRINT_CAMPO_PRECO PROC
    PUSH AX
    PUSH CX
    PUSH DX
    MOV CX, PRECO_TAM
PPP_L:
    CMP CX, 0
    JE PPP_F
    MOV AL, [SI]
    TEST AL, AL
    JZ PPP_F
    MOV AH, 02h
    MOV DL, AL
    INT 21h
    INC SI
    DEC CX
    JMP PPP_L
PPP_F:
    ADD SI, CX
    POP DX
    POP CX
    POP AX
    RET
PRINT_CAMPO_PRECO ENDP

; ============================================================
; PRINT_CAMPO_CIL   
; ============================================================
PRINT_CAMPO_CIL PROC
    PUSH AX
    PUSH CX
    PUSH DX
    MOV CX, CIL_TAM
PPCIL_L:
    CMP CX, 0
    JE PPCIL_F
    MOV AL, [SI]
    TEST AL, AL
    JZ PPCIL_F
    MOV AH, 02h
    MOV DL, AL
    INT 21h
    INC SI
    DEC CX
    JMP PPCIL_L
PPCIL_F:
    ADD SI, CX
    POP DX
    POP CX
    POP AX
    RET
PRINT_CAMPO_CIL ENDP

; ============================================================
; PRINT_CAMPO_SI_ONLY 
; ============================================================
PRINT_CAMPO_SI_ONLY PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI
    MOV CX, CAMPO_TAM
PCSO_L:
    CMP CX, 0
    JE PCSO_F
    MOV AL, [SI]
    TEST AL, AL
    JZ PCSO_F
    MOV AH, 02h
    MOV DL, AL
    INT 21h
    INC SI
    DEC CX
    JMP PCSO_L
PCSO_F:
    POP SI
    POP DX
    POP CX
    POP AX
    RET
PRINT_CAMPO_SI_ONLY ENDP

; ============================================================
; PRINT_PRECO_SI_ONLY
; ============================================================
PRINT_PRECO_SI_ONLY PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI
    MOV CX, PRECO_TAM
PPSO_L:
    CMP CX, 0
    JE PPSO_F
    MOV AL, [SI]
    TEST AL, AL
    JZ PPSO_F
    MOV AH, 02h
    MOV DL, AL
    INT 21h
    INC SI
    DEC CX
    JMP PPSO_L
PPSO_F:
    POP SI
    POP DX
    POP CX
    POP AX
    RET
PRINT_PRECO_SI_ONLY ENDP

; ============================================================
; PRINT_CIL_SI_ONLY
; ============================================================
PRINT_CIL_SI_ONLY PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI
    MOV CX, CIL_TAM
PCILSO_L:
    CMP CX, 0
    JE PCILSO_F
    MOV AL, [SI]
    TEST AL, AL
    JZ PCILSO_F
    MOV AH, 02h
    MOV DL, AL
    INT 21h
    INC SI
    DEC CX
    JMP PCILSO_L
PCILSO_F:
    POP SI
    POP DX
    POP CX
    POP AX
    RET
PRINT_CIL_SI_ONLY ENDP

; ============================================================
; LER_CAMPO  
; ============================================================
LER_CAMPO PROC
    PUSH AX
    PUSH CX
    PUSH SI

    MOV SI, DI
    MOV CX, 0

LC_LOOP:
    CMP CX, BX
    JGE LC_STRIP
    MOV AH, 01h
    INT 21h
    CMP AL, 13
    JE LC_STRIP
    CMP AL, 8
    JE LC_BACK
    MOV [SI], AL
    INC SI
    INC CX
    JMP LC_LOOP

LC_BACK:
    CMP CX, 0
    JE LC_LOOP
    DEC SI
    DEC CX
    MOV BYTE PTR [SI], 0
    MOV AH, 02h
    MOV DL, ' '
    INT 21h
    MOV DL, 8
    INT 21h
    JMP LC_LOOP

LC_STRIP:
LC_ZERO:
    MOV AX, DI
    ADD AX, BX
    CMP SI, AX
    JGE LC_FIM
    MOV BYTE PTR [SI], 0
    INC SI
    JMP LC_ZERO

LC_FIM:
    ADD DI, BX
    POP SI
    POP CX
    POP AX
    RET
LER_CAMPO ENDP

; ============================================================
; PEDIR_CAMPOS  (DI = inicio do veiculo)
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

    LEA DX, prm_cil
    MOV AH, 09h
    INT 21h
    MOV BX, CIL_TAM
    CALL LER_CAMPO

    POP BX
    POP DX
    RET
PEDIR_CAMPOS ENDP

; ============================================================
; ADICIONAR_VEICULO  (AL=0 carros, AL=1 motas)
; ============================================================
ADICIONAR_VEICULO PROC
    PUSH AX
    PUSH BX
    PUSH DI
    PUSH DX

    CMP AL, 0
    JE CALC_ADD_CARR

    MOV BL, num_motas
    MOV BH, 0
    MOV AX, VEICULO_TAM
    MUL BX
    MOV DI, OFFSET arr_motas
    ADD DI, AX
    CALL PEDIR_CAMPOS
    INC num_motas
    JMP ADD_OK

CALC_ADD_CARR:
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
; ELIMINAR_VEICULO  (AL=0 carros, AL=1 motas)
;   idx_tmp = indice 0-based do veiculo a apagar
;   Desloca todos os veiculos seguintes uma posicao para tras
;   e decrementa o contador.
; ============================================================
ELIMINAR_VEICULO PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    PUSH DI

    MOV BL, idx_tmp
    MOV BH, 0

    CMP AL, 0
    JE EL_CARR

    ; --- Motas ---
    MOV AL, num_motas
    MOV AH, 0
    DEC AL                      ; ultimo indice valido
    CMP BL, AL
    JA EL_FIM                   ; indice >= num: nao faz nada (seguranca)

    ; SI = inicio do veiculo a apagar
    MOV AX, VEICULO_TAM
    MUL BX
    MOV SI, OFFSET arr_motas
    ADD SI, AX

    ; DI = proximo veiculo (o que vai substituir)
    MOV DI, SI
    ADD DI, VEICULO_TAM

    ; CX = numero de bytes a copiar = (num_motas - idx_tmp - 1) * VEICULO_TAM
    MOV AL, num_motas
    MOV AH, 0
    SUB AL, BL                  ; num_motas - idx_tmp
    DEC AL                      ; -1
    MOV AH, 0
    MOV BX, VEICULO_TAM
    MUL BX                      ; AX = bytes a copiar
    MOV CX, AX

    CMP CX, 0
    JE EL_ZERO_M
    ; copiar SI->DI (SI=fonte, DI=destino, CX=bytes) -- inverter pois REP MOVSB usa SI->DI
    ; aqui DI > SI por isso a copia directa esta correcta (sem overlap problematico)
    XCHG SI, DI                 ; SI=fonte (proximo), DI=destino (actual)
    REP MOVSB
    JMP EL_ZERO_M

EL_ZERO_M:
    ; Zerar o ultimo slot que ficou duplicado
    MOV AL, num_motas
    DEC AL
    MOV AH, 0
    MOV BX, VEICULO_TAM
    MUL BX
    MOV DI, OFFSET arr_motas
    ADD DI, AX
    MOV CX, VEICULO_TAM
    MOV AL, 0
    REP STOSB

    DEC num_motas
    JMP EL_OK

EL_CARR:
    ; --- Carros ---
    MOV AL, num_carros
    MOV AH, 0
    DEC AL
    CMP BL, AL
    JA EL_FIM

    MOV AX, VEICULO_TAM
    MUL BX
    MOV SI, OFFSET arr_carros
    ADD SI, AX

    MOV DI, SI
    ADD DI, VEICULO_TAM

    MOV AL, num_carros
    MOV AH, 0
    SUB AL, BL
    DEC AL
    MOV AH, 0
    MOV BX, VEICULO_TAM
    MUL BX
    MOV CX, AX

    CMP CX, 0
    JE EL_ZERO_C
    XCHG SI, DI
    REP MOVSB

EL_ZERO_C:
    MOV AL, num_carros
    DEC AL
    MOV AH, 0
    MOV BX, VEICULO_TAM
    MUL BX
    MOV DI, OFFSET arr_carros
    ADD DI, AX
    MOV CX, VEICULO_TAM
    MOV AL, 0
    REP STOSB

    DEC num_carros

EL_OK:
    LEA DX, msg_ok_del
    MOV AH, 09h
    INT 21h

EL_FIM:
    POP DI
    POP SI
    POP CX
    POP BX
    POP AX
    RET
ELIMINAR_VEICULO ENDP

; ============================================================
; PEDIR_IDX 
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
    MOV AH, 01h
    INT 21h

    CMP BL, '1'
    JB IDX_INV
    CMP BL, '5'
    JA IDX_INV

    SUB BL, '1'
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
; ============================================================
EDITAR_VEICULO PROC
    PUSH AX
    PUSH BX
    PUSH DI
    PUSH DX

    MOV BL, idx_tmp
    MOV BH, 0

    CMP AL, 0
    JE CALC_EDIT_CARR

    MOV AX, VEICULO_TAM
    MUL BX
    MOV DI, OFFSET arr_motas
    ADD DI, AX
    JMP EDIT_LOOP

CALC_EDIT_CARR:
    MOV AX, VEICULO_TAM
    MUL BX
    MOV DI, OFFSET arr_carros
    ADD DI, AX

EDIT_LOOP:
    MOV vei_base, DI

    LEA DX, msg_menu_edit
    MOV AH, 09h
    INT 21h

    MOV AH, 01h
    INT 21h
    MOV BL, AL
    MOV AH, 01h
    INT 21h

    CMP BL, '0'
    JE EDIT_FIM
    CMP BL, '1'
    JE ED_MARCA
    CMP BL, '2'
    JE ED_MODELO
    CMP BL, '3'
    JE ED_KMS
    CMP BL, '4'
    JE ED_ANO
    CMP BL, '5'
    JE ED_COR
    CMP BL, '6'
    JE ED_PRECO
    CMP BL, '7'
    JE ED_CIL
    LEA DX, msg_inv_op
    MOV AH, 09h
    INT 21h
    MOV DI, vei_base
    JMP EDIT_LOOP

ED_MARCA:
    MOV SI, vei_base
    LEA DX, msg_edit_atual
    MOV AH, 09h
    INT 21h
    CALL PRINT_CAMPO_SI_ONLY
    LEA DX, msg_nl
    MOV AH, 09h
    INT 21h
    LEA DX, prm_marca
    MOV AH, 09h
    INT 21h
    MOV DI, vei_base
    MOV BX, CAMPO_TAM
    CALL LER_CAMPO
    JMP ED_OK

ED_MODELO:
    MOV SI, vei_base
    ADD SI, OFF_MODELO
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
    ADD DI, OFF_MODELO
    MOV BX, CAMPO_TAM
    CALL LER_CAMPO
    JMP ED_OK

ED_KMS:
    MOV SI, vei_base
    ADD SI, OFF_KMS
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
    ADD DI, OFF_KMS
    MOV BX, CAMPO_TAM
    CALL LER_CAMPO
    JMP ED_OK

ED_ANO:
    MOV SI, vei_base
    ADD SI, OFF_ANO
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
    ADD DI, OFF_ANO
    MOV BX, CAMPO_TAM
    CALL LER_CAMPO
    JMP ED_OK

ED_COR:
    MOV SI, vei_base
    ADD SI, OFF_COR
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
    ADD DI, OFF_COR
    MOV BX, CAMPO_TAM
    CALL LER_CAMPO
    JMP ED_OK

ED_PRECO:
    MOV SI, vei_base
    ADD SI, OFF_PRECO
    LEA DX, msg_edit_atual
    MOV AH, 09h
    INT 21h
    CALL PRINT_PRECO_SI_ONLY
    LEA DX, msg_nl
    MOV AH, 09h
    INT 21h
    LEA DX, prm_preco
    MOV AH, 09h
    INT 21h
    MOV DI, vei_base
    ADD DI, OFF_PRECO
    MOV BX, PRECO_TAM
    CALL LER_CAMPO
    JMP ED_OK

ED_CIL:
    MOV SI, vei_base
    ADD SI, OFF_CIL
    LEA DX, msg_edit_atual
    MOV AH, 09h
    INT 21h
    CALL PRINT_CIL_SI_ONLY
    LEA DX, msg_nl
    MOV AH, 09h
    INT 21h
    LEA DX, prm_cil
    MOV AH, 09h
    INT 21h
    MOV DI, vei_base
    ADD DI, OFF_CIL
    MOV BX, CIL_TAM
    CALL LER_CAMPO
    JMP ED_OK

ED_OK:
    LEA DX, msg_ok_ed
    MOV AH, 09h
    INT 21h
    MOV DI, vei_base
    JMP EDIT_LOOP

EDIT_FIM:
    POP DX
    POP DI
    POP BX
    POP AX
    RET
EDITAR_VEICULO ENDP

END MAIN
