;
; vera.asm
; 
; Routines for displaying text on the VERA video adapter for Commander X16
; commanderx16.com
;

ScrnAdr = $B000  ; Address of screen buffer in VERA

; VERA constants
vera_addr0 = $9f20    ; low byte of display address (col)
vera_addr1 = $9f21    ; middle byte of display address (row)
vera_addr2 = $9f22    ; high byte of display address (bank + increment)
vera_data0 = $9f23    ; VERA data port 0
vera_data1 = $9f24    ; VERA data port 1
vera_dcsel = $9f25    ; VERA data select register

jsrfar = $FF6E

bank_select_ram = $00
bank_select_rom = $01

bank_audio = $0A
ym_init = $C063
bas_fmnote = $C003
bas_fmfreq = $c000
bas_psgfreq = $c00f
ym_loadpatch = $c069

; Zero page registers
R0      = $02
R0L     = $02
R0H     = $03
R1      = $04
R1L     = $04
R1H     = $05
R2      = $04
R2L     = $04
R2H     = $05

ansi_strptr   = R0  ; string pointer for prints procedure

incr16 .macro 
        inc \1
        bne +
        inc \1+1
    +
.endmacro

; sets up the callback
; loads the ANSI character set
; sets ISO mode
ansi_init:
    lda #15     ; ISO mode PETSCII character
    jsr $FFD2   ; print it

    ; set ANSI character set
    lda #7
    jsr $ff62 ; screen_set_charset    

    ; initialize audio system for the Bell tone
    jsr jsrfar  ; $FF6E
    .word ym_init ; $C063
    .byte bank_audio

    ldx #$0d
    sec
    jsr jsrfar
    .word ym_loadpatch
    .byte bank_audio
    rts 

;
; Sets the cursor position
; coordinates are zero based (fits with VERA addressing)
; .X Column (0-79)
; .Y Row (0-59)
; Modifies: none
locate:
    pha
    jsr csr_blink_off
    stx csr_col 
    sty csr_row
    jsr load_addr_vector
    pla
    rts

; 
; Sets the VERA address vector to the current cursor position
; Row should be in Row variable
; Col should be in csr_col variable
; modifies .A .P
;
load_addr_vector:
    stz vera_dcsel        ; work with data port 0
    lda csr_col
    asl A
    sta vera_addr0
    lda csr_row
    clc
    adc csr_base
    sta vera_addr1
    lda csr_bank
    sta vera_addr2
    rts

; 
; Sets the VERA address vector to the current cursor position
; Row should be in Row variable
; Col should be in csr_col variable
; modifies .A .P
;
save_addr_vector:
    stz vera_dcsel        ; work with data port 0
    lda vera_addr0
    lsr A
    sta csr_col
    lda vera_addr1
    sec
    sbc csr_base
    sta csr_row
    rts

; Print a null-terminated string
; ansi_strptr: string address
; modifies ansi_strptr .A .X .Y Flags
;   ansi_strptr will be left at the address after the null terminator
;   so you can just call prints again to print another string.
ansi_print_str:
    jsr load_addr_vector
prints_loop:
    lda (ansi_strptr)
    beq prints_done
    jsr chrout
    .incr16 ansi_strptr
    bra prints_loop
prints_done:
    .incr16 ansi_strptr
    ;jsr save_addr_vector
    rts

; Print a character to the screen 
; Intercepts and stores any ANSI terminal sequences
; .A character to print
; modifies .A .X .Y flags
; stack: 3
chrout:
    ;debug
    ;jmp just_print
    ;/debug

    ; first, test to see if we're in terminal parameter mode
    ; param_count will be > 0
    ldy param_count
    cpy #cmd_max
    cpy #1
    beq chrout_read_param
    bcc +
    jmp chrout_test_semi

    ; look for a control character
+   cmp #' '
    bcc do_control_char

; This actually prints the character to the screen
; pretty simple after all that other stuff, eh?
just_print:
    sta vera_data0
    lda cur_color   ; get the current color
    sta vera_data0
    inc csr_col     ; moves cursor to the right one position

; Check the cursor column and row
; ANSI does not wrap by default. The last character printed overwrites the 
; character at the last column.
; (todo) Scroll text up if cursor is past the bottom of the screen
check_bounds:
    lda csr_col
    cmp col_count
    bcc check_row
    ;stz csr_col
    lda col_count
    dec A
    sta csr_col
    ;inc csr_row
    jsr load_addr_vector
check_row:
    lda csr_row
    cmp row_count
    bcc check_done
    lda csr_row
    sec
    sbc #$01
    sta csr_row
    jsr load_addr_vector
check_done:
chrout_done:
    rts 

do_control_char:
    cmp #$1B ; ESC
    bne +
    inc param_count
    jmp chrout_done

+   cmp #$0A ; Line Feed
    bne +
    inc csr_row
    jsr load_addr_vector
    jmp check_bounds

+   cmp #$0D ;CR
    bne +
    stz csr_col
    jsr load_addr_vector
    jmp check_bounds

