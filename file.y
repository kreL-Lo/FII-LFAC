%{
#include <stdio.h>
extern FILE* yyin;
extern char* yytext;
extern int yylineno;
%}
%token FLOAT BOOL CHAR INT STRINGTYPE CLASS STRING ID BOPN BCLS SEMIC EQ NUMBER CONST POPN PCLS COMMA MAIN IF ELSE WHILE FOR LO GT LOEQ GTEQ EQEQ NOTEQ AND OR NOT PLUS MINUS DIV MUL ENDIF ENDWHILE ENDFOR DECR INCR FUNCTION FUNC_ID EVAL CALL VECTOR RETURN
%start start
%left AND
%left OR
%left PLUS MINUS
%left MUL DIV
%left NOT

%%
start : eva progr {printf("Accepted!");}
      ;

progr : main
      ;
functii : functii functie
        | functie
        ;
eva : FUNCTION EVAL POPN INT ID PCLS BOPN block BCLS  
    |  FUNCTION EVAL POPN INT ID PCLS BOPN BCLS  
    ;
functie : FUNCTION tip FUNC_ID args BOPN blocks BCLS
        | FUNCTION tip FUNC_ID args BOPN BCLS
        ;
tip : INT 
    | FLOAT
    ;

bgn_main :FUNCTION INT MAIN args
         ;
main : bgn_main BOPN blocks BCLS
     | bgn_main BOPN BCLS
     ;

blocks : block
       | blocks block
       ;
block : statements
      ;

if_stmt :  IF POPN condition PCLS BOPN blocks BCLS ENDIF
      | IF POPN condition PCLS BOPN blocks BCLS ELSE BOPN blocks BCLS ENDIF
      | IF POPN condition PCLS BOPN BCLS ELSE BOPN blocks BCLS ENDIF
      ;

for_stmt : FOR POPN statements SEMIC condition SEMIC blocks PCLS BOPN statements BCLS ENDFOR
         ;

while_stmt : WHILE POPN condition PCLS BOPN blocks BCLS ENDWHILE
           ;

call_parm : CALL FUNC_ID args_call
          ;

statements : expression_stmt
          | if_stmt 
          | while_stmt
          |for_stmt
          |return_stmt
          ;
return_stmt : RETURN SEMIC
            ;
 
expression_stmt : ID EQ expr SEMIC
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
args_call : POPN PCLS
          | POPN parameters_call PCLS
          ;

parameters_call : param_call COMMA  parameters_call
                | param_call
                ;
param_call : ID
           ;

args : POPN PCLS 
     | POPN parameters PCLS
     ;  
parameters : param COMMA parameters
           | param 
           ;
param : tip ID 
      ; 

classes : class 
        | classes class
        ;
class : CLASS ID BOPN declaratii BCLS  SEMIC 
      | CLASS ID BOPN BCLS SEMIC 
      ;

declaratii : declaratie 
           | declaratii declaratie 
           ;

declaratie :tip ID SEMIC
           | CONST INT ID SEMIC
           | INT ID EQ NUMBER
           | CONST ID EQ NUMBER
           | CONST tip ID SEMIC 
           | tip ID EQ NUMBER SEMIC
           | CONST tip ID EQ NUMBER SEMIC
           | STRINGTYPE ID SEMIC 
           | STRINGTYPE ID EQ STRING SEMIC 
           | VECTOR INT ID ':' '[' list ']' SEMIC
           ;
list : list COMMA NUMBER
     | NUMBER
     ;


%%
int yyerror(char * s){
printf("eroare: %s la linia:%d\n",s,yylineno);
}

int main(int argc, char** argv){
    yyin=fopen(argv[1],"r");
    yyparse();
} 
