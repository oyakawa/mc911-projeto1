/**
 * parser.y
 * Alunos:
 * Davi Uezono - RA097464
 * Gustavo Oyakawa - RA117150
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
%token T_SPACE
%token <str> T_P
/* Tokens de caracteres */
%token T_DOLLAR

%type <str> text_list text list item_list item

%start stmt_list

%error-verbose

%%
/* Declaração da gramática */

stmt_list:  stmt_list stmt 
            | stmt 
;

stmt:   T_TITLE T_LBRACE T_P T_RBRACE {
            //printf("Found title: %s\n", $3);
          }
        | T_MAKETITLE {
            //printf("MAKETITLE\n");
          }
        | T_BEGIN_DOC {
            //printf("BEGIN_DOC\n");
          }
        | T_END_DOC {
            //printf("END_DOC\n");
          }
        | T_INCLUDEGRAPHICS T_LBRACE T_P T_RBRACE{
            printf("<img src=\"%s\" />\n", $3);
          }
        | T_BEGIN_BIB
        | T_END_BIB
        | T_BIB_ITEM T_LBRACE T_P T_RBRACE T_P
        | T_NEWLINE
        | T_SPACE
        | text_list T_NEWLINE T_NEWLINE {
            printf("<p>\n%s\n</p>\n", $1);
          }
;

text_list:  text_list T_NEWLINE text { $$ = concat(3, $1, " ", $3); }
            | text_list T_SPACE text { $$ = concat(3, $1, " ", $3); }
            | text_list text { $$ = concat(2, $1, $2); }
            | text { $$ = $1; }
;

text:   T_MATH T_P T_MATH {
            $$ = concat(3,"<span class=\"MathJax\">", $2, "</span>");
          }
        | T_DOLLAR {
            //printf("T_DOLLAR");
            $$ = "$";
          }
        | T_P {
            $$ = $1;
          }
        | T_TEXTBF T_LBRACE T_P T_RBRACE {
            $$ = concat(3, "<strong>", $3, "</strong>");
          } 
        | T_TEXTIT T_LBRACE T_P T_RBRACE { 
            $$ = concat(3, "<em>", $3, "</em>"); 
          } 
        | list {
            $$ = $1;
          }
        | T_CITE T_LBRACE T_P T_RBRACE {
            $$ = "";
          }
;

list:   T_BEGIN_ITEMIZE freespace_list item_list freespace_list T_END_ITEMIZE {
            $$ = concat(3, "\n<ul>", $3, "\n</ul>");
          }
;

item_list:  item_list freespace_list item {
                $$ = concat(2, $1, $3);
              }
            | item {
                $$ = $1;
              }
;

item:       T_ITEM T_P {                
                printf("item: %s\n",$2);
                $$ = concat(3,"\n<li>",$2,"</li>");
              }
            | list { $$ = $1; }
;

freespace_list: freespace_list freespace
                | freespace
;

freespace:  T_NEWLINE | T_SPACE
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