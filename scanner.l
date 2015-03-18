/**
 * scanner.l
 * Alunos:
 * Davi Uezono - RA097464
 * Gustavo Oyakawa - RA117150
 */

%{
#include "parser.h"
%}

P [a-zA-Z0-9.,;:!?/\-\(\)\[\] ]+
ANYCHAR .

/* Emissão de tokens */
%%

"\\documentclass"[a-zA-Z0-9.,\[\]\{\} ]*          ;
"\\usepackage"[a-zA-Z0-9.,\[\]\{\} ]*             ;
"\\author"[a-zA-Z0-9.,\[\]\{\} ]*                 ;
"\\title"                                         {return T_TITLE;}
"\\maketitle"                                     {return T_MAKETITLE;}
"\\textbf"                                        {return T_TEXTBF;}
"\\textit"                                        {return T_TEXTIT;}
"\\begin{document}"                               {return T_BEGIN_DOC;}
"\\end{document}"                                 {return T_END_DOC;}
"\\begin{itemize}"                                {return T_BEGIN_ITEMIZE;}
"\\end{itemize}"                                  {return T_END_ITEMIZE;}
"\\item"                                          {return T_ITEM;}
"\\includegraphics"                               {return T_INCLUDEGRAPHICS;}
"\\cite"                                          {return T_CITE;}
"\\begin{thebibliography}"                        {return T_BEGIN_BIB;}
"\\end{thebibliography}"                          {return T_END_BIB;}
"\\bibitem"                                       {return T_BIB_ITEM;}
"\$"                                              {return T_MATH;}
"\\\$"                                            {return T_DOLLAR;}
"{"                                               {return T_LBRACE;}
"}"                                               {return T_RBRACE;}
"["                                               {return T_LBRACKET;}
"]"                                               {return T_RBRACKET;}
"\n"                                              {return T_NEWLINE;}
[ ]*                                              {return T_SPACE;}
{P}                                               {yylval.str = (char*) strdup(yytext); return T_P;}
{ANYCHAR}                                         ;

%%
/* Código C adicional */