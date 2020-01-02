%{
#include <stdio.h>
#include "y.tab.h"
%}
%%
"float" {yylval.str=strdup(yytext); return FLOAT;}
"char"  {yylval.str=strdup(yytext); return CHAR; }
"bool" {yylval.str=strdup(yytext);return BOOL;}
"int" {yylval.str=strdup(yytext); ;return INT;}
"string" {yylval.str=strdup(yytext); return STRINGTYPE;}
"vector" {return VECTOR;}
"const" {return CONST;}
"return" {return RETURN;}
"false" {return FALSE;}
"true" {return TRUE;}
"class" {return CLASS;}
"call" {return CALL;}
"@eval" {return EVAL;}
"@eval_str" {return EVAL_STR;}
"main" { return MAIN;}
"if" {return IF;}
"end_if" {return ENDIF;}
"end_while" {return ENDWHILE;}
"end_for" {return ENDFOR;}
"to" {return TO;}
"concat" {return CONCAT;}
"length" {return LENGTH;}
"eq_str" {return EQ_STR;}
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
"." {return DOT;}
"-" {return MINUS;}
"*" {return MUL;}
"/" {return DIV;}
"<-" {return STR_ATRIB;}
\"[_a-zA-Z0-9 ]*\" {yylval.str=strdup(yytext);return STRING;}
[_a-zA-Z][_a-zA-Z0-9]* {yylval.str=strdup(yytext);return ID;}
[0-9]+,[0-9]+f {return FLOATVAL;}
[0-9]+ {yylval.num=atoi(yytext);return NUMBER;}
@[_a-zA-Z][_a-zA-Z0-9]* {return FUNC_ID;}
$[_a-zA-Z][_a-zA-Z0-9]* {return CLASS_ID;}
0[_a-zA-Z][_a-zA-Z0-9]* {return VECID;}
#[_a-zA-Z0-9] {yylval.str=strdup(yytext);return CHARVAL;}
[ \t] ;
\n {yylineno++;}
. {return yytext[0];}

 
