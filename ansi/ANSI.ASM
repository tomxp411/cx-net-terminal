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

.include "KERNAL.ASM"

; BASIC stub
* = $801
; BASIC header
.byte $0B,$08,$0A,$00,$CE,$90,$3A,$9E,$24,$38,$31,$30,$00,$00,$00

* = $810
main:
    jsr ansi_init

;     stz R1L
;     lda #4
;     sta R1H
; -   jsr ansi_cls
;     dec R1L
;     bne -
;     dec R1H
;     bne -
;     stp 

test_start:
    ldx start_pos
    ldy start_pos+1
    jsr locate

    lda #<str_test
    sta R0
    lda #>str_test
    sta R0+1

; Keeps printing text until we reach an empty string.
print_loop:
    jsr ansi_print_str
-   jsr getin
    beq -

    lda (R0)
    bne print_loop
done:
    jsr ansi_cls
    jmp test_start

    ; if we ever get here, something has failed
    brk

; end of program (easy to see in MONitor)
.byte 0,0,0,0

; Test strings
;.enc "screen"
start_pos:
    .byte 5,10
str_test:
    .text "|ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQ|",0

str_test_home:
    ; clear the screen before we get started
    .text 27,"[H"
    .text "1",$0D,$0A
    .text "2",$0D,$0A
    .text "3",$0D,$0A
    .text "4",$0D,$0A
    .text "5",$0D,$0A
    .text "6",$0D,$0A
    .text "7",$0D,$0A
    .text "8",$0D,$0A
    .text "9",$0D,$0A
    .text "10",$0D,$0A
    .text 27,"[H",$c5," HOME POSITION",$0D,$0A
    .text 27,"[30;40H",$c5," Row 30 Col 40",$0d,$0a
    .text 27,"[60;65H",$c5," Row 60 Col 65",$0d,$0a
    .text 27,"[4;2H",$c5," Row 4 Col 2",$0d,$0a
    .byte 0

    .text 27,"[2J"
    .text 27,"[10HBad escape code tests:",13,10,0
    .text 27,"H missing [ in escape code",$0d,$0a,0
    .text 27,"[Z invalid command in escape code",$0d,$0a,0

    .text 27,"[2J"
    .text 27,"[H"
    .text "1",$0D,$0A
    .text "2",$0D,$0A
    .text "3",$0D,$0A
    .text "4",$0D,$0A
    .text "5",$0D,$0A
    .text "6",$0D,$0A
    .text "7",$0D,$0A
    .text "8",$0D,$0A
    .text "9",$0D,$0A
    .text ".........1.........2.........3.........4.........5.........6.........7.........8"
    .text "11",$0D,$0A
    .text ".........1.........2.........3.........4.........5.........6.........7.........8"
s   .text "13",$0D,$0A
    .text "14",$0D,$0A
    .text "15",$0D,$0A
    .text "16",$0D,$0A
    .text "17",$0D,$0A
    .text "18",$0D,$0A
    .text "19",$0D,$0A
    .text ".........1.........2.........3.........4.........5.........6.........7.........8"
    .text 27,"[11;16HErasing cursor to end ->xxx"
    .text 27,"[11;40H[This text should disappear]",0
    .text 27,"[11;40H"
    .text 27,"[0J"
    .text 0

    .text 27,"[H"
    .text "1",$0D,$0A
    .text "2",$0D,$0A
    .text "3",$0D,$0A
    .text "4",$0D,$0A
    .text "5",$0D,$0A
    .text "6",$0D,$0A
    .text "7",$0D,$0A
    .text "8",$0D,$0A
    .text "9",$0D,$0A
    .text ".........1.........2.........3.........4.........5.........6.........7.........8"
    .text 27,      "[11;40H<- Erasing to cursor",0

    .text 27,"[11;40H"
    .text 27,"[1J"
    .text 0

    .text 27,"[30;31HErase full screen",0
    .text 27,"[2J"
    .text 27,"[31;33HScreen cleared",0

    .text 27,"[2;2HPress a key to restart test"

    ; end of data segment
    .byte 0,0,0,0

.include "TERM_ANSI.ASM"
