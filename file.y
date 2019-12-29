%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

extern FILE* yyin;
extern char* yytext;
extern int yylineno;



struct var{
    int value;
    char * type;
    char * name;
    int constant;
    int 
    
};
struct var vars[500];
int k =0 ;
void declare_with_init(char * type, char * name,int value, int constant){

    vars[k].type = strdup(type);
    vars[k].name = strdup(name);
    vars[k].value = value;
    vars[k].constant= constant;
    ++k;
}
int getPosition(char * name){
    for(int i=0;i<k;i++){
        if(strcmp(vars[i].name,name)==0){
            return i;
        }
    }
    return -1;
}
int getValue(char * name){
    int position = getPosition(name);
    return vars[position].value;
}

%}
%token FLOAT BOOL CHAR INT STRINGTYPE CLASS STRING ID BOPN BCLS SEMIC EQ NUMBER CONST POPN PCLS COMMA MAIN IF ELSE WHILE FOR LO GT LOEQ GTEQ EQEQ NOTEQ AND OR NOT PLUS MINUS DIV MUL ENDIF ENDWHILE ENDFOR DECR INCR FUNCTION FUNC_ID EVAL CALL VECTOR RETURN
%start start
%left AND
%left OR
%left PLUS MINUS
%left MUL DIV
%left NOT
%union
{
    int num;
    char* str;
}
%type <num> expr NUMBER function_call
%type <str> ID FLOAT INT BOOL CHAR STRING tip
%%
start : progr {printf("Accepted!");}
      ;

progr : main
      ;
functii : functii functie
        | functie
        ;

functie : FUNCTION tip FUNC_ID args BOPN blocks BCLS
        | FUNCTION tip FUNC_ID args BOPN BCLS
        ;
tip : INT {$$=$1;}
    | FLOAT {$$=$1;}
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
      | function_call
      ;
function_call : EVAL POPN expr PCLS SEMIC {$$=$3; printf("number is %d\n",$$);}
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
 
expression_stmt : declaratie
                ;

expr : expr PLUS expr {$$ = $1 + $3;}
     | expr MINUS expr {$$ = $1-$3;}
     | expr MUL expr {$$ = $1*$3;}
     | expr DIV expr {$$= $1/$3;}
     | POPN expr PCLS {$$=$2;}
     | NUMBER {$$=$1;}
     | ID {$$=getValue($1);}
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

declaratie :tip ID SEMIC {}
           | tip ID EQ NUMBER SEMIC {declare_with_init($1,$2,$4);}
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
