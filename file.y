%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include<sys/types.h>
#include<sys/stat.h>

extern FILE* yyin;
extern char* yytext;
extern int yylineno;

int fd;
struct function{
    char *type;
    char * name;
    char * args;
};
struct function functions[500];
int f = 0; int f_s=0;
struct var{
    int value;
    char * type;
    char * name;
    char * str;
    int constant;
    int changed;
};
struct var vars[500];
int k =0 ; int k_s=0;
int accept =1;
void table_printf(char *scope){
    
    char container[100];
    bzero(container,sizeof(container));
    sprintf(container,"Defined Variables ");
    write(fd,scope,strlen(scope));
    write(fd,"\n",1);
    write(fd,container,strlen(container));
    write(fd,"\n",1);
    for(int i = k_s;i<k;i++){
        write(fd,"\t",1);
        if(vars[i].constant ==1){
            write(fd,"constant ",9);
        }

        write(fd,vars[i].type,strlen(vars[i].type));
        bzero(container,sizeof(container));
        write(fd," ",1);
        write(fd,container,strlen(container));
        write(fd,vars[i].name,strlen(vars[i].name));
        if(vars[i].changed==1){
    
            if(strcmp(vars[i].type,"int")==0){
                sprintf(container,"= %d ",vars[i].value);
            }
            else if (strcmp(vars[i].type,"float")==0){
                sprintf(container,"= %d ",vars[i].value);
            }
            else if(strcmp(vars[i].type,"bool")==0){
                sprintf(container,"= %d ",vars[i].value);
            }
            else if(strcmp(vars[i].type,"string")==0){

                printf("%s\n",vars[i].str);
                sprintf(container,"= %s ",vars[i].str);
            }
            else if(strcmp(vars[i].type,"char")==0){
                sprintf(container,"= %s ",vars[i].str);
            }
            write(fd,container,strlen(container));
        }
        write(fd,"\n",1);
    }
    k_s=k;
    bzero(container,sizeof(container));
    sprintf(container,"Defined Functions\n");
    write(fd,scope,strlen(scope));
    write(fd,"\n",1);
    write(fd,container,strlen(container));
    write(fd,"as\n",3);
    for(int i = f_s;i<f;i++){
        write(fd,vars[i].name,strlen(vars[i].name));
        write(fd,"\n",1);
    }
    write(fd,"\n\n",2);
    f_s = f;
}
void isAccepted(){
    if(accept==1){
        printf("Code is accepted\n");
    }
    else{
        printf("Code is not accepted\n");
    }
}

void eval (int notEmpty, int value){

        if(notEmpty==1){
            if(accept==1)
                printf("Value of @eval at line %d is %d \n",yylineno,value);
        }else
        {
            printf("Nothing in expresion at line %d \n",yylineno);
        }
}

int isDeclared(char * name,int declare){
    if(k==0 && declare==1){
        return -1;
    }
    for(int i=0;i<k;i++){
        if(strcmp(name,vars[i].name)==0){
            return k;
        }
    }
    return -1;
}

void declare(char * type, char * name,int value,char * str, int constant,int init,int isString){
    int ok;
    if(isString){
        if(strcmp(type,"string")==0||strcmp(type,"char")==0)
            ok=1;
        else 
            ok=0;
    }else{
        if(strcmp(type,"int")==0||strcmp(type,"float")==0||strcmp(type,"bool")==0)
            ok = 1;
        else   
            ok = 0;
    }
    if(init==0){ok=1;}
    if(ok==1&&isDeclared(name,1)==-1){
        vars[k].type = strdup(type);
        vars[k].name = strdup(name);
        if(init==1){

            if(isString==1){
                printf(" what %s\n",str);
                vars[k].str=strdup(str);
            }else{
                vars[k].value = value;
            }
                vars[k].changed=1;
            
            } 
        else {
            vars[k].changed=0;}
        
        vars[k].constant=constant;
        ++k;
    }
    else{
        accept=0;
        printf("LineNo: %d : \n",yylineno);
        if(ok==1){
            printf("\tRedeclaration of %s \n",name);
        }
        else{
            printf("\tBad assigment\n");
        }
    }
}

int getPosition(char * name){
    for(int i =0 ;i<k;i++){
        if(strcmp(name,vars[i].name)==0){
            return i;
        }
    }    
    return -1;
}
int getValue(char * name){
    int position =getPosition(name);
    if(position==-1){
        accept = 0;
        printf("LineNo: %d : \n",yylineno);
        printf("\t-No declaration of %s\n",name);
        return -1;
    }
    else if(vars[position].changed==0)
        {accept =0;
        printf("LineNo: %d : \n",yylineno);
        printf("\t-No initialiazation of %s\n",name);
        return -1;
    }
    else if(strcmp(vars[position].type,"int")!=0){
        accept =0 ;
        printf("LineNo: %d : \n",yylineno);
        printf("\t-No matching type\n" );
        return -1;
    }
    else{
        return vars[position].value;
    }
}

