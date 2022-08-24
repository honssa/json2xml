%{
    #include<stdio.h>
    #include<stdlib.h>
    #include<string.h>
    #include"json.h"

    int yylex();
    void yyerror (char const *);
    char* int_to_str(int x);
    extern int yylineno;    /* Esto e para que funcione o contador de linhas */
    FILE *fp;               /* Ficheiro no que escribimos a traduccion a xml*/
    char buffer[500];
    char* xml_null = "NULL-VALUE";

    struct Node {
        char *pre;
        char *post;
        struct Node *content;
        struct Node *next;
    };

    struct Node* new_node(); 
    struct Node* start=NULL;
%}
%union {
    char* str;
    int intval;
    struct Node *node;
}
%token <str> TXT COLON CBOPEN CBCLOSE SQBOPEN SQBCLOSE ID NULL_VALUE
%token<str> TYPE_BOOLEAN TYPE_FLOAT TYPE_INTEGER
%token<intval> COMMA
%type <node> instruction_list instruction value obxeto elementos array
%start s

%%
/* Simbolo inicial */
s : obxeto                                        { start = $1; }

obxeto : CBOPEN instruction_list CBCLOSE          { $$ = $2; }



/* Corpo do json : 1 ou n instruccions  */
instruction_list : /* nada */                                   { $$ = NULL; }

                | instruction                                   { $$ = $1; }

                | instruction COMMA instruction_list            {
                                                                    $$ = $1;
                                                                    $1->next = $3;
                                                                }
                ;



/* Formato da instruccion */
instruction : /* nada */                            { $$ = NULL; }

    | ID COLON value                        {
                                                $$=new_node();
                                                $$->pre=(char *)malloc(sizeof(char)*strlen($1)+10);
                                                sprintf($$->pre,"<%s>",$1);
                                                $$->post=(char *)malloc(sizeof(char)*strlen($1)+10);
                                                sprintf($$->post,"</%s>",$1);
                                                $$->content=$3;
                                            }
    ;

array : SQBOPEN SQBCLOSE /*array baleiro*/   { $$ = NULL; }

    | SQBOPEN elementos SQBCLOSE            {
                                              $$ = $2;
                                            }
    ;


elementos : value                           {
                                                $$ = new_node();
                                                char *tmp = (char *)malloc(sizeof(char)*30); strcat(tmp,"<elemento");
                                                strcat(tmp, int_to_str(array_size)); strcat(tmp,">");
                                                $$->pre = tmp;
                                                strcpy(tmp,"</elemento");
                                                strcat(tmp, int_to_str(array_size)); strcat(tmp,">");
                                                $$->post = tmp;
                                                $$->content=$1;
                                            }

    | value COMMA elementos                 {
                                                $$ = new_node();
                                                char *tmp = (char *)malloc(sizeof(char)*30); strcat(tmp,"<elemento");
                                                strcat(tmp, int_to_str($2)); strcat(tmp,">");
                                                $$->pre = tmp;
                                                strcpy(tmp,"</elemento");
                                                strcat(tmp, int_to_str($2)); strcat(tmp,"/>");
                                                $$->post = tmp;
                                                $$->content = $1;
                                                $$->next = $3;
                                            }
    ;

value : obxeto                              { $$ = $1; }

    | TXT                                   {
                                                $$ = new_node(); $$->pre = $1;
                                            }

    | TYPE_BOOLEAN                          {
                                                $$ = new_node(); $$->pre = $1;
                                            }

    | TYPE_FLOAT                            {
                                                $$ = new_node(); $$->pre = strcat($1,"f");
                                            }

    | TYPE_INTEGER                          {
                                                $$ = new_node(); $$->pre = strcat($1,"i");
                                            }

    | NULL_VALUE                            {
                                                $$ = new_node(); $$->pre = xml_null;
                                            }

    | array                                 { $$ = $1;}
    ;


%%


const struct Node def = {NULL,NULL,NULL,NULL};

struct Node* new_node()
{
    struct Node *tmp = (struct Node*)malloc(sizeof(struct Node));
    *tmp=def;
    return tmp;
}

char* int_to_str(int x){
  int length = snprintf(NULL, 0, "%d", x);
  char *str = malloc(length+1);
  snprintf(str,length+1,"%d",x);
  return str;
}

void print_tabs(int n)
{
    for(int i=0; i<n; i++)
        fprintf(fp, "\t");
}


void print_tree(struct Node *tree, int t)
{
  if(tree->pre)
    {
      print_tabs(t);
      fprintf(fp, "%s\n", tree->pre); 
    }
  if(tree->content)
    print_tree(tree->content, t+1);
  if(tree->post)
    {
      print_tabs(t);
      fprintf(fp, "%s\n",tree->post);
    }
  if(tree->next)
    print_tree(tree->next,t);
}
int main() {
    yyparse();
    fp = fopen("output.txt", "w");
    print_tree(start, 0);
    fclose(fp);
    printf("\nJSON -> XML\n");
    return 0;
}