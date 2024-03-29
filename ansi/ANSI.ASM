;
; ANSI.ASM
;
; Test ANSI driver for Commander X16
;
; This just contains some ANSI text strings and a program to display the strings
; with the appropriate ANSI escape code actions.
;

.cpu "w65c02"
;.cpu "65816" 

; BASIC stub
* = $801
; BASIC header
.byte $0B,$08,$0A,$00,$CE,$90,$3A,$9E,$24,$38,$31,$30,$00,$00,$00

; Zero page registers
R0      = $02
R0L     = $02
R0H     = $03
R1      = $04
R1L     = $04
R1H     = $05

StrAddr = $02    ; R0  address of string to print

* = $810
start:

print_str:
    ldx start_pos
    ldy start_pos+1
    jsr locate

    ldx #0
    jsr load_addr_vector
print_loop:
    lda str_test,x
    beq print_done
    jsr chrout
    inx
    bra print_loop
print_done:
    bra print_done
    brk
    brk
    brk

; Test strings
;.enc "screen"
start_pos:
    .byte 10,32
str_test:
    .text "ROW 10 COL 32",0

str_test_home:
    .text 27,"[H"
    .text "HOME POSITION"
    .byte 0

.include "TERM_ANSI.ASM"
