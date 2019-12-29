%{
#include <stdio.h>
#include "y.tab.h"
%}
%%
"float" {return FLOAT;}
"char"  {return CHAR; }
"bool" {return BOOL;}
"int" { return INT;}
"vector" {return VECTOR;}
"const" {return CONST;}
"string" {return STRINGTYPE;}
"return" {return RETURN;}
"class" {return CLASS;}
"call" {return CALL;}
"int @eval" {return EVAL;}
"main" { return MAIN;}
"if" {return IF;}
"end_if" {return ENDIF;}
"end_while" {return ENDWHILE;}
"end_for" {return ENDFOR;}
"else" {return ELSE;}
"while" {return WHILE;}
"for" {return FOR;}
"function" {return FUNCTION;}
"++" {return INCR;}
"--" {return DECR;}
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
@[_a-zA-Z][_a-zA-Z0-9]* {return FUNC_ID;}
[ \t] ;
\n {yylineno++;}
. {return yytext[0];}

 
