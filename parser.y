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

int reference_exist(char *alias);
void full_reference(char *alias, char *full);
void new_reference(char *alias);
char *concat(int count, ...);

int len;
char *title;

char *math_string;
char *pch;

int ref_index = 0;

FILE *f;

/**
 * Structs
 */
struct bibitem {
  char *alias;
  char *full;
  int number;
  struct bibitem *next;
};

struct bibitem *bibl;
struct bibitem *current;
struct bibitem *end;


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
          fprintf(f, "<h1>%s</h1>\n", title);
        }
        | T_BEGIN_DOC {
          fprintf(f, "<html>\n<head>\n<script type='text/x-mathjax-config'>MathJax.Hub.Config({tex2jax: {inlineMath: [['$','$'],['\\(','\\)']]}});</script>\n");
          fprintf(f, "<script type='text/javascript' src='http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_HTML-full'></script>\n</head>\n");
          fprintf(f, "<body>\n\n");
        }
        | T_END_DOC {
          fprintf(f, "\n\n</body>\n</html>\n");
        }
        | T_INCLUDEGRAPHICS T_LBRACE T_P T_RBRACE {
          fprintf(f, "<img src=\"%s\" />\n", $3);
        }
        | T_BEGIN_BIB freespace_list {
          fprintf(f, "<h3>The Bibliography</h3>\n<ol>\n");
        }
        | T_END_BIB freespace_list {
          fprintf(f, "</ol>\n");
        }
        | T_BIB_ITEM T_LBRACE T_P T_RBRACE T_P freespace_list {
          full_reference($3, $5);
          current = bibl;
          while (current->next != NULL) {
            current = current->next;
            if (!strcmp(current->alias, $3)) {
              fprintf(f, "<li>%s</li>\n", current->full);
            }
          }
        }
        | T_NEWLINE
        | T_SPACE
        | text_list T_NEWLINE T_NEWLINE {
          fprintf(f, "<p>\n%s\n</p>\n", $1);
        }
;

text_list:  text_list T_NEWLINE text { $$ = concat(3, $1, " ", $3); }
            | text_list T_SPACE text { $$ = concat(3, $1, " ", $3); }
            | text_list text { $$ = concat(2, $1, $2); }
            | text { $$ = $1; }
;

text:   T_MATH T_P T_MATH {
          $$ = concat(3, "$", $2, "$");
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
          new_reference($3);
          $$ = concat(3, "%", $3, "%");
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
 * Functions
 */

int reference_exist(char *alias) {
  struct bibitem *current;
  current = bibl;
  
  while (current->next != NULL) {
    current = current->next;
    if (!strcmp(current->alias, alias)) {
      return 1;
    }
  }
  return 0;

}

void full_reference(char *alias, char *full) {
  struct bibitem *current, *new_ref;
  int i;
  
  current = bibl;
  while (current->next != NULL) {
    current = current->next;
    if (!strcmp(current->alias, alias)) {
      current->full = full;
      current->number = ++ref_index;
      return;
    }
  }
  
  new_ref = (struct bibitem*) malloc (sizeof(struct bibitem));
  new_ref->alias = alias;
  new_ref->full = full;
  new_ref->number = ++ref_index;
  new_ref->next = NULL;
  
  // Insertion always in the end of linked list.
  end->next = new_ref;
  end = new_ref;
  
  return;
}

void new_reference(char *alias) {
  struct bibitem *new_ref;
  
  if (reference_exist(alias))
    return;
  
  new_ref = (struct bibitem*) malloc (sizeof(struct bibitem));
  new_ref->alias = alias;
  new_ref->full = '\0';
  new_ref->number = 0;
  new_ref->next = NULL;
  
  // Insertion always in the end of linked list.
  end->next = new_ref;
  end = new_ref;
  
  return;
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
  char buffer[200] = { };
  char number[10] = { };
  char *search;
  char *replacer;
  
  bibl = NULL;
  bibl = (struct bibitem*) malloc (sizeof(struct bibitem));
  if (bibl == NULL) fprintf(stderr, "ERRO DE ALOCACAO: bibl\n");
  
  bibl->alias = '\0';
  bibl->full = '\0';
  bibl->number = 0;
  bibl->next = NULL;
  
  end = bibl;
  
  f = fopen("output.html", "w");
  
  yyparse();
  
  fclose(f);
  
  /*
   * The idea here in this commented block was to search and replace directly
   * from shell script using 'strcat' and 'sprintf' functions to create the
   *  command and system to call it and execute it.
   * 
   * References:
   * http://forums.devshed.com/unix-help-35/unix-replace-text-files-directory-146179.html#post_message_1135303
   * https://www.gidforums.com/t-7414.html
   
  current = bibl;
  while (current->next != NULL) {
    current = current->next;
    
    search[0] = '\0';
    strcat(search, "%");
    strcat(search, current->alias);
    strcat(search, "%");
    //puts(search);
    fprintf(stderr, "DEBUG!\n");

    replacer[0] = '\0';
    fprintf(stderr, "DEBUG!\n");
    strcat(replacer, "[");
    fprintf(stderr, "DEBUG!\n");
    sprintf(number, "%d", current->number);
    fprintf(stderr, "DEBUG!\n");
    strcat(replacer, number);
    fprintf(stderr, "DEBUG!\n");
    strcat(replacer, "]");
        
    fprintf(stderr, "DEBUG!\n");
    sprintf(buffer, "perl -pi -e 's/%s/%s/g' output.html", search, replacer);
    fprintf(stderr, "SYSTEM: %s\n", buffer);
  }
   */  
  
  return 0;
}

