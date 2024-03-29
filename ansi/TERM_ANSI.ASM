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

strout_addr = $7E     ; string pointer for strout procedure

;
; Sets the cursor position
; .X Column
; .Y Row
; Modifies: None
locate:
    txa 
    sta VCol
    tya
    sta VRow
    rts

; 
; Sets the VERA address vector to the current cursor position
; Row should be in Row variable
; Col should be in VCol variable
; modifies .A .P
;
load_addr_vector:
    stz vera_dcsel        ; work with data port 0
    lda VCol
    asl A
    sta vera_addr0
    lda VRow
    clc
    adc VBase
    sta vera_addr1
    lda VBnk
    sta vera_addr2
    rts

; Print a null-terminated string
; strout_addr: string address
; modifies r0 .A .Y .P
strout:
    ldy #0
    lda (


; Print a character to the screen 
; Intercepts and stores any ANSI terminal sequences
; .A character to print
; modifies .A .Y .P
chrout:
    ldy cmd_pos
    beq chrout_not_tsq

    cmp #$40 ; check for letter
    bpl chrout_cmd
    ; if not letter, add to the terminal sequence buffer
    sta cmd_buffer,y
    iny
    cpy #cmd_max
    rts 

; if the last character was a letter, decode the command and act on the buffer
chrout_cmd:    
    jmp do_cmd

chrout_not_tsq:
    cmp #27 ; check for escape character
    bne chrout_not_esc
    sta cmd_buffer,y
    iny

chrout_not_esc:
    sta vera_data0
    lda VAttr
    sta vera_data0
    lda vera_addr0
    sta VCol
    rts
    jmp check_bounds

; Reset the terminal sequence buffer after a terminal command
chrout_clear_cmd:
    stz cmd_pos

; Check the cursor column and row
; if needed, wrap the cursor to column 1 and advance to next row
; (todo) Scroll text up if cursor is past the bottom of the screen
check_bounds:
    lda VCol
    cmp Col_max
    bmi check_row
    stz VCol
    inc VRow
    sec
check_row:
    lda VRow
    bmi check_load_addr_vector
    sec
    lda Row_max
    sta VRow
check_load_addr_vector:
    bcc check_done
    jmp load_addr_vector
check_done:
    rts 

; execute a terminal command
do_cmd:
    ; Home (set cursor location)
    cmp #'H'
    bne not_h
    jmp do_home
not_h:
    ; Invalid command (dump buffer and return)
    jmp chrout_clear_cmd

do_home:
    stz R0L
    stz R0H
    jmp chrout_clear_cmd

; Data segment
VCol:       .byte $00 ; column number (addr bits 0-7)
VRow:       .byte $00 ; row number (addr bits 8-15)
VBnk:       .byte $11 ; auto-increment and addr bit 16.
VBase:      .byte $b0 ; base address of screen buffer

VAttr:      .byte $01 ; color attribute
VChr:       .byte $00 ; character being printed

Col_max:    .byte 79 * 2  
Row_max:    .byte 24 

cmd_x       .byte 0   ; first parameter in command
cmd_y       .byte 0   ; second parameter in command
cmd_pos     .byte 0   ; >0 if parsing a terminal sequence
cmd_max     = 16   ; length of terminal sequence buffer
cmd_buffer  .fill cmd_max
