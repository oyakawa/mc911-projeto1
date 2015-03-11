/**
 * projeto1.ypp
 */

%{
#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <stdlib.h>

char *concat(int count, ...);

%}

%union{
	char *str;
}

/* Declaração de tokens */
%token T_TITLE
%token T_MAKETITLE
%token T_TEXTBF
%token T_TEXTIT
%token T_BEGIN_DOC
%token T_END_DOC
%token T_BEGIN_ITEMIZE
%token T_END_ITEMIZE
%token T_ITEM
%token T_INCLUDEGRAPHICS
%token T_CITE
%token T_BEGIN_BIB
%token T_END_BIB
%token T_BIB_ITEM
%token T_MATH
%token T_LBRACE
%token T_RBRACE
%token T_LBRACKET
%token T_RBRACKET
%token T_NEWLINE
%token <str> T_P
/* Tokens de caracteres */
%token T_DOLLAR

%type <str> text_list text

%start stmt_list

%error-verbose

%%
/* Declaração da gramática */

stmt_list:	stmt_list stmt 
			| stmt 
;

stmt:		T_TITLE T_LBRACE text_list T_RBRACE
			| T_MAKETITLE
			| T_BEGIN_DOC
			| T_END_DOC
			| T_BEGIN_ITEMIZE
			| T_END_ITEMIZE
			| T_ITEM T_P
			| T_INCLUDEGRAPHICS T_LBRACE T_P T_RBRACE
			| T_CITE T_LBRACE T_P T_RBRACE
			| T_BEGIN_BIB
			| T_END_BIB
			| T_BIB_ITEM T_LBRACE T_P T_RBRACE T_P
			| text_list
;

text_list:	text_list text
			| text
;

text:		T_MATH text T_MATH { printf("Texto matematico: %s", $2); $$ = $2; }
			| T_DOLLAR { printf("T_DOLLAR"); $$ = "$"; } 
			| T_NEWLINE { $$ = "\n"; }
			| T_NEWLINE T_NEWLINE T_P { printf("\nNovo paragrafo: %s\n", $3); $$ = $3; }
			| T_P { $$ = $1; } 
			| T_TEXTBF T_LBRACE text T_RBRACE { printf("Texto em negrito: %s\n", $3); $$ = $3; } 
			| T_TEXTIT T_LBRACE text T_RBRACE { printf("Texto em italico: %s\n", $3); $$ = $3; } 
;



%%

char* concat(int count, ...) {
    va_list ap;
    int len = 1, i;

    va_start(ap, count);
    for(i=0 ; i<count ; i++)
        len += strlen(va_arg(ap, char*));
    va_end(ap);

    char *result = (char*) calloc(sizeof(char),len);
    int pos = 0;

    // Actually concatenate strings
    va_start(ap, count);
    for(i=0 ; i<count ; i++)
    {
        char *s = va_arg(ap, char*);
        strcpy(result+pos, s);
        pos += strlen(s);
    }
    va_end(ap);

    return result;
}

int yyerror(const char* errmsg) {
	printf("\n*** Erro: %s\n", errmsg);
}
 
int yywrap(void) { return 1; }

int main(int argc, char** argv) {
	//cria tags HTML no arquivo?
	yyparse();
	return 0;
}