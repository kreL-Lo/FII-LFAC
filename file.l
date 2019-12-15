%{
#include <stdio.h>
#include "y.tab.h"
%}
%%
"int"|"float"|"char"|"bool" {return TYPE;}
"const" {return CONST;}
"string" {return STRINGTYPE;}
"class" {return CLASS;}
"main" { return MAIN;}
"if" {return IF;}
"end_if" {return ENDIF;}
"end_while" {return ENDWHILE;}
"end_for" {return ENDFOR;}
"else" {return ELSE;}
"while" {return WHILE;}
"for" {return FOR;}
"&&" {return AND;}
"||" {return OR;}
"==" {return EQEQ;}
"!=" {return NOTEQ;}
">=" {return GTEQ;}
"<=" {return LOEQ;}
">" {return GT;}
"<" {return LO;}
"!" {return NOT;}
"=" {return EQ;}
"," {return COMMA;}
"(" {return POPN;}
")" {return PCLS;}
"{" {return BOPN;}
"}" {return BCLS; }
";" {return SEMIC;}
"+" {return PLUS;}
"-" {return MINUS;}
"*" {return MUL;}
"/" {return DIV;}
\"[_a-zA-Z0-9 ]*\" {return STRING;}
[_a-zA-Z][_a-zA-Z0-9]* {return ID;}
[0-9]+ {return NUMBER;}
[ \t] ;
\n {yylineno++;}
. {return yytext[0];}

 
