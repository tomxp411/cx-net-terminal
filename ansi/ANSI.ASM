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

test_start:
    ; get start of test strings
    lda #<str_test
    sta R0
    lda #>str_test
    sta R0+1

; Keeps printing text until we reach an empty string.
print_loop:
    lda (R0)
    cmp #$01
    bne +
    jsr draw_test
+   cmp #26 ; end of file marker
    beq done

print_test:
    jsr ansi_print_str

wait_for_key:
-   jsr getin
    beq -
    bra print_loop

; prints the test grid, with column and row headers
draw_test:
    lda R0L
    pha
    lda R0H
    pha

    lda #<test_grid
    sta R0L
    lda #>test_grid
    sta R0H
    jsr ansi_print_str

    pla
    sta R0H
    pla
    sta R0L

    inc R0L
    bne +
    inc R0H
+   rts

done:
    jmp test_start

    ; if we ever get here, something has failed
    brk

; end of program (easy to see in MONitor)
.byte 0,0,0,0

press_key_text:
    .text "[Press Any Key]",0

test_grid:
    .text 27,"[2J",27,"[2H",27,"[36m"
    .text "....,....1....,....2....,....3....,....4....,....5....,....6....,....7....,....8"
    .text 27,"[19H"
    .text "....,....1....,....2....,....3....,....4....,....5....,....6....,....7....,....8"
    .text 27,"[21H"
    .text "....,....1....,....2....,....3....,....4....,....5....,....6....,....7....,....8"
    .text 27,"[60;70H"
    .text "7....,....8"
    .text 27,"[H"
    .text "1", $0d,$0a,"2", $0d,$0a,"3", $0d,$0a,"4", $0d,$0a,"5", $0d,$0a
    .text "6", $0d,$0a,"7", $0d,$0a,"8", $0d,$0a,"9", $0d,$0a,"10",$0d,$0a
    .text "11",$0d,$0a,"12",$0d,$0a,"13",$0d,$0a,"14",$0d,$0a,"15",$0d,$0a
    .text "16",$0d,$0a,"17",$0d,$0a,"18",$0d,$0a,"19",$0d,$0a,"20",$0d,$0a
    .text "21",$0d,$0a,"22",$0d,$0a,"23",$0d,$0a,"24",$0d,$0a,"25",$0d,$0a
    .text "26",$0d,$0a,"27",$0d,$0a,"28",$0d,$0a,"29",$0d,$0a,"30",$0d,$0a
    .text "31",$0d,$0a,"32",$0d,$0a,"33",$0d,$0a,"34",$0d,$0a,"35",$0d,$0a
    .text "36",$0d,$0a,"37",$0d,$0a,"38",$0d,$0a,"39",$0d,$0a,"40",$0d,$0a
    .text "41",$0d,$0a,"42",$0d,$0a,"43",$0d,$0a,"44",$0d,$0a,"45",$0d,$0a
    .text "46",$0d,$0a,"47",$0d,$0a,"48",$0d,$0a,"49",$0d,$0a,"50",$0d,$0a
    .text "51",$0d,$0a,"52",$0d,$0a,"53",$0d,$0a,"54",$0d,$0a,"55",$0d,$0a
    .text "56",$0d,$0a,"57",$0d,$0a,"58",$0d,$0a,"59",$0d,$0a,"60"
    .text 27,"[H",27,"[0m"
    .byte 0

