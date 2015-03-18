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
int full_reference(char *alias, char *full);
int new_reference(char *alias);
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
        | T_INCLUDEGRAPHICS T_LBRACE T_P T_RBRACE {
          printf("<img src=\"%s\" />\n", $3);
        }
        | T_BEGIN_BIB freespace_list {
          //printf("BEGIN BIBLIOGRAPHY\n");
        }
        | T_END_BIB freespace_list {
          //printf("END BIBLIOGRAPHY\n");
        }
        | T_BIB_ITEM T_LBRACE T_P T_RBRACE T_P freespace_list {
          //printf("BIB ITEM %02d : %s : %s\n", full_reference($3, $5), $3, $5);
          full_reference($3, $5);
        }
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
          //printf("CITE %02d :: %s\n", new_reference($3), $3);
          new_reference($3);
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
              printf("item: %s\n", $2);
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
 * Structs
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
 * Functions
 */

/*
Source code for this function: 
http://www.linuxquestions.org/questions/programming-9/replace-a- substring 
-with- another-string-in-c-170076/#post_message_877511
*/
char *replace_str(char *str, char *orig, char *rep){
  static char buffer[4096];
  char *p;
  
  if(!(p = strstr(str, orig)))  // Is 'orig' even in 'str'?
    return str;
  
  strncpy(buffer, str, p-str); // Copy characters from 'str' start to 'orig' st$
  buffer[p-str] = '\0';
  
  sprintf(buffer+(p-str), "%s%s", rep, p+strlen(orig));
  
  return buffer;
}

int reference_exist(char *alias) {
  struct bibitem *current;
  current = bibl;
  
  while (current->next != NULL) {
    current = current->next;
    if (!strcmp(current->alias, alias)) {
      // Return the index of the reference.
      return current->number;
    }
  }
  return 0;
  
  /*
  while (current->alias != alias) {
    current = current->next;
    if (current == NULL) {
      return 0;
    }
  }
  // Return the index of the reference.
  return current->number;
  */
}

int full_reference(char *alias, char *full) {
  struct bibitem *current, *new_ref;
  int ref, i;
  
  ref = reference_exist(alias);
  
  if (ref) {
    current = bibl;
    for (i = 0; i < ref; i++) {
      current = current->next;
    }
    current->full = full;
    return current->number;
  }
  
  new_ref = (struct bibitem*) malloc (sizeof(struct bibitem));
  new_ref->alias = alias;
  new_ref->full = full;
  new_ref->number = ++ref_index;
  new_ref->next = NULL;
  
  // Insertion always in the end of linked list.
  end->next = new_ref;
  end = new_ref;
  
  // Return the index of the reference.
  return new_ref->number;
}

int new_reference(char *alias) {
  struct bibitem *new_ref;
  
  if (reference_exist(alias))
    return 0;
  
  new_ref = (struct bibitem*) malloc (sizeof(struct bibitem));
  new_ref->alias = alias;
  new_ref->full = '\0';
  new_ref->number = ++ref_index;
  new_ref->next = NULL;
  
  // Insertion always in the end of linked list.
  end->next = new_ref;
  end = new_ref;
  
  // Return the index of the reference.
  return new_ref->number;
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
  while (current->next != NULL) {
    current = current->next;
    printf("%02d. %s :: %s\n", current->number, current->alias, current->full);
  }
  /*
  while (current->alias != '\0') {
    printf("%02d. %s :: %s\n", current->number, current->alias, current->full);
    current = current->next;
  }
  */
  //if (current->alias == '\0')
  if (current->next == NULL)
    fprintf(stderr, "SUCCESS!\n");
  
  return 0;
  
}