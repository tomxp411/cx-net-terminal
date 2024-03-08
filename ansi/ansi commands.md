
#ANSI Escape Codes

See https://en.wikipedia.org/wiki/ANSI_escape_code for more information.

## C0 Codes

| Chr | Hex  | Abbrev | Name       | Description     |
|-----|------|--------|------------|-----------------|
| ^@  | 0x00 | NUL    | Null       | Does nothing    |
| ^E  | 0x05 | ENQ    | Enquiry    | Sends back the terminal string (ANSI) |
| ^G  | 0x07 | BEL    | Bell       | Makes an audible noise.  |
| ^H  | 0x08 | BS     | Backspace  | Moves the cursor left (but may "backwards wrap" if cursor is at start of line). |
| ^I  | 0x09 | HT     | Tab	       | Moves the cursor right to next multiple of 8. |
| ^J  | 0x0A | LF     | Line Feed  | Moves to next line, scrolls the display up if at bottom of the screen. Usually does not move horizontally, though programs should not rely on this. |
| ^L  | 0x0C | FF     | Form Feed  | Move a printer to top of next page. Usually does not move horizontally, though programs should not rely on this. Effect on video terminals varies. |
| ^M  | 0x0D | CR     | Carriage   | Return	Moves the cursor to column zero. |
| ^[  | 0x1B | ESC    |	Escape     | Starts all the escape sequences |

## C1 Codes

| Code   | Abbr  | Name                         | Description  |
|--------|-------|------------------------------|--------------|
| ESC [  | CSI   | Control Sequence Introducer  | Starts a terminal sequence. Terminated by 0x40 - 0x7E (A-~) |

## CSI Sequences

CSI Sequences start with ESC [ and end with a letter. One or two numbers,
separated by a semicolon, may be used as arguments. 

The format looks like: `^[[H`, `^[[0H`, or `^[[0,1H`

* **A** Cursor up
  * nA Argument: move the cursor that many spaces.
* **B** Cursor Down
* **C** Cursor Right
* **D** Cursor Left
* **E** Start of next line
  * Move to the start of n lines down.
* **F** Start of previous line
  * Move to the start of n lines up.
* **G** Move to column
* **H** Move to position or Home
  * Accepts two arguments: Row ; Column
  * Default for *row* and *col* is 1.
  * H with no args moves to top left corner
* **J**
  * 0J Clears to the end of screen
  * 1J Clears from beginning of screen to cursor
  * 2J Clear entire screen (Home? not sure)
  * 3J Clear screen and scrollback buffer (XTerm)
* **K** Line Erase
  * 0K Erase from cursor to end of line
  * 1K Erase start of line to cursor
  * 2K Erase whole line.
* **S** Scroll Up
  * Moves text on screen upward. Opens up a row at the bottom of the screen
  * nS moves text *n* rows
* **T** Scroll Down
  * Moves text on screen down. Opens up a row at the top of the screen
  * nT moves text *n* rows
* **f** Same as H
* **s** Save cursor position
* **u** Recall saved position (moves cursor to saved position)
* **? 25 h** show cursor
* **? 25 l** hide cursor
* **m** Attribute change
  * **0m** Reset all attributes
  * **1m** Bold/Bright
  * **2m** Faint/Dim
  * **3m** Italic
  * **4m** Underline
  * **5m** Slow blink
  * **6m** Rapid blink
  * **7m** Reverse video
  * **8m** Hidden text
  * **9m** crossed out
  * **21m-29m** turn off 1-9 attribute
  * **30m-37m** set foreground color (3 bit RGB)
  * **38m** set foreground color: 5;n or 2;r;g;b
  * **39m** Default foreground color
  * **40m-47m** Background color
  * **48m** set background color: 5;n or 2;r;g;b
  * **49m** Default background color
  * **90m-97m** Bright foreground
  * **100m-107m** Bright background
    