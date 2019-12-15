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
"," {return COMMA;}
"(" {return POPN;}
")" {return PCLS;}
"{" {return BOPN;}
"}" {return BCLS; }
";" {return SEMIC;}
"=" {return EQ;}
\"[_a-zA-Z0-9 ]*\" {return STRING;}
[_a-zA-Z][_a-zA-Z0-9]* {return ID;}
[0-9]+ {return NUMBER;}
[ \t] ;
\n {yylineno++;}
. {return yytext[0];}

 
