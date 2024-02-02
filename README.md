# CX-Net 
This will be the home of the X16 Serial Terminal.

## Description

The Commander X16 is a 65C02 computer designed by The 8-Bit Guy and sold by TexElec. 

TexElec has designed a UART/MIDI card that will allow the X16 to talk to serial port devices, including dial-up modems, network terminal adapters, PCs, and MIDI keyboards and synthesizers.

This project is meant to support BBS style communication and file transfer, as well as serving as a terminal for CP/M computers like the Altair 8800 and IMSAI 8080.

Planned features are:

* Connects at 9600 (and up, hopefully) to any standard RS-232 DCE device.
* Text interface with ANSI, ADM-3A, and PETSCII terminal modes
* 80x24, 80x30, 40x25, and 40x30 text modes. (VGA required)
* Address book to store frequently used sites
* XMODEM file transfer module
* Commander Net (proprietary) transfer module
  * Auto-download with automatic filename
  * Cross platform X-Net server for Windows, Linux, Mac, and X16.

## CX-Net Server
* Runs on Windows, Mac, and Linux:
* Emulate a Hayes modem for Internet dialout.
  * AT *address* dialing commands
* Quick file transfer to/from the PC
* PC "Host Mode" mini BBS, with e-mail and file section.