%}
%token STR_ATRIB CONCAT TO LENGTH CLASS_ID VECID FLOATVAL CHARVAL FALSE TRUE DOT FLOAT BOOL CHAR INT STRINGTYPE CLASS STRING ID BOPN BCLS SEMIC EQ NUMBER CONST POPN PCLS COMMA MAIN IF ELSE WHILE FOR LO GT LOEQ GTEQ EQEQ NOTEQ AND OR NOT PLUS MINUS DIV MUL ENDIF ENDWHILE ENDFOR DECR INCR FUNCTION FUNC_ID EVAL CALL VECTOR RETURN
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
%type <num> boolval expr NUMBER eval 
%type <str> ID FLOAT INT BOOL CHAR STRING tip STRINGTYPE
%%
start : progr {isAccepted();}
      ;
progr :  classes functii main
        | classes main 
        | functii main
        | main
      ;
functii : functii functie
        | functie
        ;

classes : classes class
        | class
        ;
class : CLASS CLASS_ID BOPN declaratii BCLS 
      | CLASS CLASS_ID BOPN BCLS
      ;
declaratii : declaratie 
           | declaratii declaratie 
           ;
functie : FUNCTION tip FUNC_ID POPN PCLS BOPN blocks BCLS
        |FUNCTION tip FUNC_ID POPN parameters PCLS BOPN blocks BCLS
        ;
parameters : param COMMA parameters
           | param
           ;
function_call : CALL FUNC_ID POPN parameters_call PCLS
              ;
parameters_call : param_call COMMA parameters_call
                | param_call
                ;
param_call : expr
           | FUNC_ID
           |STRING
           ;
boolval : FALSE {$$=0;}
        | TRUE {$$=1;}
        ;

param : tip ID 
      | CONST ID
      | FUNCTION tip FUNC_ID
      ;
      
tip : INT {$$=$1;}
    | FLOAT {$$=$1;}
    | BOOL {$$=$1;}
    | STRINGTYPE {$$=$1;}
    | CHAR {$$=$1;}
    ;

bgn_main :FUNCTION INT MAIN POPN PCLS
         ;
main : bgn_main BOPN blocks BCLS {table_printf("global");}
     | bgn_main BOPN BCLS
     ;

blocks : block
       | blocks block
       ;
block : statements
      | eval
      |string_functions
      | function_call
      ;
eval : EVAL POPN expr PCLS  {eval(1,$3);}
     | EVAL POPN PCLS {eval(0,0);}
     ;
if_stmt :  IF POPN condition PCLS BOPN blocks BCLS ENDIF
      | IF POPN condition PCLS BOPN blocks BCLS ELSE BOPN blocks BCLS ENDIF
      | IF POPN condition PCLS BOPN BCLS ELSE BOPN blocks BCLS ENDIF
      ;

for_stmt : FOR statements TO op BOPN blocks BCLS ENDFOR
         ;

while_stmt : WHILE POPN condition PCLS BOPN blocks BCLS ENDWHILE
           ;

statements : expression_stmt
          | if_stmt 
          | while_stmt
          |for_stmt
          |return_stmt
          ;
return_stmt : RETURN op
            ;
 
expression_stmt : declaratie
                | assign
                ;

expr : expr PLUS expr {$$ = $1 + $3;}
     | expr MINUS expr {$$ = $1-$3;}
     | expr MUL expr {$$ = $1*$3;}
     | expr DIV expr {$$= $1/$3;}
     | POPN expr PCLS {$$=$2;}
     | ID {$$=1;}
     | NUMBER {$$=$1;}
     |boolval {$$=$1;}
     ;
declaratie :tip ID  {declare($1,$2,0,"",0,0,0);}
           |tip ID EQ expr  {declare($1,$2,$4,"",0,1,0);}
           | CONST tip ID EQ expr  {declare($2,$3,$5,"",1,1,0);}
           | CONST tip ID  {declare($2,$3,0,"",1,0,0);}
           | tip ID EQ STRING  {}
           | tip ID EQ FLOATVAL {}
           | tip ID EQ CHARVAL {}
           | CONST tip ID EQ FLOATVAL {}
           | CONST tip ID EQ CHARVAL {}
           | CLASS_ID ID {}
           | VECTOR tip VECID {}
           | VECTOR tip VECID ':' '['list ']' {}
           | VECTOR tip VECID ':' '['']' {}
           ;
assign : ID EQ expr
       | ID INCR
       | ID DECR
       |INCR ID
       |DECR ID
       |ID EQ string_functions
       |VECID '['NUMBER ']' EQ op
       |ID STR_ATRIB ID EQ op
       ;
list : list COMMA op
     | op
     ;
string_functions : CONCAT POPN ID COMMA ID PCLS
                 | CONCAT POPN ID COMMA STRING PCLS
                 | LENGTH POPN ID PCLS
                 | LENGTH POPN STRING PCLS
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
   | STRING
   | CHARVAL
   | FLOATVAL
   | boolval
   ;
%%
int yyerror(char * s){
    printf("eroare: %s la linia:%d\n",s,yylineno);
}

int main(int argc, char** argv){
    truncate("symbol_table.txt",0);
    fd = open("symbol_table.txt", O_WRONLY );
    yyin=fopen(argv[1],"r");
    yyparse();
    close(fd);
} 
