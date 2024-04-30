Completion checklist for Escape codes and control characters

| Done | Name  | decimal | octal | hex  | C-escape | Ctrl-Key | Description                    |
|------| ----- | ------- | ----- | ---- | -------- | -------- | ------------------------------ |
|      | `BEL` | 7       | 007   | 0x07 | `\a`     | `^G`     | Terminal bell                  |
|      | `BS`  | 8       | 010   | 0x08 | `\b`     | `^H`     | Backspace                      |
|      | `HT`  | 9       | 011   | 0x09 | `\t`     | `^I`     | Horizontal TAB                 |
| y    | `LF`  | 10      | 012   | 0x0A | `\n`     | `^J`     | Linefeed (newline)             |
| y    | `FF`  | 12      | 014   | 0x0C | `\f`     | `^L`     | Formfeed (also: New page `NP`) |
| y    | `CR`  | 13      | 015   | 0x0D | `\r`     | `^M`     | Carriage return                |
| y    | `ESC` | 27      | 033   | 0x1B | `\e`[*](#escape) | `^[` | Escape character           |
|      | `DEL` | 127     | 177   | 0x7F | `<none>` | `<none>` | Delete character               |

## Escape Codes

| Done | Sequence	  | Effect                                            | 
|------|--------------|---------------------------------------------------|
|      | ESC [ r A	  | Cursor up (CUU)                                   |
|      | ESC [ r B	  | Cursor down (CUD)                                 |
|      | ESC [ c C	  | Cursor forward (CUF)                              |
|      | ESC [ c D	  | Cursor back (CUB)                                 |
| yes  | ESC [ r;c f  | Horizontal and vertical position (HVP)†           |
| yes  | ESC [ r;c H  | Cursor position (CUP)†                            |
| yes  | ESC [ n J	  | Erase display (ED) (n=0, 2 or n=0, 1, 2)[nb 1]    |
| yes  | ESC [ n K	  | Erase in line (EL) (n=0 or n=0, 1, 2)[nb 1]       |
|      | ESC [ n m	  | Select graphic rendition (SGR) (n=0..47)          |
|      | ESC [ 6 n	  | Device status report (DSR) requests cursor position, returned as cursor position report (CPR): ESC [ r;c R |
|      | ESC [ s	  | Save cursor position (SCP)                        |
|      | ESC [ u	  | Restore cursor position (RCP)                     |
|      | ESC 7        | Save cursor position (SCP)                        |
|      | ESC 8        | Restore cursor position (RCP)                     |


* HT moves to the next decade column on the screen (10,20,30, ...)
* LF moves to the cursor down one line
* CF moves to the start of the current row
* ESC prefixes Escape Codes
* DEL blanks the current character cell and moves the cursor left one space. It
  does NOT pull text in from the right
* BS moves the cursor left one space. It does not affect the text on the screen
