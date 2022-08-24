%x TEXT APE ARRAY
%option yylineno
id [a-zA-Z0-9]+
float -?[0-9]+\.[0-9]+
integer -?[0-9]+

%{
    #include "json.tab.h"
    #include "json.h"
    //int array_counter = 0;
    int array_size = 0;
%}

%%

"{"                                 {/*printf("\nCBOPEN: %s\n", yytext); */return(CBOPEN);}
"}"                                 {/*printf("\nCBCLOSE: %s\n", yytext); */return(CBCLOSE);}
","                                 {/*printf("\nCOMMA: %s\n", yytext); */return(COMMA);}
{id}                                {/*printf("\nID: %s\n", yytext); */yylval.str = strdup(yytext); return(ID);}
":"                                 {/*printf("\nCOLON: %s\n", yytext); */BEGIN(APE); return(COLON);}
\"|\n                               {/* Come todas as comillas ou saltos de linha que atopa */}

<APE>"null"                         { BEGIN(INITIAL); yylval.str = strdup(yytext); return(NULL_VALUE);} 
<APE>"{"                            {/*printf("\nCBOPEN: %s\n", yytext); */BEGIN(INITIAL); return(CBOPEN);}
<APE>\"                             { BEGIN(TEXT); }
<APE>"true"|"false"                 { BEGIN(INITIAL); yylval.str = strdup(yytext); return(TYPE_BOOLEAN);}
<APE>{integer}                      { BEGIN(INITIAL); yylval.str=strdup(yytext); return(TYPE_INTEGER);}
<APE>{float}                        { BEGIN(INITIAL); yylval.str = strdup(yytext); return(TYPE_FLOAT);}
<APE>\[                             { BEGIN(ARRAY); array_size = 0; return(SQBOPEN);}

<ARRAY>{integer}                 { yylval.str = strdup(yytext); return(TYPE_INTEGER);}    
<ARRAY>{float}                   { yylval.str = strdup(yytext); return(TYPE_FLOAT);}
<ARRAY>\"{id}\"                  { yylval.str = strdup(yytext); return(TXT);}
<ARRAY>"null"                    { yylval.str = strdup(yytext); return(TXT);}
<ARRAY>","                       { yylval.intval = array_size; array_size++; return(COMMA); }    
<ARRAY>\]                        { BEGIN(INITIAL); array_size; return(SQBCLOSE);}  
 

<TEXT>[^\"{}]+                      {/*printf("\nTEXT: %s\n", yytext); */yylval.str = strdup(yytext); return(TXT);}
<TEXT>\"                            { BEGIN(INITIAL); }
%%