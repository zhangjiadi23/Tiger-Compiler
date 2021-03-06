%{
#include <stdio.h>
#include "util.h"
#include "errormsg.h"

int yylex(void); /* function prototype */

void yyerror(char *s) {
  EM_error(EM_tokPos, "%s", s);
}

%}

%union {
	int pos;
	int ival;
	string sval;
  }

%nonassoc LOW
%nonassoc TYPE FUNCTION
%nonassoc ID
%nonassoc LBRACK
%nonassoc DO OF
%nonassoc THEN
%nonassoc ELSE
%left SEMICOLON
%nonassoc ASSIGN
%left OR
%left AND
%nonassoc EQ NEQ LT LE GT GE
%left PLUS MINUS
%left TIMES DIVIDE
%left UMINUS

%token <sval> ID STRING
%token <ival> INT

%token 
  COMMA COLON SEMICOLON LPAREN RPAREN LBRACK RBRACK 
  LBRACE RBRACE DOT 
  PLUS MINUS TIMES DIVIDE EQ NEQ LT LE GT GE
  AND OR ASSIGN
  ARRAY IF THEN ELSE WHILE FOR TO DO LET IN END OF 
  BREAK NIL
  FUNCTION VAR TYPE

%start program

%%

program: exp

exp: lvalue
   | NIL
   | LPAREN RPAREN
   | INT
   | STRING
   | MINUS exp %prec UMINUS
   | func_call
   | arith_exp
   | cmp_exp
   | bool_exp
   | record_create
   | array_create
   | lvalue ASSIGN exp
   | IF exp THEN exp ELSE exp
   | IF exp THEN exp
   | WHILE exp DO exp
   | FOR ID ASSIGN exp TO exp DO exp
   | BREAK
   | LET decs IN expseq END
   | LPAREN expseq RPAREN

lvalue: ID
      | ID LBRACK exp RBRACK
      | lvalue LBRACK exp RBRACK
      | lvalue DOT ID

func_call: ID LPAREN explist RPAREN

explist:
       | explist_nonempty

explist_nonempty: exp
                | explist_nonempty COMMA exp

arith_exp: exp PLUS exp
         | exp MINUS exp
         | exp TIMES exp
         | exp DIVIDE exp

cmp_exp: exp EQ exp
       | exp NEQ exp
       | exp LT exp
       | exp LE exp
       | exp GT exp
       | exp GE exp

bool_exp: exp AND exp
        | exp OR exp

record_create: ID LBRACE record_create_list RBRACE

record_create_list: 
                  | record_create_list_nonempty

record_create_list_nonempty: record_create_field
                           | record_create_list_nonempty COMMA record_create_field

record_create_field: ID EQ exp

array_create: ID LBRACK exp RBRACK OF exp

decs:
    | decs dec

dec: tydeclist
   | vardec
   | fundeclist

tydeclist: tydec %prec LOW
         | tydec tydeclist

tydec: TYPE ID EQ ty

ty: ID
  | LBRACE tyfields RBRACE
  | ARRAY OF ID

tyfields:
        | tyfields_nonempty

tyfields_nonempty: tyfield
                 | tyfields_nonempty COMMA tyfield

tyfield: ID COLON ID

vardec: VAR ID ASSIGN exp
      | VAR ID COLON ID ASSIGN exp

fundeclist: fundec %prec LOW
          | fundec fundeclist

fundec: FUNCTION ID LPAREN tyfields RPAREN EQ exp
      | FUNCTION ID LPAREN tyfields RPAREN COLON ID EQ exp

expseq: exp
      | expseq SEMICOLON exp