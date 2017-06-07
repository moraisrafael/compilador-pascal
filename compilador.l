%{


#include<stdio.h>
#include<string.h>

#include "compilador.h"
#include "compilador.tab.h"

//#define IMPRIME(STR) {};
#define IMPRIME(STR) printf("%s    # %s \n", STR, token);

int nl = 1;

%}

pulo_linha [\n]

descarte [\t ]+

ident [a-zAZ][a-zAZ1-9]*

numero [0-9]+

comentario "(*".*"*)"

%%

{pulo_linha} {nl++;} 

{descarte}

{comentario}

program { simbolo  = simb_program;  
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("program          ");
          return PROGRAM;
 }

var      { simbolo = simb_var;  
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("var              ");
          return VAR;
 }

begin { simbolo = simb_begin;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("begin            ");
          return T_BEGIN;
 }

end { simbolo = simb_end;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("end              ");
          return T_END;
 }

= { simbolo = simb_igual;  
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("igual            ");
          return IGUAL;  
 }

\+ { simbolo = simb_mais;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("mais             ");
          return MAIS;
  }

- { simbolo = simb_menos;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("menos            ");
          return MENOS;
  }

\* { simbolo = simb_asteristico;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("asteristico      ");
          return ASTERISTICO;
  }

\/ { simbolo = simb_barra;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("barra            ");
          return BARRA;
  }

mod { simbolo = simb_mod;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("mod              ");
          return MOD;
  }

div { simbolo = simb_div;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("div              ");
          return DIV;
  }

and { simbolo = simb_and;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("and              ");
          return AND;
  }

or { simbolo = simb_or;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("OR               ");
          return OR;
  }

\; { simbolo = simb_ponto_e_virgula;  
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("pt_virgula       ");
          return PONTO_E_VIRGULA;
 }

\:= { simbolo = simb_atribuicao;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("atribuicao       ");
          return ATRIBUICAO;
  }

\: { simbolo = simb_dois_pontos;  
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("dois pontos      ");
          return DOIS_PONTOS;
 }

\, { simbolo = simb_virgula;  
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("virgula          ");
          return VIRGULA;
 }


\. { simbolo = simb_ponto;  
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("ponto            ");
          return PONTO; 
    }

\(  { simbolo = simb_abre_parenteses;  
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("abre_parenteses  ");
          return ABRE_PARENTESES;
    }

\)  { simbolo = simb_fecha_parenteses;  
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("fecha_parenteses ");
          return FECHA_PARENTESES;
 }

do { simbolo = simb_do;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("do               ");
          return DO;
  }

while { simbolo = simb_while;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("while            ");
          return WHILE;
  }

if { simbolo = simb_if;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("if               ");
          return IF;
  }

else { simbolo = simb_else;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("else             ");
          return ELSE;
  }

function { simbolo = simb_function;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("function         ");
          return FUNCTION;
  }

procedure { simbolo = simb_procedure;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("procedure        ");
          return PROCEDURE;
  }

integer { simbolo = simb_integer;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("integer          ");
          return TIPO;
  }

{ident} { simbolo = simb_ident; 
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("ident            ");
          return IDENT;
        }

{numero} { simbolo = simb_numero;
           strncpy (token, yytext, TAM_TOKEN);
           IMPRIME("numero           ");
           return NUMERO;
         }
%%
