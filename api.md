The ANSI display module will be developed as a public API, separate from the terminal program. This allows for multiple terminal logic modules to be implemented. 

This the preliminary API list for the ANSI display module. This will be a jump table in the Terminal bank, located *below* the KERNAL public APIs.

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

