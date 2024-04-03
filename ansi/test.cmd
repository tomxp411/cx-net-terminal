@echo on

call build.cmd

set progdir=%~dp0
set p=ansi.prg
if not exist %p% goto fail

:test
:C:\cx16\x16emu -fsroot . -scale 2 -echo -rtc -debug -prg ansi.prg -run -gif ansi_test.gif
C:\cx16\x16emu -fsroot . -scale 2 -echo -rtc -debug -prg ansi.prg -run
goto done

:fail
echo Assembly failed.

:done
