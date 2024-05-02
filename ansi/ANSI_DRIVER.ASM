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

colors_bank = $11   ;incr=1, bank=1
colors_addr = $FA00
default_color_fg = $07
default_color_bg = $00

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
; alters .A .X .Y Flags
ansi_init:
    lda #15     ; ISO mode PETSCII character
    jsr $FFD2   ; print it

    ; set ANSI character set
    lda #7
    jsr $ff62 ; screen_set_charset    


    ; set VERA 
    lda #<colors_addr
    sta vera_addr0
    lda #>colors_addr
    sta vera_addr1
    lda #colors_bank
    sta vera_addr2

    ; load the palette
    ldx #0
-   lda palette_data, x
    sta vera_data0
    inx
    cpx #palette_end - palette_data
    bcc -

    stz cur_mode        ; reset colors and attributes
    lda #default_color_fg  ; default color is white on black
    sta cur_color

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
ansi_locate:
    pha
    stx csr_col 
    sty csr_row
    jsr load_addr_vector
    pla
    rts

;
; Sets the VERA address for a screen position.
; Sets ADDR0 (address for vera_data0)
; coordinates are zero based (fits with VERA addressing)
; ADDR0:
;   start_col: column
;   start_row: row
;   csr_bank: increment, bank bit
; Modifies: .A
;
vera_set_address_0:
    stz vera_dcsel        ; work with data port 0
    lda start_col
    asl A
    sta vera_addr0
    lda start_row
    clc
    adc csr_base
    sta vera_addr1
    lda csr_bank
    sta vera_addr2
    rts

;
; Sets the VERA address for a screen position.
; Sets ADDR1 (address for vera_data1)
; coordinates are zero based (fits with VERA addressing)
; ADDR1:
;   start_col: column
;   dest_row: row
;   csr_bank: increment, bank bit
; Modifies: .A
;
vera_set_address_1:
    lda #$01
    sta vera_dcsel        ; work with data port 0
    lda start_col
    asl A
    sta vera_addr0
    lda start_row2
    clc
    adc csr_base
    sta vera_addr1
    lda csr_bank
    sta vera_addr2
    stz vera_dcsel
    rts

; 
; Sets the VERA address vector to the current cursor position
; Row should be in Row variable
; Col should be in csr_col variable
; modifies .A Flags
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
; modifies .A Flags
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
    jsr ansi_chrout
    .incr16 ansi_strptr
    bra prints_loop
prints_done:
    .incr16 ansi_strptr
    rts

; Print a character to the screen 
; Intercepts and stores any ANSI terminal sequences
; .A character to print
; modifies .A .X .Y flags
; stack: 3
ansi_chrout:
    ;debug
    ;jmp just_print
    ;/debug

    ; first, test to see if we're in terminal parameter mode
    ; param_index will be > 0
    ldy param_index
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
check_bounds:
    lda csr_col
    cmp col_count
    bcc check_row
    ;stz csr_col
    lda col_count
    dec A
    sta csr_col
check_row:
    lda csr_row
    sec
    sbc row_count
    bcc check_done
    inc a
    ; .A should now have the number of rows we overran the screen
    jsr do_scroll_up
    lda row_count
    dec a
    sta csr_row
check_done:
    jsr load_addr_vector
chrout_done:
    rts 

do_control_char:
    cmp #$1B ; ESC
    bne +
    inc param_index
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
    inc param_index
    jmp chrout_done

+   ; not a known escape sequence
    stz param_index
    jmp just_print

chrout_test_semi:
    cmp #';'
    bne chrout_test_number
    inc param_index
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
    lda parameters,Y
    asl
    asl
    asl
    sta mult_1
    lda parameters,Y
    asl
    clc
    adc mult_1
    adc digit_1
    sta parameters,Y

    jmp chrout_done
chrout_not_number:
    jmp do_CSI

; execute a terminal command
do_CSI:
    ; Home (set cursor location)
    cmp #'A'
    beq do_CUU

    cmp #'B'
    beq do_CUD
    
    cmp #'C'
    beq do_CUF
    
    cmp #'D'
    beq do_CUB

    cmp #'f'
    beq do_CUP

    cmp #'H'
    beq do_CUP
    
    cmp #'J'
    bne +
    jmp do_ED
+
    cmp #'K'
    beq do_EL

    cmp #'m'
    bne +
    jmp do_SGR
+    
    ; if a bad escape code is encountered, skip
    jmp cmd_done

