
 ΐ:�$810    ��w��
���� 7��- C 1L ����`�H�H�m��� Ch�h����`L     [Press Any Key] [2J[2H[36m....,....1....,....2....,....3....,....4....,....5....,....6....,....7....,....8[19H....,....1....,....2....,....3....,....4....,....5....,....6....,....7....,....8[21H....,....1....,....2....,....3....,....4....,....5....,....6....,....7....,....8[60;70H7....,....8[H1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
57
58
59
60[H[0m [2J[H[2;4HANSI Control and Escape Code Demo


This will run several test sequences.
After each sequence, the test will pause.
Text on the screen should tell you how
to interpret each test.

For example:
....,....1....,....2
    x [x is on column 5]

If the x is on column 5, then the test passes.


After confirming each test, press a key
for the next test.


[Press a key] [5;5HScroll Test: The screen will scroll up by 1 line.[60;10H[Bottom of the screen] 
	[after the line feed, the new bottom] [2J[H[2;65HNo-wrap test. -[Not visible]>[3HNo-Wrap test: > char should be on
right edge and [Not visible] should not
be visible.
 [2J[HBad escape code tests:
H (missing [)
[Z (Z is not a valid command)
 [2J[1;5H[97mColor Test

[0m[37m37 WHITE    [1m1 BOLD  
[36m36 CYAN     [1m1 BOLD  
[35m35 MAGENTA  [1m1 BOLD  
[34m34 BLUE     [1m1 BOLD  
[33m33 YELLOW   [1m1 BOLD  
[32m32 GREEN    [1m1 BOLD  
[31m31 RED      [1m1 BOLD  
[44m[30m30 BLACK    [1m1 BOLD  
[49m

[39m39 DEFAULT (white on black)


[97m97 BRT WHITE
[96m96 BRT CYAN
[95m95 BRT MAGENTA
[94m94 BRT BLUE
[93m93 BRT YELLOW
[92m92 BRT GREEN
[91m91 BRT RED
[90m90 BRT BLACK


[30;47m47 BG WHITE   [49m
[30;46m46 BG CYAN    [49m
[30;45m45 BG MAGENTA [49m
[30;44m44 BG BLUE    [49m
[30;43m43 BG YELLOW  [49m
[30;42m42 BG GREEN   [49m
[30;41m41 BG RED     [49m
[90;40m40 BG BLACK   [49m


[39m39 DEFAULT (white on black)


[37m[[93mA[37m][32m Menu Item Test
[0m0 RESET
 [97m[2J[HCursor movement test


[31m[5HCUU >[A< Up one line


[5;30HCUU 1 >[1A< Up 1 line


[5;60HCUU 2 >[2A< Up 2 lines
[32m[10HCUD >[B< Down one line

[10;30HCUD 1 >[B< Down one line

[10;60HCUD 2 >[2B< Down 2 lines

[33m[15HCUF >[C< One space gap

CUF 1 >[C< One space gap

CUF 2 >[2C< 2 space gap

[36mCUB >X[D< Should be no gap and no X

CUB 1 >X[1D< Should be no gap and no X

CUB 2 >XX[2D< Should be no gap and no X



 [2J[H[0mControl character test

$07 BELL: Play a tone
Ding [Pass if you heard a 'ding' sound.]


 $08 BS: Backspace
Backspace test [should say 'pass' twice]: failpasspass


 $09 HT: Horizontal tab
         |         |         |         |
bars	|should	|line	|up	|


 $10 LF: moves the cursor down one line
Line 1 \
\ Line 2
The backslashes should line up.

 $13 CR: move to start of line

          <- CR TEST [should be on same line]CR TEST ->


 [20;20H[33mED  cursor to end ->[20;40H[90m[This text should disappear] [20;40H[0J [20;17H[90m[This should disappear][33m[20;40H<- ED start to cursor
[60;54HThis should remain visible. [20;39H[1J [2J[10;27H   Erase full screen[11;27H Screen should be clear[12;27H[Aside from this message] [20;10H[33mEL cursor to to end of line ->[20;40H[90m[This text should disappear] [20;40H[0K [20;10H[90m  This text should disappear ->[20;41H[33m<- EL start to cursor [20;40H[1K [20H[36m....,....1....,....2....,....3....,....4....,....5....,....6....,....7....,....8[20;18H[33m[EL entire line. This text should disappear] [20;10H[2K [H� HOME POSITION
 [20;40H� Row 20 Col 40
 [60;80H�[60;65HRow 60 Col 80 [4;5H� Row 4 Col 5
 [10H+ Line 10, column 1 (no column) [;40H+ Col 40 (no row)   [29;27HPress a key to restart test     � ��� b�� � ����!���"�� ���#��� ���R��P n�c�
�8 n�i�
`H�L�M h`�%��^
� ��_mO�!��N�"�`��%��^
� ��bmO�!��N�"��%�`�%��L
� ��MmO�!��N�"�`�%�� �J�L�!�8�O�M` �� \��������`�W��x�L�� �3�#��P�#��L�L�S��S:�L�M8�T� ��T:�M `���WL��
�	�M Lx��	�L Lx��L���L��	�L�Ll�[��WL��WLl�;��WL��0�$�:� 8�0�]�W


�c�W
mcm]�WL�L �A�)�B�=�C�Q�D�e�f�y�H�u�J�L�K�|�m�L�L��Y��M8�Y�ML��ML��Y��MmY�ML��ML��Y��LmY�LL��LL��Y��L8�Y�LL��LL��Z�ʬY�� �L��Y��L�^�M�_�S:�`�M�aLp���^�M�_�L�`�M�aLp��9�^�M�_�S�`�M�aLp�Y��L�^�M�_�S�`�T:�aLp���^�_�L�`�M�aLp���^�_�S:�`�T:�aLpL��Q�P�%��^
� ��_mO�!��N�"��`8�^�#��#�:�� �� ��!��_�_�a���S�ܭ`��L��
�� � � n� �
L��L�:�L L��L��h��L L���W��R��PL������P	�PL����P)��PL��&�8��Y�P)�Y�PL��'��P)�	�PL��0�8�(



�Y�P)Y�PL��1��P)	 �PL��Z��b�8�R�Y�P)�Y�PL��l�8�\



�Y�P)�Y�PL���W�L��L�L�l
`�W�X�Y�ZLx``````�b�_�^�S:�` � ��T8�b��S
��$��#�����_�b � ����Q�P�S�S� ��!��#��#�:�� ��_�_�T��`  �  P<                            �         �         �         �         �         �         �         �         �         �         �         �        ��   
� �

 

� �
f � � � ��