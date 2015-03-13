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
  
int reference_exist(char *string);
void new_reference(char *string);
char *concat(int count, ...);

int len;
char *title;

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
            len = strlen($3);
            title = (char*) malloc( (len+1) * sizeof(char) );
            strncpy(title, $3, len);
            title[len] = '\0';
          }
        | T_MAKETITLE {
            printf("<h1>%s</h1>\n", title);
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

/**
 * Estruturas
 */
struct bibitem {
  char *alias;
  char *full;
  int number;
  struct bibitem *next;
};

int ref_index = 0;

struct bibitem *bibl;
struct bibitem *end;

/**
 * Funcoes
 */

int reference_exist(char *string) {
  struct bibitem *current;
  current = bibl;
  
  while (strcmp(current->alias, string) != 0) {
    if (current->next == NULL) {
      return 0;
    }
    current = current->next;
  }
  return 1;
}

/** ref_exists implemented as a static vector of bib references
int ref_exists(char *string) {
  int i;
  int len;
  len = sizeof(bibl)/sizeof(struct bibitem);
  for (i = 0; i < len; i++) {
    if (strcmp(bibl[i].alias, string) == 0)
      return 1;
  }
  return 0;
}
*/

void new_reference(char *string) {
  struct bibitem *new_ref;
  int len;
  
  new_ref = (struct bibitem*) malloc (sizeof(struct bibitem));
  len = strlen(string);
  
  strncpy(new_ref->alias, string, len);
  new_ref->alias[len] = '\0';
  new_ref->alias[0] = '\0';
  new_ref->number = ++ref_index;
  new_ref->next = NULL;
  
  // Insertion always in the end of linked list.
  end->next = new_ref;
  end = new_ref;
}

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
  for(i=0 ; i<count ; i++) {
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
  struct bibitem *current;
  
  bibl = NULL;
  bibl = (struct bibitem*) malloc (sizeof(struct bibitem));
  if (bibl == NULL) fprintf(stderr, "ERRO DE ALOCACAO: bibl\n");
  
  bibl->alias = '\0';
  bibl->full = '\0';
  bibl->number = 0;
  bibl->next = NULL;
  
  end = bibl;
  
  yyparse();
  
  current = bibl;
  while (current->alias != '\0') {
    printf("%02d. %s :: %s\n", current->number, current->alias, current->full);
    current = current->next;
  }
  
  if (current->alias == '\0')
    fprintf(stderr, "DEBUG: %s\nSUCCESS!\n", current->alias);
  
  return 0;
  
}