do_CUU:
    lda param_1
    beq +
    lda csr_row
    sec
    sbc param_1
    sta csr_row
    jmp cmd_done
+   dec csr_row
    jmp cmd_done    

do_CUD:
    lda param_1
    beq +
    lda csr_row
    clc
    adc param_1
    sta csr_row
    jmp cmd_done
+   inc csr_row
    jmp cmd_done    

do_CUF:
    lda param_1
    beq +
    lda csr_col
    clc
    adc param_1
    sta csr_col
    jmp cmd_done
+   inc csr_col
    jmp cmd_done

do_CUB:
    lda param_1
    beq +
    lda csr_col
    sec
    sbc param_1
    sta csr_col
    jmp cmd_done
+   dec csr_col
    jmp cmd_done    

; Cursor Position
do_CUP:
    ldx param_2
    beq +
    dex
+   ldy param_1
    beq +
    dey
+   jsr ansi_locate
    jmp cmd_done

;---------------------------------------------------------------------------
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
;------------------------------------------------

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

; Set Graphic Rendition: colors, bold, etc.
do_SGR:
    ldx #2
sgr_loop:    
    lda parameters, x

    bne +         ;0: reset all modes, styles, and colors
    stz cur_mode
    lda #default_color_fg
    sta cur_color
    jmp sgr_next

+   cmp #30     
    bcs sgr_30
    
    cmp #1  ; bold
    bne +
    lda cur_color
    ora #$08
    sta cur_color
    jmp sgr_next 

+   cmp #22
    bne +
    lda cur_color
    and #$F7 ; remove bright bit
    sta cur_color
    jmp sgr_next 

+
sgr_30: ; 30-37: basic colors
    cmp #38
    bcs +
    sec
    sbc #30
    sta param_1
    lda cur_color
    and #$F0
    ora param_1
    sta cur_color
    jmp sgr_next

+   cmp #39
    bne +
    lda cur_color
    and #$F0
    ora #default_color_fg
    sta cur_color
    jmp sgr_next

+
sgr_40: ; 40-47: background colors
    cmp #48
    bcs +
    sec
    sbc #40
    asl
    asl
    asl
    asl
    sta param_1
    lda cur_color
    and #$0F
    ora param_1
    sta cur_color
    jmp sgr_next

+   cmp #49
    bne +
    lda cur_color
    and #$0F
    ora #default_color_bg
    sta cur_color
    jmp sgr_next


+   ; 90-97: bright colors
    cmp #90
    bcc +
    cmp #98
    bcs +

    sec
    sbc #82
    sta param_1
    lda cur_color
    and #$F0
    ora param_1
    sta cur_color
    jmp sgr_next

+
sgr_100: ; 100-107: bright background colors
    cmp #108
    bcs +
    sec
    sbc #92
    asl
    asl
    asl
    asl
    sta param_1
    lda cur_color
    and #$F0
    ora param_1
    sta cur_color
    jmp sgr_next

+   ; ignore other codes
sgr_next:
    inx
    cpx param_index
    bcs +
    jmp sgr_loop
+   bne +
    jmp sgr_loop

+   jmp cmd_done

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
    stz param_index
    stz param_0
    stz param_1
    stz param_2
    jmp check_bounds

;
; cursor blinking
; 
csr_blink_off:
    ; blink the cursor off, either because the timer or 
    ; when moving the cursor
    rts

csr_blink_on:
    ; blink the cursor on due to the timer or because
    ; the cursor was just moved
    ;todo
    rts

csr_blink_toggle:
    ; blink the cursor at the 1/2 cycle time
    ;todo
    rts

csr_blink_wait:
    ; checks the clock and blinks if it's time
    ;todo
    rts

csr_hide:
    ; turn the cursor off and keep it off. Disables blinking.
    ;todo
    rts

csr_show:
    ; shows the cursor and starts the blink cycle.
    ;godo
    rts

; ----------------------------------------------------------------------
; Scrolling  
; The screen can be scrolled up or down by any number of rows.  
; Empty space will be created at the top or bottom of the screen based on the
; scroll direction 

