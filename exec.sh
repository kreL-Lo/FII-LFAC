rm y.tab.c |
rm y.tab.h | 
rm a.out |
yacc -d file.y |
lex file.l |
gcc lex.yy.c y.tab.c -ly -ll |
./a.out myOut