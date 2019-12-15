%{
#include <stdio.h>
extern FILE* yyin;
extern char* yytext;
extern int yylineno;
%}
%token TYPE STRINGTYPE CLASS STRING ID BOPN BCLS SEMIC EQ NUMBER CONST POPN PCLS COMMA MAIN IF ELSE WHILE FOR LO GT LOEQ GTEQ EQEQ NOTEQ AND OR NOT PLUS MINUS DIV MUL ENDIF ENDWHILE ENDFOR
%start start
%left AND
%left OR
%left PLUS MINUS
%left MUL DIV
%left NOT
//problems: 
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
     ;

blocks : block
       | BOPN block BCLS
       | blocks block
       ;
block : IF POPN condition PCLS statement ENDIF
      | IF POPN condition PCLS BOPN statements BCLS ENDIF
      | IF POPN condition PCLS statements ELSE statement ENDIF
      | IF POPN condition PCLS BOPN statements BCLS ELSE statement ENDIF
      | IF POPN condition PCLS BOPN statements BCLS ELSE BOPN statements BCLS ENDIF
      | IF POPN condition PCLS statement ELSE BOPN statements BCLS ENDIF
      | FOR POPN statement SEMIC condition SEMIC statement PCLS statement  ENDFOR
      | FOR POPN statement SEMIC condition SEMIC statement PCLS BOPN statements BCLS ENDFOR
      | WHILE POPN condition PCLS statement ENDWHILE
      | WHILE POPN condition PCLS BOPN statements BCLS ENDWHILE
      | declaratie
      | statement
      ;
statements : statement SEMIC
           | statements statement SEMIC
statement : expr SEMIC
          ;
expr : expr PLUS expr
     | expr MINUS expr
     | expr MUL expr
     | expr DIV expr 
     | POPN expr PCLS
     | NUMBER
     ;
condition : op 
          | op LO op
          | op GT op
          | op LOEQ op
          | op GTEQ op
          | op EQEQ op
          | op NOTEQ op
          | NOT op
          | condition AND condition 
          | condition OR condition
          | POPN condition PCLS
          ;
op : ID
   | NUMBER 
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