; move data on the screen upward
; Always scrolls at least one row. Scrolling more than
; the screen rows will just empty the screen. 
; 
; input: 
;   .A: number of rows
; affects: 
;   .A .X .Y Flags
;   vera_address0-2
;   vera_dcsel
do_scroll_up:
    sta start_row2
    ; copying from line 1 to line 0
    stz start_row
    stz start_col
    lda col_count
    dec A
    sta end_col

    jsr vera_set_address_0
    jsr vera_set_address_1

    ; set up area to scroll
    ; scrolls rows between start_row and end_row
    lda row_count
    sec
    sbc start_row2
    tay

    lda col_count
    asl
    tax
    ; scroll one row
-   lda vera_data1
    sta vera_data0
    dex
    bne -
    ; repeat for the next row
    inc work_row
    inc work_row2
    jsr vera_set_address_0
    jsr vera_set_address_1
    dey
    bne -

; erase bottom of screen
    ldx cur_char
    ldy cur_color
    lda col_count

scroll_fill_line:
    ; set address to start of next row
    lda col_count ; number of columns to delete
    stz vera_addr0
    inc vera_addr1

-   stx vera_data0
    sty vera_data0      
    dec a               
    bne -
    jsr do_callback  ; give serial driver the chance to empty the FIFO

    ; check for last line
    ; or end of operation
    inc work_row
    lda work_row
    cmp row_count
    bcc scroll_fill_line
    
    rts

; end scrolling
; ----------------------------------------------------------------------

; Data segment

; cursor location is in character coordinates
; and is converted to memory coordinates in load_addr_vector
csr_col:       .byte $00  ; column number (addr bits 0-7)
csr_row:       .byte $00  ; row number (addr bits 8-15)
csr_bank:      .byte $11 ; auto-increment and addr bit 16.
csr_base:      .byte $b0  ; base address of screen buffer

cur_color:     .byte $01 ; currrent color attribute
cur_char:      .byte ' ' ; fill character for clear screen

cur_mode:      .byte $00 ; Modes bitmask (not implemented)
                         ; $01 Bold
                         ; $02 Faint
                         ; $04 Italic
                         ; $08 Underline
                         ; $10 Blink
                         ; $20 Inverse/Reverse
                         ; $40 Hidden/Invisible
                         ; $80 Strikethrough


col_count:     .byte 80 ; default screen width  
row_count:     .byte 60 ; default screen height

bank_rom_save: .byte 0 ; perserve the current ROM bank
bank_ram_save: .byte 0 ; preserve the current RAM bank

param_count = 5
parameters:
param_index:   .byte 0     ; >0 if parsing a terminal sequence
param_0:       .byte 0     ; .X=1 [ or pain non-CSI command 
param_1:       .byte 0     ; .X=2 first parameter in CSI
param_2:       .byte 0     ; .X=3 second parameter in CSI
param_3:       .byte 0     ; .X=4 second parameter in CSI
param_4:       .byte 0     ; .X=5 second parameter in CSI

digit_1:       .byte 0     ; character being processed

; variables

incr_col:
start_col:              ; start col for erase/scroll (0-79)
work_col:      .byte 0  ; current col for erase/scroll (0-79)
start_row:              ; start row for erase/scroll (0-59)
work_row:      .byte 0  ; current row for erase/scroll (0-59)
end_col:       .byte 0  ; end col for erase/scroll (0-79)
end_row:       .byte 0  ; end row for erase/scroll (0-59)
start_row2:       
work_row2:     .byte 0  ; data is copied FROM this row when scrolling
mult_1:        .byte 0  ; temp slot for multiplication
mult_2:        .byte 0  ; temp slot for multiplication

; cursor blink state
cbs_next:      .word 0     ; the next time the cursor should blink
cbs_blink:     .byte 0     ; Bitmask
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

; write palette data to $1FA00
palette_data:    
palette_normal:
              .byte $00, $00  ; black  
              .byte $00, $0A  ; red
              .byte $A0, $00  ; green
              .byte $A0, $0A  ; yellow
              .byte $0A, $00  ; blue
              .byte $0A, $0A  ; magenta
              .byte $AA, $00  ; cyan
              .byte $AA, $0A  ; white
pallete_bright:   
              .byte $66, $06  ; dark gray (light black)
              .byte $00, $0f  ; light red
              .byte $f0, $00  ; light green
              .byte $f0, $0f  ; bright yellow
              .byte $0f, $00  ; light blue
              .byte $0f, $0f  ; light magenta
              .byte $ff, $00  ; light cyan
              .byte $ff, $0f  ; bright white
palette_end:

; this address is called at the end of each row when the screen is being
; scrolled or cleared (or any other long operation)
callback_addr:
            .word empty_callback
