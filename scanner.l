/**
 * projeto1.l
 */

%{
#include "parser.h"
%}

P [a-zA-Z0-9.,;:!?/\-\(\)\[\] ]+
ANYCHAR .

/* Emissão de tokens */
%%

[ \n]*"\\documentclass"[a-zA-Z0-9.,\[\]\{\} ]* ;
[ \n]*"\\usepackage"[a-zA-Z0-9.,\[\]\{\} ]* ;
[ \n]*"\\author"[a-zA-Z0-9.,\[\]\{\} ]* ;
[ \n]*"\\title"					{return T_TITLE;}
[ \n]*"\\maketitle"				{return T_MAKETITLE;}
[ \n]*"\\textbf"					{return T_TEXTBF;}
[ \n]*"\\textit"					{return T_TEXTIT;}
[ \n]*"\\begin{document}"			{return T_BEGIN_DOC;}
[ \n]*"\\end{document}"			{return T_END_DOC;}
[ \n]*"\\begin{itemize}"			{return T_BEGIN_ITEMIZE;}
[ \n]*"\\end{itemize}"			{return T_END_ITEMIZE;}
[ \n]*"\\item"					{return T_ITEM;}
[ \n]*"\\includegraphics"			{return T_INCLUDEGRAPHICS;}
[ \n]*"\\cite"					{return T_CITE;}
[ \n]*"\\begin{thebibliography}"	{return T_BEGIN_BIB;}
[ \n]*"\\end{thebibliography}"	{return T_END_BIB;}
[ \n]*"\\bibitem"					{return T_BIB_ITEM;}
"\$"						{return T_MATH;}
"\\\$"						{return T_DOLLAR;}
"{"							{return T_LBRACE;}
"}"							{return T_RBRACE;}
"["							{return T_LBRACKET;}
"]"							{return T_RBRACKET;}
"\n\n"						{return T_NEWP;}
"\n"						{return T_NEWLINE;}
{P}							{yylval.str = (char*) strdup(yytext); return T_P;}
{ANYCHAR}					/*ignore*/;

%%
/* Código C adicional */