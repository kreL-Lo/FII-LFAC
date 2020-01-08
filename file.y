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
int count_functii=0;

int f = 0; int f_s=0;
struct var{
    int value;
    char * type;
    char * name;
    char * str;
    int constant;
    int changed;
    int func_type;
};
struct container{
    char *id ;
    char *tip;
    int constant;
    int func_type;
    int isId;
}contain[100];

struct function{
    char *type;
    char * name;
    //container unde retin parametri
    struct container contain[100];
    int nr_args;
    int nr_vars;
    //variabile
    struct var vars[500];
};

struct function functions[500];
int k =0 ; int k_s=0;
int accept =1;
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
//count_functii reprezinta in ce functie suntem la momentul curent
int isDeclared(char * name,int declare,int scope){
    if(k==0 && declare==1){
        return -1;
    }
    for(int i=0;i<k;i++){
        if(strcmp(name,functions[scope].vars[i].name)==0){
            return i;
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

void declare(char * type, char * name,int value,char * str, int constant,int init,struct filter filt,int scope,int func_type);
void filter_declaration(int nr,char * type, char * name, int value, char * str,int init, int constant, int scope, int func_type){
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
    declare(type,name,value,str,constant,init,filt,scope,func_type);
    }
}
int getPosition(char * name,int scope);
void declare(char * type, char * name,int value,char * str, int constant,int init,struct filter filt,int scope, int func_type){
    if(accept==1){
        int declared = 0;
        int sameValue=0;
        int p = getPosition(name,scope);
        if(p!=-1){
            declared=1;
        }
        if(declared==0){
            if(init==1){
                
                if(func_type==0){
                    functions[scope].vars[k].func_type=0;    
                    printf("%s %s \n",type,name);
                    if(strcmp(type,"int")==0){
                            if(filt.integer==1){
                                functions[scope].vars[k].changed=1;
                                sameValue=1;
                                functions[scope].vars[k].value=value;
                            }   
                    }
                    else if(strcmp(type,"bool")==0){
                        if(filt.integer==1)
                        {
                            if(value==0||value==1){
                                functions[scope].vars[k].value=value;
                                functions[scope].vars[k].changed=1;
                                sameValue=1;
                            }
                        }
                    }
                    else if(strcmp(type,"char")==0){
                        if(filt.character==1){
                            sameValue=1;
                            functions[scope].vars[k].changed=1;
                            functions[scope].vars[k].str = strdup(str);
                        }
                    }
                    else if(strcmp(type,"string")==0){
                        if(filt.string==1){
                            sameValue=1;
                            functions[scope].vars[k].changed=1;
                            functions[scope].vars[k].str = strdup(str);
                        }
                    }
                    else if(strcmp(type,"float")==0){
                        if(filt.floating==1){
                            sameValue=1;
                            functions[scope].vars[k].changed=1;
                        }
                    }
                }
                else{
                    sameValue=1;
                    printf("%s %s  \n",name,type);
                    functions[scope].vars[k].name=strdup(name);
                    functions[scope].vars[k].type = strdup(type);
                    functions[scope].vars[k].func_type=1;    
                    ++k;
                }
                if(sameValue){
                    functions[scope].vars[k].name=strdup(name);
                    functions[scope].vars[k].type = strdup(type);
                    functions[scope].vars[k].constant = constant;
                    functions[scope].vars[k].func_type=0;    
                    ++k;
                
                }
            }
            else{
                sameValue=1;
                functions[scope].vars[k].func_type = 0;
                functions[scope].vars[k].name=strdup(name);
                functions[scope].vars[k].type = strdup(type);
                ++k;
                
            }
        }
    functions[scope].nr_vars=k;
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
int getPosition(char * name,int scope){
    for(int i =0 ;i<k;i++){
        
        if(strcmp(name,functions[scope].vars[i].name)==0){
            return i;
        }
    }    
    return -1;
}
int getValue(char * name,int scope){
    if(accept==1){
    int position =getPosition(name,scope);
    if(position==-1){
        accept = 0;
        printf("LineNo: %d : \n",yylineno);
        printf("\t-No declaration of %s\n",name);
        return -1;
    }
    else if(functions[scope].vars[position].changed==0)
        {accept =0;
        printf("LineNo: %d : \n",yylineno);
        printf("\t-No initialiazation of %s\n",name);
        return -1;
    }
    else if(strcmp(functions[scope].vars[position].type,"int")!=0){
        accept =0 ;
        printf("LineNo: %d : \n",yylineno);
        printf("\t-No matching type\n" );
        return -1;
    }
    else{
        return functions[scope].vars[position].value;
    }
    }else
        return -1;
}

int decr_incr( char * name ,int nr,int scope){
    int position = getPosition(name,scope);
    if(position==-1){
        accept = 0;
        printf("LineNo: %d : \n",yylineno);
        printf("\t-No declaration of %s\n",name);
        return -1;
    }else{
        if(strcmp(functions[scope].vars[position].type,"int")==0){
            if(nr==0){
                functions[scope].vars[position].value +=1;
            }
            else{
                functions[scope].vars[position].value -=1;
            }
            return functions[scope].vars[position].value;
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
void assignment(char * name,  int value , char * str,int nr,int scope){
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
    int position=getPosition(name,scope);
    if(position==-1){
        accept =0;
        printf("LineNo: %d : \n",yylineno);
        printf("\t-No declaration of %s\n",name);
    }
    else{
        int someValue = 0;
        if(strcmp(functions[scope].vars[position].type,"int")==0){
            if(nr==0){
                someValue=1;
                functions[scope].vars[position].value=value;
                functions[scope].vars[position].changed=1;
            }
        }   
        else if (strcmp(functions[scope].vars[position].type,"string")==0){
            if(nr==1){
                someValue=1;
                functions[scope].vars[position].str= strdup(str);
                functions[scope].vars[position].changed=1;
            }
        }
        else if (strcmp(functions[scope].vars[position].type,"string")==0){
            if(nr==2){
                someValue=1;
                functions[scope].vars[position].str= strdup(str);
                functions[scope].vars[position].changed=1;
            }
        }else if (strcmp(functions[scope].vars[position].type,"float")==0){
            if(nr==3){
                someValue=1;
                functions[scope].vars[position].changed=1;
            }
        }
        else if (strcmp(functions[scope].vars[position].type,"char")==0){
            if(nr==4){
                someValue=1;
                functions[scope].vars[position].str= strdup(str);
            }
        }
        else if (strcmp(functions[scope].vars[position].type,"bool")==0){
            if(nr==0){
                if(value==0||value==1){
                    someValue=1;
                    functions[scope].vars[position].str= strdup(str);
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


char * getStringval(char * name,int scope){
    int position =getPosition(name,scope);
    if(position==-1){
        accept = 0;
        printf("LineNo: %d : \n",yylineno);
        printf("\t-No declaration of %s\n",name);
        return "";
    }
    else if(functions[scope].vars[position].changed==0)
        {accept =0;
        printf("LineNo: %d : \n",yylineno);
        printf("\t-No initialiazation of %s\n",name);
        return "";
    }
    else if(strcmp(functions[scope].vars[position].type,"string")!=0){
        accept =0 ;
        printf("LineNo: %d : \n",yylineno);
        printf("\t-No matching type\n" );
        return "";
    }
    else{
        return functions[scope].vars[position].str;
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


void concat_id_id(char * id1,char *id2,int scope){
    if(accept==1){
        int p1 = getPosition(id1,scope);
        int p2 = getPosition(id2,scope);
        if(p1!=-1&&p2!=-1){
            if(strcmp(functions[scope].vars[p1].type,functions[scope].vars[p2].type)==0&&strcmp(functions[scope].vars[p1].type,"string")==0){
                functions[scope].vars[p1].changed=1;
                strcat(functions[scope].vars[p1].str,functions[scope].vars[p2].str);
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

void concat_id_str(char * id1,char *str,int scope){
    if(accept==1){
        int p1 = getPosition(id1,scope);
        if(p1!=-1){
            if(strcmp(functions[scope].vars[p1].type,"string")==0){
                functions[scope].vars[p1].changed=1;
                strcat(functions[scope].vars[p1].str,str);
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

int str_length(char * id1,int nr,int scope){
    if(accept==1){
        if(nr==0){
        int p1 = getPosition(id1,scope);
            if(p1!=-1){

                if(strcmp(functions[scope].vars[p1].type,"string")==0){
                    return strlen(functions[scope].vars[p1].str);
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

int eq_str( char * id1, char *id2, int nr ,int scope){
    if(accept==1){
        if(nr==0){ // id id
            int p1 = getPosition(id1,scope);
            int p2 = getPosition(id2,scope);
            if(p1!=-1&&p2!=-1){
                if(strcmp(functions[scope].vars[p1].type,functions[scope].vars[p2].type)==0&&strcmp(functions[scope].vars[p1].type,"string")==0){
                    return strcmp(functions[scope].vars[p1].str,functions[scope].vars[p2].str);
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
            int p1 = getPosition(id1,scope);
            if(p1!=-1){
                if(strcmp(functions[scope].vars[p1].type,"string")==0){
                    return strcmp(functions[scope].vars[p1].str,id2);
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
            int p2 = getPosition(id2,scope);
            if(p2!=-1){
                if(strcmp(functions[scope].vars[p2].type,"string")==0){
                    return strcmp(functions[scope].vars[p2].str,id1);
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


void push_str(char * str,char * str1,int nr){
    if(nr==0){
        //basic variable
        contain[count].id=strdup(str1);
        contain[count].tip=strdup(str);
        contain[count].constant =0;
        contain[count].func_type =0;
        }
        else if(nr ==1){
        //constant variable
        contain[count].id=strdup(str1);
        contain[count].tip=strdup(str);
        contain[count].constant =1;
        contain[count].func_type =0;

    }else{ 
        //function
        contain[count].id=strdup(str1);
        contain[count].constant =0;
        contain[count].func_type =1;
    }
    ++count;

}

void eq_functions(int k,char * name, char * type ,int nr){
    // bag din container in functions la pozitia k 
    functions[k].name=strdup(name);
    functions[k].type=strdup(type);
    if(nr==0){
    for(int i =0;i<count;i++){
        functions[k].contain[i]=contain[i];
        functions[k].nr_args=count;
    }}
    else{
        functions[k].nr_args=0;
    }


}
void function_declaration( char * type, char * name ,int nr){
    if(accept==1){
    int p=getPositionFunction(name);
    if(p==-1){
        eq_functions(f,name,type,nr);
        ++f;
    }
    else{
        int ok=1;
        for(int i =0;i<f;i++){
            if(strcmp(functions[i].type,type)==0){
                if(functions[i].nr_args==count){
                    ok=0;
                    break;
                }   
            }
        }
        if(ok==0){
            printf("LineNo: %d : \n",yylineno);
            printf("\t There is another function with the same number of parameters\n");
            accept=0;
        }
        else{
            eq_functions(f,name,type,nr);
        ++f;
        }
    }

        count=0;
    }
}

void check_function(char * name){
    int p=getPositionFunction(name);
    if(p==-1){
        printf("LineNo: %d : \n",yylineno);
        printf("\t There is no function in program with the name %s \n",name);
        accept = 0;
    }
}
struct param_call{
    char *id ;
    int isType[5];
}p_call[100];
void push_param_call(char *str, int nr)
{
    for(int i =0;i<5;i++)
        p_call[count].isType[i]=0;
    p_call[count].isType[nr]=1;
    if(nr==0||nr==3){
        p_call[count].id=strdup(str);
    }
    ++count;
}



int check_function_id(char * str,int i, int j,int scope){
    int p =getPosition(str,scope);    
    if(p==-1){
        printf("LineNo: %d : \n",yylineno);
        printf("\t No initialization of  %s \n",str);
        accept=0;
        return -1;
    }
    
    //printf("%s\n",contain[p].tip);
    str = contain[p].tip;
    if(strcmp(functions[i].contain[j].tip,str)==0){
        return 1;
    }
    return -1;
}

int check_function_nr(int i,int j,int scope ){
    if(strcmp(functions[i].contain[j].tip,"bool")==0||
    strcmp(functions[i].contain[j].tip,"int")==0){
        return 1;
    }
    return -1;
}

int check_function_string(int i,int j,int scope){
    if(strcmp(functions[i].contain[j].tip,"string")==0
    ||strcmp(functions[i].contain[j].tip,"char")==0)
    {
        return 1;
    }
    return -1;
}

int check_function_float(int i,int j,int scope ){
    
    if(strcmp(functions[i].contain[j].tip,"float")==0){
        return 1;
    }
    return -1;
}

int check_function_fuc(char * str ,int i,int j,int scope){
    int p =getPosition(str,scope);    
    if(p==-1){
        printf("LineNo: %d : \n",yylineno);
        printf("\t No initialization of  %s \n",str);
        accept=0;
        return -1;
    }
    str = contain[p].tip;
    if(strcmp(functions[i].contain[j].tip,str)==0){
        return 1;
    }
    return -1;
}

void function_call(int scope,char * name){
    if(accept==1){
    int nr_args = count;
    int p = getPositionFunction(name);
    if(p==-1){
        printf("LineNo: %d : \n",yylineno);
        printf("\t There is no function in program with the name %s \n",name);
    }
    else{
        int invalid_nr_agrs=1;
        int invalid_arg=1;
        for(int i =0 ;i<f;i++){
            if(functions[i].nr_args==nr_args){
                for(int j =0 ;j<nr_args;j++){
                    if(p_call[j].isType[0])
                    {
                        printf("1\n");
                        if(check_function_id(p_call[i].id,i,j,scope)==-1){
                            invalid_arg=0;
                            break;
                        }
                    }
                    if(p_call[j].isType[1]){
                        printf("2\n");
                        if(check_function_nr(i,j,scope)==-1){
                            invalid_arg=0;
                            break;
                        }
                    }

                    if(p_call[j].isType[2]){
                        printf("3\n");
                        if(check_function_string(i,j,scope)==-1){
                            invalid_arg=0;
                            break;
                        }
                    }

                    if(p_call[j].isType[3]){
                        printf("4\n");
                        if(check_function_fuc(p_call[i].id,i,j,scope)==-1){
                            invalid_arg=0;
                            break;
                        }
                    }
                    if(p_call[j].isType[4]){
                        printf("5\n");
                        if(check_function_float(i,j,scope)==-1){
                            invalid_arg=0;
                            break;
                        }
                    }

                }
                invalid_nr_agrs=0;
            }
            if(invalid_nr_agrs==0){
                break;
            }
        }
        if(accept==1){
        if(invalid_nr_agrs==1){
            /// nu am gasit
            printf("LineNo: %d : \n",yylineno);
            printf("\t Invalid number of arguments %s \n",name);
            accept = 0;
        }
        else if(invalid_arg==0){
            printf("LineNo: %d : \n",yylineno);
            printf("\t Invalid matching argument of function %s \n",name);
            accept=0;
        }}
    }

    }
}

void check_id(char * str,int scope)
{
    int p =getPosition(str,scope);
    if(p==-1){
        printf("LineNo: %d : \n",yylineno);
        printf("No initialization of %s\n",str);
        accept=0;
    }
}
/////////////////////////////TABLE

char buf[10000];
int size;
void sending(char * text ){
    bzero(buf,sizeof(buf));
    size = strlen(buf);
    write(fd,buf,size);
}
void table_select(){
    /*struct container{
    char *id ;
    char *tip;
    int constant;
    int func_type;
    int isId;
}contain[100];*/
    ////printez functiile declaratte
    int size;
    bzero(buf,sizeof(buf));
    sprintf(buf,"FUNCTIONS \n");
    size = strlen(buf);//
    write(fd,buf,size);
    printf("%d\n",f);
    for(int i=0;i<f;i++){
        write(fd,"\t",1);
        bzero(buf,sizeof(buf));
        sprintf(buf,"%s %s ",functions[i].type, functions[i].name);
        size = strlen(buf);
        write(fd,buf,size);
        write(fd," (",2);
        for( int j =0 ;j<functions[i].nr_args-1;j++){
        bzero(buf,sizeof(buf));
        if(functions[i].contain[j].constant == 1 ){
            bzero(buf,sizeof(buf));
            sprintf(buf,"constant ");
            size = strlen(buf);//
            write(fd,buf,size);
        }
        if(functions[i].contain[j].func_type ){
            bzero(buf,sizeof(buf));
            sprintf(buf,"function ");
            size = strlen(buf);//
            write(fd,buf,size);
        }
            bzero(buf,sizeof(buf));
            sprintf(buf,"%s %s ,",functions[i].contain[j].tip,functions[i].contain[j].id);
            size = strlen(buf);//
            write(fd,buf,size);
        }
        if(functions[i].nr_args>0){
        bzero(buf,sizeof(buf));
            sprintf(buf,"%s %s ",functions[i].contain[functions[i].nr_args-1].tip,functions[i].contain[functions[i].nr_args-1].id);
            size = strlen(buf);//
            write(fd,buf,size);
        }
        write(fd,") \n",3);
////////////variabile pentru fiecare functii 
    }
    bzero(buf,sizeof(buf));
    sprintf(buf,"\nVariabile \n");
    size = strlen(buf);//
    write(fd,buf,size);
    
    for(int i=0;i<f;i++){
        write(fd,"\t",1);
        bzero(buf,sizeof(buf));
        sprintf(buf,"%s \n ",functions[i].name);
        size = strlen(buf);
        write(fd,buf,size);
        printf("h%d\n",functions[i].nr_vars);
        for(int j =0;j<functions[i].nr_vars;j++){
            write(fd,"\t",1);
            write(fd,"\t",1);
            if(functions[i].vars[j].constant){
                bzero(buf,sizeof(buf));
                sprintf(buf,"constant ");
                size = strlen(buf);//
                write(fd,buf,size);
            }

            if(functions[i].vars[j].func_type){
                bzero(buf,sizeof(buf));
                sprintf(buf,"function ");
                size = strlen(buf);//
                write(fd,buf,size);   
            }
            bzero(buf,sizeof(buf));
            sprintf(buf,"%s %s \n\n ",functions[i].vars[j].type,functions[i].vars[j].name);
            size = strlen(buf);
            write(fd,buf,size);
        }

    }



    ////printez variabilile din fiecare functie
}
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
}
%type <num> boolval expr NUMBER eval string_length string_eq condition 
%type <str> ID FLOAT INT BOOL CHAR STRING tip STRINGTYPE CHARVAL  eval_str arg_str param_call FUNC_ID 
%%
start : progr {isAccepted();
if(accept){table_select();}}
      ;
progr :   main
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
functie : FUNCTION tip FUNC_ID POPN PCLS BOPN blocks BCLS {function_declaration($2,$3,1);++count_functii;k=0;}
        |   FUNCTION tip FUNC_ID POPN parameters PCLS BOPN blocks BCLS {function_declaration($2,$3,0);
                                                                        functions[count_functii].nr_vars=k;
                                                                        ++count_functii;
                                                                        k=0;
                                                                            } 
        ;
parameters : param COMMA parameters {}
           | param {}
           ;

param :tip ID {filter_declaration(-1,$1,$2,0,"",0,0,count_functii,0);push_str($1,$2,0);}
      | CONST tip ID {filter_declaration(-1,$2,$3,0,"",0,1,count_functii,0); push_str($2,$3,1);}
      | FUNC_ID {check_function($1);push_str($1,"",3);}
      ;
function_call : CALL FUNC_ID POPN parameters_call PCLS {function_call(count_functii,$2);count =0;}
              ;
parameters_call : param_call COMMA parameters_call {}
                | param_call 
                ;
param_call : ID {check_id($1,count_functii);
                ;push_param_call($1,0);}
           | NUMBER {push_param_call("",1);}
           | STRING {push_param_call("",2);}
           | FUNC_ID {push_param_call($1,3);}
           | FLOATVAL {push_param_call("",4);}
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
         |FUNCTION INT MAIN POPN PCLS
         ;
args_main : parameters
          ;
main : bgn_main BOPN blocks BCLS {function_declaration("funciton","main",1);count =0;++count_functii;k=0;}
     | bgn_main BOPN BCLS {function_declaration("function","main",0);count =0;++count_functii;k=0;}
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
         | ID {$$=strdup(getStringval($1,count_functii));}
         ;

if_stmt :  IF POPN condition PCLS BOPN blocks BCLS ENDIF
      | IF POPN condition PCLS BOPN BCLS ENDIF
      | IF POPN condition PCLS BOPN blocks BCLS ELSE BOPN blocks BCLS ENDIF
      | IF POPN condition PCLS BOPN BCLS ELSE BOPN blocks BCLS ENDIF
      | IF POPN condition PCLS BOPN BCLS ELSE BOPN BCLS ENDIF
      ;

for_stmt : FOR statements TO op BOPN blocks BCLS 
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
     | ID {$$=getValue($1,count_functii);}
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
declaratie :tip ID  {filter_declaration(-1,$1,$2,0,"",0,0,count_functii,0);}
           |tip ID EQ expr  {filter_declaration(0,$1,$2,$4,"",1,0,count_functii,0);}
           | tip ID EQ CHARVAL {filter_declaration(2,$1,$2,0,$4,1,0,count_functii,0);}
           | tip ID EQ STRING  {filter_declaration(3,$1,$2,0,$4,1,0,count_functii,0);}
           |tip ID EQ FUNC_ID {filter_declaration(3,$1,$2,0,$4,1,0,count_functii,1);}
           | tip ID EQ FLOATVAL {filter_declaration(4,$1,$2,0,"",1,0,count_functii,0);}
           | CONST tip ID  {filter_declaration(-1,$2,$3,0,"",0,1,count,0);}
           | CONST tip ID EQ expr {filter_declaration(0,$2,$3,$5,"",1,1,count_functii,0);}
           | CONST tip ID EQ CHARVAL {filter_declaration(2,$2,$3,0,$5,1,1,count_functii,0);}
           | CONST tip ID EQ STRING {filter_declaration(3,$2,$3,0,$5,1,1,count_functii,0);}
           | CONST tip ID EQ FLOATVAL {filter_declaration(4,$2,$3,0,"",1,1,count_functii,0);}
           | CLASS_ID ID {}
           | VECTOR tip VECID {}
           | VECTOR tip VECID ':' '['list ']' {}
           | VECTOR tip VECID ':' '['']' {}
           ;
assign : ID EQ expr {assignment($1,$3,"",0,count_functii);}
       | ID EQ STRING {assignment($1,0,$3,1,count_functii);}
       | ID EQ FLOATVAL {assignment($1,0,"",2,count_functii);}
       | ID EQ CHARVAL {assignment($1,0,$3,3,count_functii);}
       | ID INCR {decr_incr($1,0,count_functii);}
       | ID DECR {decr_incr($1,1,count_functii); }
       |INCR ID {decr_incr($2,0,count_functii);}
       |DECR ID {decr_incr($2,1,count_functii);}
       |ID EQ string_functions 
       |VECID '['NUMBER ']' EQ op
       |ID STR_ATRIB ID EQ op
       ;
list : list COMMA op
     | op
     ;
string_functions : CONCAT POPN ID COMMA ID PCLS {concat_id_id($3,$5,count_functii);}
                 | CONCAT POPN ID COMMA STRING PCLS {concat_id_str($3,$5,count_functii);}
                 ;
string_length : LENGTH POPN ID PCLS {$$=str_length($3,0,count_functii);}
                 | LENGTH POPN STRING PCLS {$$=str_length($3,1,count_functii);}
                 ;
string_eq : EQ_STR POPN ID COMMA ID PCLS {$$=eq_str($3,$5,0,count_functii);} 
          | EQ_STR POPN STRING COMMA STRING PCLS {$$=eq_str($3,$5,1,count_functii);} 
          | EQ_STR POPN ID COMMA STRING PCLS {$$=eq_str($3,$5,2,count_functii);} 
          | EQ_STR POPN STRING COMMA ID PCLS  {$$=eq_str($3,$5,3,count_functii);} 
          ;


condition : expr {if(accept==1){$$=$1;}}
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