+   cmp #$07 ; bell
    bne +
    jmp do_bell

+   cmp #$08 ; backspace
    bne +
    jmp do_bs

+   cmp #$09 ; tab
    bne +
    jmp do_tab

+   jmp just_print

chrout_read_param:
    cmp #'['
    bne +
    inc param_count
    jmp chrout_done

+   ; not a known escape sequence
    stz param_count
    jmp just_print

chrout_test_semi:
    cmp #';'
    bne chrout_test_number
    lda #$03
    sta param_count
    jmp chrout_done

chrout_test_number:
    ; test for number and store in the parameter variable
    cmp #'0'
    bcc chrout_not_number
    cmp #'9'+1
    bcs chrout_not_number
    ; value is >=0 and <=9 so it's a number

    ; get the numeric value of the digit and save it
    sec
    sbc #'0'
    sta digit_1

    ; multiply by 10
    lda param_count,Y
    asl
    asl
    asl
    sta mult_1
    lda param_count,Y
    asl
    clc
    adc mult_1
    adc digit_1
    sta param_count,Y

    jmp chrout_done
chrout_not_number:
    jmp do_CSI

; execute a terminal command
do_CSI:
    ; Home (set cursor location)
    cmp #'H'
    beq do_CUP
    cmp #'f'
    beq do_CUP

    cmp #'J'
    beq do_ED

    cmp #'K'
    beq do_EL

    ; if a bad escape code is encountered, skip
    jmp cmd_done

; Cursor Position
do_CUP:
    ldx param_2
    beq +
    dex
+   ldy param_1
    beq +
    dey
+   jsr locate
    jmp cmd_done

; Erase Line
do_EL:
    ; 0=cursor to end of  line
    lda param_1
    bne +

    ; copy cursor location to start_addr
    lda csr_col
    sta start_col
    lda csr_row
    sta start_row

    ; copy end of line to end_addr
    lda col_count
    dec a
    sta end_col
    lda csr_row
    sta end_row

    jmp do_erase

    ; 1=beginning of line to cursor
+   cmp #1
    bne +

    ; copy start of line to start address
    stz start_col
    lda csr_row
    sta start_row
    ; copy cursor location to end addr
    lda csr_col
    sta end_col
    lda csr_row
    sta end_row
    jmp do_erase
    
    ; 2=clear entire line
+   cmp #2
    bne +

    ; copy start of line to start address
    stz start_col
    lda csr_row
    sta start_row
    ; copy end of line to end address
    lda col_count
    sta end_col
    lda csr_row
    sta end_row
    jmp do_erase

; Erase Display
do_ED:
    lda param_1
    ; 0=cursor to end of screen
    bne +

    ; copy cursor location to start_addr
    lda csr_col
    sta start_col
    lda csr_row
    sta start_row

    ; copy end of screen to end_addr
    lda col_count
    sta end_col
    lda row_count
    dec a
    sta end_row

    jmp do_erase

    ; 1=beginning screen to cursor
+   cmp #1
    bne +

    ; copy start of screen to start addr
    stz start_col
    stz start_row

    ; copy cursor location to end addr
    lda csr_col
    sta end_col
    lda csr_row
    sta end_row

    jmp do_erase
    
    ; 2=clear entire screen
+   cmp #2
    bne +

ansi_cls:
    ; copy start of screen to start addr
    stz start_col
    stz start_row

    ; copy end of screen to end_addr
    lda col_count
    dec a
    sta end_col
    lda row_count
    dec a
    sta end_row

    jmp do_erase

    ; invalid argument
+   jmp cmd_done

; Erase one or more lines on screen
; start_row, start_col: the first position to delete
; end_row, end_col: the last position to delete
; first row: erases after start_col to end of line
; betweenrows: erases entire line
; last row: erases start of line up to end_col
do_erase:
    ; data to load into VERA
    ldx cur_char    
    ldy cur_color   

erase_first_line:
    ; set start address
    stz vera_dcsel  
    lda start_col
    asl             
    sta vera_addr0  
    lda work_row    
    clc             
    adc csr_base    
    sta vera_addr1  
    lda csr_bank    
    sta vera_addr2  
    
    lda end_col     ; number of rows to clear
    sec
    sbc start_col
    inc a

    ; fill one row with space and current color
    ; VERA should be set to the starting ddress
    ; .A columns to delete
erase_fill_line:
    stx vera_data0      
    sty vera_data0      
    dec a               
    bne erase_fill_line 
    jsr do_callback  ; give serial driver the chance to empty the FIFO

    ; set address to start of next row
    stz vera_addr0
    inc vera_addr1

    ; check for last line
    ; or end of operation
    inc work_row
    lda work_row
    cmp end_row
    beq erase_last_line
    bcs erase_done 
    lda col_count ; number of columns to delete
    bra erase_fill_line    

erase_last_line:
    lda end_col ; for Erase Line, only erase up to cursor
    inc a
    bra erase_fill_line

erase_done:
    jmp cmd_done

