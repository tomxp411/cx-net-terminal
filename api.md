
# ANSI terminal APIs 

The ANSI display module will be developed as a public API, separate from the terminal program. This allows for multiple terminal logic modules to be implemented. 

This the preliminary API list for the ANSI display module. This will be a jump table in the Terminal bank, located *below* the KERNAL public APIs.

## Terminal Decode API

* `TERM_INIT` .A is 0 for PETSCII, 1 for ANSI. Add $80 for custom character set and $40 for custom terminal logic. Set TERM_VECTOR and TERM_CHARSET as appropriate.
* `TERM_CLS` Clears the screen. 
* `TERM_LOCATE` set cursor location to Row .Y Col .X
* `TERM_SCREEN` set screen size. .X=columns .Y=rows. Text will be scaled 2x as needed when cols <= 40 or rows <= 30. 
* `TERM_PUTC` prints char in .A. Interprets terminal commands based on the terminal mode.
* `TERM_PUTS` string pointer at R0. Interprets terminal commands based on the terminal mode.
* `TERM_CLOSE` restore the system font and exit to BASIC.
* `scroll` scroll .A rows. .A is signed value -60 to 60. If A is positive, the text moves up the screen, opening space at the bottom.
* `clear_line` .A=0 clear from cursor to end of line. .A=1 clear from start of line to cursor. .A=2 clear entire line
* `clear_screen` .A=0 clear from cursor to end of screen. .A=1 clear from start of screen to cursor. .A=2 clear entire screen. Does NOT move the cursor.
* `color` sets the color attribute.
* `background` sets the background color.
* `blink` sets blinking text
* TERM_VECTOR: A pointer will be set aside in Zero Page for the terminal decode address. In PETSCII or ANSI modes (0 or 1), this will be set to the address of the ROM decode logic.
For plugin terminals, this will be set to the address of the plugin code. 
* `TERM_CHARSET` A pointer to the string holding the name of a custom font file. The font should be ordered in the order of your character encoding (usually ASCII, so A=65 and a=97.)
* `ENCODE_KEY` accepts a key code in .A and encodes a terminal string. The string will be placed in KEY_BUFFER and be null terminated.

## Serial port API

* `OPEN` opens the serial port. R0-Rx will contain: Baud rate (3 bytes), Bits (7-8), Stop Bits (1-2), Parity (N,O,E,M,S). 
This will be formatted as a drop-in value for the UART's control register.
Buffering will also be configured in the OPEN call.
* `CLOSE` terminates serial port handling.
* `READ` reads one byte from the port to .A. Carry=1 if data is valid. If c=0, then .A is invalid.
* `CAN_READ` sets Carry bit 1 if data is waiting to be read. c=0 if no data is waiting.
* `SEND` send .A to serial port. Blocks until data is sent.
* `CAN_SEND` returns C=1 if the output buffer is not full. (ie: you can send a byte.)
* `SERVICE_BUFFER` services the RAM buffers. 

Data *may* be stored in a pair of ring buffers. If the buffers are enabled, then SERVICE_BUFFER must be called (directly or via an ISR) to check the 
serial port's data waiting register, pull any data from the port, and populate the buffer. Likewise, the routine will check the send buffer and 
transmit any bytes that are waiting, up until the RAM buffer is empty or the UART's buffer is full. At 115K, the serial port transmits 240 bytes per
1/60sec Jiffy, so a 1-page buffer should allow for direct interrupt driven, Jiffy clock driven, or polled communications.