; Test strings
str_test:
    ;.byte 0 ends a text string. This is required for ansi_print_str
    ;.byte 1 tells the test rig to clear the screen and draw the rulers
    ;   as it's part of the test rig and not the driver, it can only be
    ;   used as the first character in a text string.
    
    ; CR and LF test
    .text 27,"[2J",27,"[H"
    .text 27,"[2;4H"
    ;.text 27,"[39m"
    .text "ANSI Control and Escape Code Demo",$0d,$0a,$0a,$0a
    .text "This will run several test sequences.",$0d,$0a
    .text "After each sequence, the test will pause.",$0d,$0a
    .text "Text on the screen should tell you how",$0d,$0a
    .text "to interpret each test.",$0d,$0a,$0a
    .text "For example:",$0d,$0a
    .text "....,....1....,....2",$0d,$0a
    .text "    x [x is on column 5]",$0d,$0a
    .text $0d,$0a
    .text "If the x is on column 5, then the test passes.",$0d,$0a
    .byte 10,$0a
    .text "After confirming each test, press a key",$0d,$0a
    .text "for the next test.",$0d,$0a
    .text $0a,$0a
    .text "[Press a key]"
    .byte 0

    .text 27,"[2J",27,"[1;15H"
    .text 27,"[97mColor Test",13,10,10
    .text 27,"[0m"
    .text 27,"[37m37 WHITE    ",27,"[1m1 BOLD  ",13,10
    .text 27,"[36m36 CYAN     ",27,"[1m1 BOLD  ",13,10
    .text 27,"[35m35 MAGENTA  ",27,"[1m1 BOLD  ",13,10
    .text 27,"[34m34 BLUE     ",27,"[1m1 BOLD  ",13,10
    .text 27,"[33m33 YELLOW   ",27,"[1m1 BOLD  ",13,10
    .text 27,"[32m32 GREEN    ",27,"[1m1 BOLD  ",13,10
    .text 27,"[31m31 RED      ",27,"[1m1 BOLD  ",13,10
    .text 27,"[44m"
    .text 27,"[30m30 BLACK    ",27,"[1m1 BOLD  ",13,10
    .text 27,"[49m"

    .text $0a,$0a
    .text 27,"[39m39 DEFAULT (white on black)",13,10

    .text $0a,$0a
    .text 27,"[97m97 BRT WHITE",13,10
    .text 27,"[96m96 BRT CYAN",13,10
    .text 27,"[95m95 BRT MAGENTA",13,10
    .text 27,"[94m94 BRT BLUE",13,10
    .text 27,"[93m93 BRT YELLOW",13,10
    .text 27,"[92m92 BRT GREEN",13,10
    .text 27,"[91m91 BRT RED",13,10
    .text 27,"[90m90 BRT BLACK",13,10

    .text $0a,$0a
    .text 27,"[30;47m47 BG WHITE   ",27,"[49m",13,10
    .text 27,"[30;46m46 BG CYAN    ",27,"[49m",13,10
    .text 27,"[30;45m45 BG MAGENTA ",27,"[49m",13,10
    .text 27,"[30;44m44 BG BLUE    ",27,"[49m",13,10
    .text 27,"[30;43m43 BG YELLOW  ",27,"[49m",13,10
    .text 27,"[30;42m42 BG GREEN   ",27,"[49m",13,10
    .text 27,"[30;41m41 BG RED     ",27,"[49m",13,10
    .text 27,"[90;40m40 BG BLACK   ",27,"[49m",13,10

    .text $0a,$0a
    .text 27,"[39m39 DEFAULT (white on black)",13,10

    .text $0a,$0a
    .text 27,"[37m[",27,"[93mA",27,"[37m]",27,"[32m Menu Item Test",13,10
    .text 27,"[0m0 RESET",13,10
    .byte 0

    .text 27,"[97m"
    .text 27,"[2J",27,"[HCursor movement test",13,10,10,10
    .text 27,"[31m"
    .text 27,"[5HCUU >",27,"[A< Up one line",13,10,10,10
    .text 27,"[5;30HCUU 1 >",27,"[1A< Up 1 line",13,10,10,10
    .text 27,"[5;60HCUU 2 >",27,"[2A< Up 2 lines",13,10
    .text 27,"[32m"
    .text 27,"[10HCUD >",27,"[B< Down one line",13,10,10
    .text 27,"[10;30HCUD 1 >",27,"[B< Down one line",13,10,10
    .text 27,"[10;60HCUD 2 >",27,"[2B< Down 2 lines",13,10,10

    .text 27,"[33m"
    .text 27,"[15HCUF >",27,"[C< One space gap",13,10,10
    .text "CUF 1 >",27,"[C< One space gap",13,10,10
    .text "CUF 2 >",27,"[2C< 2 space gap",13,10,10
    .text 27,"[36m"
    .text "CUB >X",27,"[D< Should be no gap and no X",13,10,10
    .text "CUB 1 >X",27,"[1D< Should be no gap and no X",13,10,10
    .text "CUB 2 >XX",27,"[2D< Should be no gap and no X",13,10,10
    .byte $0a,$0a
    .byte 0


    .byte 1
    .text 27,"[2J"
    .text 27,"[H"
    .text 27,"[0m"
    .text "Control character test",$0d,$0a,$0a
    .text "$07 BELL: Play a tone",$0d,$0a
    .text $07,"Ding [Pass if you heard a 'ding' sound.]",$0d,$0a
    .byte $0a,$0a
    .byte 0

    .text "$08 BS: Backspace",$0d,$0a
    .text "Backspace test [should say 'pass' twice]: failpass"
    .text $08,$08,$08,$08,$08,$08,$08,$08,"pass",$0d,$0a
    .byte $0a,$0a
    .byte 0

    .text "$09 HT: Horizontal tab",$0d,$0a
    .text "         |         |         |         |",$0d,$0a
    .text "bars",9,"|should",9,"|line",9,"|up",9,"|",$0d,$0a
    .byte $0a,$0a
    .byte 0
    ; LF \
    ;     \ this line should be one down, one right
    .text "$10 LF: moves the cursor down one line",$0d,$0a
    .text "Line 1 ",$5C,$0a
    .text         $5C," Line 2",$0d,$0a
    .text "The backslashes should line up."
    .text $0d,$0a,$0a
    .byte 0
    .text "$13 CR: move to start of line",$0d,$0a,$0a
    ; CR TEST -><- CR TEST [should be on same line]
    .text "          <- CR TEST [should be on same line]",$0d 
    .text "CR TEST ->",$0D,$0A
    .byte $0a,$0a
    .byte 0 

    ; Position test
    .byte 1
    .text 27,"[H",$c5," HOME POSITION",$0D,$0A
    .byte 0,1
    .text 27,"[20;40H",$c5," Row 20 Col 40",$0d,$0a
    .byte 0,1
    .text 27,"[60;80H",$c5
    .text 27,"[60;65HRow 60 Col 80"
    .byte 0,1
    .text 27,"[4;5H",$c5," Row 4 Col 5",$0d,$0a
    .byte 0,1
    .text 27,"[10H+ Line 10, column 1 (no column)"
    .byte 0,1
    .text 27,"[;40H+ Col 40 (no row)  "
    .byte 0

    ; no-wrap test
    .text 27,"[2J",27,"[H"
    .text 27,"[2;65HNo-wrap test. -[Not visible]>"
    .text 27,"[3HNo-Wrap test: > char should be on",$0d,$0A
    .text "right edge and [Not visible] should not",$0d,$0a
    .text "be visible.",$0d,$0a
    .byte 0

    .text 27,"[2J"
    .text 27,"[H"
    .text 27,"Bad escape code tests:",$0d,$0a
    .text 27,"H missing [ in escape code",$0d,$0a
    .text 27,"[Z invalid command in escape code",$0d,$0a
    .byte 0

    ; erase display test
    .byte 1
    .text 27,"[20;20H"
    .text 27,"[33m"
    .text "ED  cursor to end ->"
    .text 27,"[20;40H"
    .text 27,"[90m"
    .text "[This text should disappear]"
    .byte 0
    .text 27,"[20;40H"
    .text 27,"[0J"
    .byte 0

    .byte 1
    .text 27,"[20;17H"
    .text 27,"[90m"
    .text "[This should disappear]"
    .text 27,"[33m"
    .text 27,"[20;40H"
    .text "<- ED start to cursor",$0D,$0A
    .text 27,"[60;54H"
    .text "This should remain visible."
    .byte 0
    .text 27,"[20;39H"
    .text 27,"[1J"
    .byte 0

    .text 27,"[2J"
    .text 27,"[10;27H   Erase full screen"
    .text 27,"[11;27H Screen should be clear"
    .text 27,"[12;27H[Aside from this message]"
    .byte 0

    .byte 1
    ; erase line tests
    .text 27,"[20;10H"
    .text 27,"[33m"
    .text "EL cursor to to end of line ->"
    .text 27,"[20;40H"
    .text 27,"[90m"
    .text "[This text should disappear]"
    .byte 0
    .text 27,"[20;40H"
    .text 27,"[0K"
    .byte 0

    .text 27,"[20;10H"
    .text 27,"[90m"
    .text "  This text should disappear ->"
    .text 27,"[20;41H"
    .text 27,"[33m"
    .text "<- EL start to cursor"
    .byte 0
    .text 27,"[20;40H"
    .text 27,"[1K"
    .byte 0

    .text 27,"[20H"
    .text 27,"[36m"
    .text "....,....1....,....2....,....3....,....4....,....5....,....6....,....7....,....8"
    .text 27,"[20;18H"
    .text 27,"[33m"
    .text "[EL entire line. This text should disappear]"
    .byte 0
    .text 27,"[20;10H"
    .text 27,"[2K"
    .byte 0

    .byte 1
    .text 27,"[29;27HPress a key to restart test"
    .byte 0

    ; end of data segment
    .byte 26,0,0,0,0

.include "ANSI_DRIVER.ASM"