do_bell:
    lda #bank_audio
    sta bank_select_rom

    ; Trigger a note on the YM chip. 
    lda #$00 ; channel 0
    ldx #$00 ; 512 Hz
    ldy #$02 ; 
    clc
    ; initialize audio system for the Bell tone
    jsr jsrfar  ; $FF6E
    .word bas_fmfreq ; $C063
    .byte bank_audio
    jmp cmd_done

do_bs:
    lda csr_col
    beq +
    dec A
    sta csr_col
    jsr load_addr_vector
+   jmp cmd_done        

; move the cursor to the next tab stop. The first non-zero value is a tab
do_tab:
    ldx csr_col
    dex
-   inx
    lda tab_stops,X
    bpl -
    stx csr_col
    jsr load_addr_vector
    jmp cmd_done

do_callback:
    ; this jumps into user code, allowing the user to pull from the serial 
    ; buffer during a long screen operation (Clear, Scroll). User must preserve
    ; .A .X .Y
    ; be sure to JSR to this routine, and the user must RTS at the end of their
    ; code. So the RTS will return to whatever called this routine.
    jmp (callback_addr)

empty_callback:
    RTS

; Reset the terminal sequence buffer after a terminal command
; if carry is set, prints the character in .A
; if carry is clear, just exits
cmd_done:
    ; reset the parameters to 0 for next time.
    stz param_count
    stz param_0
    stz param_1
    stz param_2
    jmp chrout_done

csr_blink_off:
    ; restore the saved value to the cursor position
    rts

csr_blink_on:
    ; save the attribute at the cursor position and invert the color
    ;todo
    rts

csr_blink:
    ; reverse the state of the character at the cursor position
    ;todo
    rts

csr_blink_reset:
    ; blinks the cursor on
    ; resets the blink timer
    ;todo
    rts

csr_blink_wait:
    ; checks the clock and blinks if 1/2 second has passed
    ;todo
    rts

csr_hide:
    ; hides the cursor until csr_show has been called
    ;todo
    rts

csr_show:
    ; shows the cursor 
    ;godo
    rts

; Data segment

; cursor location is in character coordinates
; and is converted to memory coordinates in load_addr_vector
csr_col:       .byte $00  ; column number (addr bits 0-7)
csr_row:       .byte $00  ; row number (addr bits 8-15)
csr_bank:       .byte $11 ; auto-increment and addr bit 16.
csr_base:      .byte $b0  ; base address of screen buffer

cur_color:      .byte $01 ; currrent color attribute
cur_char:       .byte ' ' ; fill character for clear screen

col_count:    .byte 80 ; default screen width  
row_count:    .byte 60 ; default screen height

bank_rom_save:  .byte 0 ; perserve the current ROM bank
bank_ram_save:  .byte 0 ; preserve the current RAM bank

cmd_max = 4
param_count .byte 0     ; >0 if parsing a terminal sequence
param_0     .byte 0     ; [ or pain non-CSI command
param_1     .byte 0     ; first parameter in CSI
param_2     .byte 0     ; second parameter in CSI
digit_1     .byte 0     ; character being processed

; variables

incr_col:
start_col:              ; start col for erase/scroll (0-79)
work_col:     .byte 0  ; current col for erase/scroll (0-79)
start_row:              ; start row for erase/scroll (0-59)
work_row:     .byte 0  ; current row for erase/scroll (0-59)
end_col:      .byte 0  ; end col for erase/scroll (0-79)
end_row:      .byte 0  ; end row for erase/scroll (0-59)
mult_1:       .byte 0   ; temp slot for multiplication
mult_2:       .byte 0   ; temp slot for multiplication

; cursor blink state
cbs_next:   .word 0     ; the next time the cursor should blink
cbs_blink:  .byte 0     ; Bitmask
                        ; $01 = cursor is blinked on
                        ; $02 = cursor enabled

; one byte per column. Since the screen has 128 virtual columns, 130 spaces
; are provided. 
; The high bit denotes a tab in that column.
tab_stops:  .byte 0,0,0,0,0,0,0,0,0,$80
            .byte 0,0,0,0,0,0,0,0,0,$80
            .byte 0,0,0,0,0,0,0,0,0,$80
            .byte 0,0,0,0,0,0,0,0,0,$80
            .byte 0,0,0,0,0,0,0,0,0,$80
            .byte 0,0,0,0,0,0,0,0,0,$80
            .byte 0,0,0,0,0,0,0,0,0,$80
            .byte 0,0,0,0,0,0,0,0,0,$80
            .byte 0,0,0,0,0,0,0,0,0,$80
            .byte 0,0,0,0,0,0,0,0,0,$80
            .byte 0,0,0,0,0,0,0,0,0,$80
            .byte 0,0,0,0,0,0,0,0,0,$80
            .byte 0,0,0,0,0,0,0,0,  $FF,$FF

; this address is called at the end of each row when the screen is being
; scrolled or cleared (or any other long operation)
callback_addr:
            .word empty_callback
