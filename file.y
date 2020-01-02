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
    int nr_args;
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
void eval_string(int notEmpty, char * str ){
    if(accept==1){
        if(notEmpty==1){
            if(accept==1)
                printf("Value of @eval_string at line %d is %s \n",yylineno,str);
        }else
        {
            printf("Nothing in expresion at line %d \n",yylineno);
        }
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
struct filter {
   int integer;
   int boolean;
   int character;
   int string;
   int floating;
};

void declare(char * type, char * name,int value,char * str, int constant,int init,struct filter filt);
void filter_declaration(int nr,char * type, char * name, int value, char * str,int init, int constant){
    if(accept==1){
    struct filter filt={0,0,0,0,0};
    if(init==1){
        if(nr==0){
            filt.integer = 1;
        }else if(nr ==1){
            filt.boolean = 1; 
        }else if(nr==2){
            filt.character =1;
        }else if(nr==3){
            filt.string =1;
        }else if (nr ==4){
            filt.floating=1;
        }
    }
    declare(type,name,value,str,constant,init,filt);
    }
}
void declare(char * type, char * name,int value,char * str, int constant,int init,struct filter filt){
    if(accept==1){
        int declared = 0;
        int sameValue;
        if(isDeclared(name,1)!=-1){
            declared = 1;
        }
        if(declared==0){
            sameValue=0;
            if(init==1){
            if(strcmp(type,"int")==0){
                    if(filt.integer==1){
                        sameValue=1;
                        vars[k].changed=1;
                        vars[k].value=value;
                    }   
            }
            else if(strcmp(type,"bool")==0){
                if(filt.integer==1)
                {
                    if(value==0||value==1){
                        vars[k].value=value;
                        vars[k].changed=1;
                        sameValue=1;
                    }
                }
            }
            else if(strcmp(type,"char")==0){
                if(filt.character==1){
                    sameValue=1;
                    vars[k].changed=1;
                    vars[k].str = strdup(str);
                }
            }
            else if(strcmp(type,"string")==0){
                if(filt.string==1){
                    sameValue=1;
                    vars[k].changed=1;
                    vars[k].str = strdup(str);
                }
            }
            else if(strcmp(type,"float")==0){
                if(filt.floating==1){
                    sameValue=1;
                    vars[k].changed=1;
                }
            }
            }
            else{
                sameValue=1;
            }
            if(sameValue){
                vars[k].name=strdup(name);
                vars[k].type = strdup(type);
                vars[k].constant = constant;
                ++k;
            }
        }

        if(declared==1){
            accept=0;
            printf("LineNo: %d : \n",yylineno);
            printf("\tRedefinition of %s\n",name);
        }
        else if(sameValue==0){
            accept=0;
            printf("LineNo: %d : \n",yylineno);
            printf("\tCan't assing  %s\n",name);
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

int decr_incr( char * name ,int nr){
    int position = getPosition(name);
    if(position==-1){
        accept = 0;
        printf("LineNo: %d : \n",yylineno);
        printf("\t-No declaration of %s\n",name);
        return -1;
    }else{
        if(strcmp(vars[position].type,"int")==0){
            if(nr==0){
                vars[position].value +=1;
            }
            else{
                vars[position].value -=1;
            }
            return vars[position].value;
        }
        else{
            accept =0 ;
            printf("LineNo: %d : \n",yylineno);
            printf("\t-Identifier %s must have an integer type\n",name);
            return -1;
        }
    }
    return -1;
}   
void assignment(char * name,  int value , char * str,int nr){
    if(accept==1){
    struct filter filt={0,0,0,0,0};
    if(nr==0){
            filt.integer = 1;
        }else if(nr ==1){
            filt.boolean = 1; 
        }else if(nr==2){
            filt.character =1;
        }else if(nr==3){
            filt.string =1;
        }else if (nr ==4){
            filt.floating=1;
        }
    int position=getPosition(name);
    if(position==-1){
        accept =0;
        printf("LineNo: %d : \n",yylineno);
        printf("\t-No declaration of %s\n",name);
    }
    else{
        int someValue = 0;
        if(strcmp(vars[position].type,"int")==0){
            if(nr==0){
                someValue=1;
                vars[position].value=value;
                vars[position].changed=1;
            }
        }   
        else if (strcmp(vars[position].type,"string")==0){
            if(nr==1){
                someValue=1;
                vars[position].str= strdup(str);
                vars[position].changed=1;
            }
        }
        else if (strcmp(vars[position].type,"string")==0){
            if(nr==2){
                someValue=1;
                vars[position].str= strdup(str);
                vars[position].changed=1;
            }
        }else if (strcmp(vars[position].type,"float")==0){
            if(nr==3){
                someValue=1;
                vars[position].changed=1;
            }
        }
        else if (strcmp(vars[position].type,"char")==0){
            if(nr==4){
                someValue=1;
                vars[position].str= strdup(str);
            }
        }
        else if (strcmp(vars[position].type,"bool")==0){
            if(nr==0){
                if(value==0||value==1){
                    someValue=1;
                    vars[position].str= strdup(str);
                }
            }
        }
        if(someValue==0){
            accept = 0;
            printf("LineNo: %d : \n",yylineno);
            printf("Types don't match\n");
        }
    }
    }
}


char * getStringval(char * name){
    int position =getPosition(name);
    if(position==-1){
        accept = 0;
        printf("LineNo: %d : \n",yylineno);
        printf("\t-No declaration of %s\n",name);
        return "";
    }
    else if(vars[position].changed==0)
        {accept =0;
        printf("LineNo: %d : \n",yylineno);
        printf("\t-No initialiazation of %s\n",name);
        return "";
    }
    else if(strcmp(vars[position].type,"string")!=0){
        accept =0 ;
        printf("LineNo: %d : \n",yylineno);
        printf("\t-No matching type\n" );
        return "";
    }
    else{
        return vars[position].str;
    }
}

int str_cut(char *str, int begin, int len)
{
    int l = strlen(str);

    if (len < 0) len = l - begin;
    if (begin + len > l) len = l - begin;
    memmove(str + begin, str + begin + len, l - len + 1);

    return len;
}


void concat_id_id(char * id1,char *id2){
    if(accept==1){
        int p1 = getPosition(id1);
        int p2 = getPosition(id2);
        if(p1!=-1&&p2!=-1){
            if(strcmp(vars[p1].type,vars[p2].type)==0&&strcmp(vars[p1].type,"string")==0){
                vars[p1].changed=1;
                strcat(vars[p1].str,vars[p2].str);
            }else{
                accept =0 ;
                printf("LineNo: %d : \n",yylineno);
                printf("Invalid data types \n");
            }
        }else{
            accept = 0;
            printf("LineNo: %d : \n",yylineno);
            printf("One of the values hasn't been declared\n");
        }
    }
}

void concat_id_str(char * id1,char *str){
    if(accept==1){
        int p1 = getPosition(id1);
        if(p1!=-1){
            if(strcmp(vars[p1].type,"string")==0){
                vars[p1].changed=1;
                strcat(vars[p1].str,str);
            }else{
                accept =0 ;
                printf("LineNo: %d : \n",yylineno);
                printf("Invalid data types \n");
            }
        }else{
            accept = 0;
            printf("LineNo: %d : \n",yylineno);
            printf("%s hasn't been declared \n",id1);
        }
    }
}

int str_length(char * id1,int nr){
    if(accept==1){
        if(nr==0){
        int p1 = getPosition(id1);
            if(p1!=-1){

                if(strcmp(vars[p1].type,"string")==0){
                    return strlen(vars[p1].str);
                }else
                {
                    accept=0;
                    printf("\t-No declaration of %s\n",id1);
                    printf("LineNo: %d : \n",yylineno);
                    return -1;
                    
                }
            }
            else{
                accept = 0;
                    printf("LineNo: %d : \n",yylineno);
                    printf("One of the values hasn't been declared\n");
                    return -1;
            }
        }
        else {
            return strlen(id1);
        }
    }
}

int eq_str( char * id1, char *id2, int nr ){
    if(accept==1){
        if(nr==0){ // id id
            int p1 = getPosition(id1);
            int p2 = getPosition(id2);
            if(p1!=-1&&p2!=-1){
                if(strcmp(vars[p1].type,vars[p2].type)==0&&strcmp(vars[p1].type,"string")==0){
                    return strcmp(vars[p1].str,vars[p2].str);
                }
                else{
                    accept = 0;
                    printf("LineNo: %d : \n",yylineno);
                    printf("Identifiers don't have the same type\n");
                    return -1;
                }
            }
            else{
                accept =0;
                printf("LineNo: %d : \n",yylineno);
                printf("One of the values hasn't been declared\n");
                return -1;
            }
        }else if(nr==1){
            return (strcmp(id1,id2));//str str
        }else if(nr==2){ //id str
            int p1 = getPosition(id1);
            if(p1!=-1){
                if(strcmp(vars[p1].type,"string")==0){
                    return strcmp(vars[p1].str,id2);
                }
                else{
                    accept =0 ;
                    printf("LineNo: %d : \n",yylineno);
                    printf("Identifier doesn't have the same type\n");
                    return -1;
                }
            }
            else{
                accept=0;
                printf("LineNo: %d : \n",yylineno);
                printf("No initialization of %s",id1);
                return -1;
            }
        }else if(nr==3){ //str id
            int p2 = getPosition(id2);
            if(p2!=-1){
                if(strcmp(vars[p2].type,"string")==0){
                    return strcmp(vars[p2].str,id1);
                }
                else{
                    accept =0 ;
                    printf("LineNo: %d : \n",yylineno);
                    printf("Identifier doesn't have the same type\n");
                    return -1;
                }
            }
            else{
                accept=0;
                printf("LineNo: %d : \n",yylineno);
                printf("No initialization of %s",id1);
                return -1;
            }
        }
    }
    else{return -1;}
}

int getPositionFunction(char * name){
     for(int i =0 ;i<f;i++){
        if(strcmp(name,functions[i].name)==0){
            return i;
        }
    }    
    return -1;
}
int count = 0;
%}
%token EQ_STR EVAL_STR STR_ATRIB CONCAT TO LENGTH CLASS_ID VECID FLOATVAL CHARVAL FALSE TRUE DOT FLOAT BOOL CHAR INT STRINGTYPE CLASS STRING ID BOPN BCLS SEMIC EQ NUMBER CONST POPN PCLS COMMA MAIN IF ELSE WHILE FOR LO GT LOEQ GTEQ EQEQ NOTEQ AND OR NOT PLUS MINUS DIV MUL ENDIF ENDWHILE ENDFOR DECR INCR FUNCTION FUNC_ID EVAL CALL VECTOR RETURN
%start start
%left AND
%left OR
%left PLUS MINUS
%left MUL DIV
%left NOT
%left LO LOEQ GT GTEQ EQEQ
%union
{
    int num;
    char* str;
    char *args;
}
%type <num> boolval expr NUMBER eval string_length string_eq condition param
%type <str> ID FLOAT INT BOOL CHAR STRING tip STRINGTYPE CHARVAL  eval_str arg_str param_call
struct functions buffer ;
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
functie : FUNCTION tip FUNC_ID POPN PCLS BOPN blocks BCLS {}
        |FUNCTION tip FUNC_ID POPN parameters PCLS BOPN blocks BCLS {printf("first\n");}
        ;
parameters : param COMMA parameters {printf("here%d\n",$1);}
           | param {printf("another\n");printf("here%d\n",$1);}
           ;

param :tip ID {$$=count++;}
      ;
function_call : CALL FUNC_ID POPN parameters_call PCLS
              ;
parameters_call : param_call COMMA parameters_call {}
                | param_call
                ;
param_call : tip ID {}
           ;
boolval : FALSE {$$=0;}
        | TRUE {$$=1;}
        ;


      
tip : INT {$$=$1;}
    | FLOAT {$$=$1;}
    | BOOL {$$=$1;}
    | STRINGTYPE {$$=$1;}
    | CHAR {$$=$1;}
    ;

bgn_main :FUNCTION INT MAIN POPN args_main PCLS
         ;
args_main : 
          ;
main : bgn_main BOPN blocks BCLS {table_printf("global");}
     | bgn_main BOPN BCLS
     ;

blocks : block
       | blocks block
       ;
block : statements
      | eval
      | string_functions
      | function_call
      | eval_str
      ;
eval : EVAL POPN expr PCLS  {eval(1,$3);}
     | EVAL POPN PCLS {eval(0,0);}
     ;
eval_str : EVAL_STR POPN arg_str PCLS {eval_string(1,$3);}
         | EVAL_STR POPN PCLS {eval_string(1,"");}
         ;
arg_str  : STRING {$$=strdup($1);}
         | ID {$$=strdup(getStringval($1));}
         ;

if_stmt :  IF POPN condition PCLS BOPN blocks BCLS ENDIF
      | IF POPN condition PCLS BOPN BCLS ENDIF
      | IF POPN condition PCLS BOPN blocks BCLS ELSE BOPN blocks BCLS ENDIF
      | IF POPN condition PCLS BOPN BCLS ELSE BOPN blocks BCLS ENDIF
      | IF POPN condition PCLS BOPN BCLS ELSE BOPN BCLS ENDIF
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
     | ID {$$=getValue($1);}
     | NUMBER {$$=$1;}
     | boolval {$$=$1;}
     | string_length {$$=$1;}
     | string_eq {$$=$1;}
     | expr AND expr {$$=$1&&$3;}
     | expr OR expr {$$=$1||$3;}
     | NOT expr {$$=!$2;}
     | expr LO expr {$$=$1<$3;}
     | expr GT expr {$$=$1>$3;}
     | expr GTEQ expr {$$=$1>=$3;}
     | expr LOEQ expr {$$=$1<=$3;}
     | expr EQEQ expr {$$=$1==$3;}
     ;
declaratie :tip ID  {filter_declaration(-1,$1,$2,0,"",0,0);}
           |tip ID EQ expr  {filter_declaration(0,$1,$2,$4,"",1,0);}
           | tip ID EQ CHARVAL {filter_declaration(2,$1,$2,0,$4,1,0);}
           | tip ID EQ STRING  {filter_declaration(3,$1,$2,0,$4,1,0);}
           | tip ID EQ FLOATVAL {filter_declaration(4,$1,$2,0,"",1,0);}
           | CONST tip ID  {filter_declaration(-1,$2,$3,0,"",0,1);}
           | CONST tip ID EQ expr {filter_declaration(0,$2,$3,$5,"",1,1);}
           | CONST tip ID EQ CHARVAL {filter_declaration(2,$2,$3,0,$5,1,1);}
           | CONST tip ID EQ STRING {filter_declaration(3,$2,$3,0,$5,1,1);}
           | CONST tip ID EQ FLOATVAL {filter_declaration(4,$2,$3,0,"",1,1);}
           | CLASS_ID ID {}
           | VECTOR tip VECID {}
           | VECTOR tip VECID ':' '['list ']' {}
           | VECTOR tip VECID ':' '['']' {}
           ;
assign : ID EQ expr {assignment($1,$3,"",0);}
       | ID EQ STRING {assignment($1,0,$3,1);}
       | ID EQ FLOATVAL {assignment($1,0,"",2);}
       | ID EQ CHARVAL {assignment($1,0,$3,3);}
       | ID INCR {decr_incr($1,0);}
       | ID DECR {decr_incr($1,1); }
       |INCR ID {decr_incr($2,0);}
       |DECR ID {decr_incr($2,1);}
       |ID EQ string_functions 
       |VECID '['NUMBER ']' EQ op
       |ID STR_ATRIB ID EQ op
       ;
list : list COMMA op
     | op
     ;
string_functions : CONCAT POPN ID COMMA ID PCLS {concat_id_id($3,$5);}
                 | CONCAT POPN ID COMMA STRING PCLS {concat_id_str($3,$5);}
                 ;
string_length : LENGTH POPN ID PCLS {$$=str_length($3,0);}
                 | LENGTH POPN STRING PCLS {$$=str_length($3,1);}
                 ;
string_eq : EQ_STR POPN ID COMMA ID PCLS {$$=eq_str($3,$5,0);} 
          | EQ_STR POPN STRING COMMA STRING PCLS {$$=eq_str($3,$5,1);} 
          | EQ_STR POPN ID COMMA STRING PCLS {$$=eq_str($3,$5,2);} 
          | EQ_STR POPN STRING COMMA ID PCLS  {$$=eq_str($3,$5,3);} 
          ;


condition : expr {if(accept==1){$$=$1;printf("%d\n",$$);}}
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
