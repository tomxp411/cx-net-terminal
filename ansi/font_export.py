# font_export
# 
# convert a BIN file to assembly language source code in the format
# ; $00
# .byte %11100011
# .byte %11011101
# .byte %10110101
# .byte %10101001
# .byte %10110011
# .byte %11011111
# .byte %11100001
# .byte %11111111
# Useful for importing font files as asm resources.
#

font_bin = open("ANSIFONT.BIN", "rb")
font_asm = open("ANSIFONT.ASM", "w")

font_data = font_bin.read()

print(";", file=font_asm)
print("; ANSI character set based on CP437 / ANSI BBS", file=font_asm)
print(";", file=font_asm)
print(file=font_asm)
print("; This is the full 7-bit ASCII character set, with Code Page 437,", file=font_asm)
print("; AKA ANSI BBS or IBM Extended ASCII.", file=font_asm)
print("; This is suitable for ANSI BBS and conversion of GW-BASIC programs.", file=font_asm)
print(";", file=font_asm)
print(file=font_asm)
print(".segment \"CHARANSI\"",file=font_asm)
print(file=font_asm)


# counter; every 8 bytes, we'll inject the current 
# character number
char_num = 0
row_num = 0

for b in font_data:
    if row_num % 8 == 0:
        print("; ${:02X}".format(char_num), file=font_asm)
        char_num += 1
    row_num += 1

    print(".byte %{:08b}".format(b), file=font_asm)
    print("${:02X}".format(char_num), ".byte %{:08b}".format(b), end="\r")

font_asm.close()
font_bin.close()
