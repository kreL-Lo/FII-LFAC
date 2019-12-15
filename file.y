%{
#include <stdio.h>
extern FILE* yyin;
extern char* yytext;
extern int yylineno;
%}
%token TYPE STRINGTYPE CLASS STRING ID BOPN BCLS SEMIC EQ NUMBER CONST POPN PCLS COMMA MAIN
%start start
%%
start : progr {printf("Accepted!");}
      ;

progr : classes declaratii main 
      | declaratii main 
      | classes main
      | main
      ;

bgn_main : TYPE MAIN args
         ;
main : bgn_main BOPN blocks BCLS

blocks :
       ;
args : POPN PCLS 
     | POPN parameters PCLS
     ;  
parameters : param COMMA parameters
           | param 
           ;
param : TYPE ID 
      ; 

classes : class 
        | classes class
        ;
class : CLASS ID BOPN declaratii BCLS  SEMIC 
      | CLASS ID BOPN BCLS  SEMIC 
      ;

declaratii : declaratie 
           | declaratii declaratie 
           ;

declaratie : TYPE ID SEMIC
           | CONST TYPE ID SEMIC 
           | TYPE ID EQ NUMBER SEMIC
           | CONST TYPE ID EQ NUMBER SEMIC
           | STRINGTYPE ID SEMIC 
           | STRINGTYPE ID EQ STRING SEMIC 
           ;

%%
int yyerror(char * s){
printf("eroare: %s la linia:%d\n",s,yylineno);
}

int main(int argc, char** argv){
    yyin=fopen(argv[1],"r");
    yyparse();
} 
