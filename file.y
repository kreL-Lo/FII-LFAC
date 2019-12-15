%{
#include <stdio.h>
extern FILE* yyin;
extern char* yytext;
extern int yylineno;
%}
%token TYPE STRINGTYPE CLASS STRING ID BOP BCLS SEMIC
%start start
%%
start : progr {printf("Accepted!");}
      ;


progr : classes 
      ;

classes : class 
        | classes class
        ;
class : CLASS ID BOP declaratii BCLS SEMIC 
      ;

declaratii : declaratie SEMIC
           | declaratii declaratie SEMIC
           ;

declaratie : TYPE ID ';'
           ;
%%
int yyerror(char * s){
printf("eroare: %s la linia:%d\n",s,yylineno);
}

int main(int argc, char** argv){
    yyin=fopen(argv[1],"r");
    yyparse();
} 