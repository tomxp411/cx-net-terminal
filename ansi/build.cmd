@echo off

set progdir=%~dp0
set p=ANSI

:start
del %p%.lst
del %p%.prg

rem Write standard PRG with header
rem 64tass %p%.asm -o %p%.prg --list %p%.lst

rem Write flat binary for BLOAD
:64tass %p%.ASM -o %p%.bin -b --list %p%.lst
64tass %p%.ASM -o %p%.PRG --list %p%.LST --cbm-prg
if errorlevel 1 goto fail
goto done 

choice /m "Start emulator?"
if errorlevel 2 goto end
:..\..\x16emu -scale 2 -echo -fsroot . -prg %p%.prg -run 
..\..\x16emu -scale 2 -echo -fsroot . -rtc -debug
goto done

:fail
echo Assembly failed.

:done
