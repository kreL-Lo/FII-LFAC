%{
#include <stdio.h>
#include "y.tab.h"
%}
%%
"int"|"float"|"char"|"bool" {return TYPE;}
"string" {return STRINGTYPE;}
"class" {return CLASS;}
"{" {return BOP;}
"}" {return BCLS; }
";" {return SEMIC;}
\"[_a-zA-Z0-9 ]*\" {return STRING;}
[_a-zA-Z][_a-zA-Z0-9]* {return ID;}
[ \t] ;
\n {yylineno++;}
. {return yytext[0];}

 
