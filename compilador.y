
// Testar se funciona corretamente o empilhamento de parâmetros
// passados por valor ou por referência.


%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "compilador.h"

int nivel_lexico, n_var, n_var_tipo, deslocamento, inicio_tipo;
char comando_mepa[128];
pilha tabela_simbolos;
extern tipo_variavel tipo_var;


// tirando warnings chatos
int yylex(void);
int yyerror(char *);
%}

%token PROGRAM ABRE_PARENTESES FECHA_PARENTESES 
%token VIRGULA PONTO_E_VIRGULA DOIS_PONTOS PONTO
%token T_BEGIN T_END VAR IDENT TIPO

//incluidos
%token AND DIV IGUAL MAIS MENOS OR
%token DO WHILE
%token ASTERISTICO NUMERO


%%

// regra 1
programa:
	{
		gera_codigo (NULL, "INPP");
		nivel_lexico = 0;
	}
	PROGRAM IDENT 
	ABRE_PARENTESES lista_de_identificadores FECHA_PARENTESES PONTO_E_VIRGULA
	bloco PONTO
	{
		gera_codigo (NULL, "PARA"); 
	}
;

// regra 2
bloco:
	//declaracao_de_rotulos
	//declaracao_de_tipos
	parte_de_declaracao_de_variaveis
	//declaracao_de_subrotinas
	comando_composto
;


// regra 8
parte_de_declaracao_de_variaveis:
	parte_de_declaracao_de_variaveis
	declaracao_de_variaveis
	{
		sprintf(comando_mepa, "AMEM %d", n_var_tipo);
		gera_codigo(NULL, comando_mepa);
		n_var += n_var_tipo;
	}
	|
	VAR
	{
		n_var = 0;
	}
	declaracao_de_variaveis
	{
		sprintf(comando_mepa, "AMEM %d", n_var_tipo);
		gera_codigo(NULL, comando_mepa);
		n_var += n_var_tipo;
	}
;

// regra 9
declaracao_de_variaveis:
	{
		n_var_tipo = tabela_simbolos->tam;
	}
	lista_de_identificadores DOIS_PONTOS TIPO
	{
		int i;
		int pos;

		n_var_tipo = tabela_simbolos->tam - n_var_tipo;

		for (i = 0, pos = tabela_simbolos->tam - 1; i < n_var_tipo; i++, pos--) {
			((tipo_variavel_simples)(tabela_simbolos->v[pos]))->tipo = tipo_var;
		}
	}
	PONTO_E_VIRGULA
;

// regra 10
lista_de_identificadores:
	lista_de_identificadores VIRGULA IDENT
	{
		/* insere última var na tabela de símbolos */
		insere_variavel_tabela(token, nivel_lexico);
	}
	|
	IDENT
	{
		/* insere vars na tabela de símbolos */
		insere_variavel_tabela(token, nivel_lexico);
	}
;

// regra 16
comando_composto:
	T_BEGIN comandos T_END 
;

comandos:
	comandos PONTO_E_VIRGULA comando |
	comando
;

// regra 17
comando:
	NUMERO {
	/*gera rotulo*/
	}
	DOIS_PONTOS comando_sem_rotulo |
	comando_sem_rotulo
;

// regra 18
comando_sem_rotulo:
	atribuicao |
	//chamada_de_processo |
	//desvio |
	comando_composto |
	//comando_condicional |
	//comando_repetitivo
;

// regra 19
atribuicao:
	IDENT
	{
		// busca por variavel na tabela de simbolos
	}
	DOIS_PONTOS IGUAL expressao
	{
		// armazena na variavel
	}
;

// regra 20
expressao:
	expressao MAIS T {
	gera_codigo(NULL, "SOMA");
	} |
	expressao MENOS T {
	gera_codigo(NULL, "SUBT");
	} |
	expressao OR T {
	gera_codigo(NULL, NULL);/////////////////////////////////////////////
	} |
	T
;

// regra 21
T:
	T ASTERISTICO F {
	gera_codigo(NULL, "MULT");
	} |
	T DIV F {
	gera_codigo(NULL, "DIVI");
	} |
	T AND F {
	gera_codigo(NULL, NULL);/////////////////////////////////////////////////////
	} |
	F
;

// regra 22
F:
	IDENT {
	/*busca por variavel ou funcao na tabela de paginas;
	CRVR nivel deslocamento*/
	} |
	ABRE_PARENTESES expressao FECHA_PARENTESES |
	NUMERO
	{
		sprintf(comando_mepa, "CRCT %s", token);
		gera_codigo(NULL, comando_mepa);
	}
;

// regra 23
//comando_repetitivo:
//	WHILE {
	/*gera_rotulo*/
	/*empilha rotulo*/
//	gera_codigo(NULL, "NADA");
//	}
//	expressao {
	/*desvio rotulo2*/
//	}
//	DO comando_sem_rotulo {
	/*desvio rotulo 1*/
//	}
//;

// falta implementar regras:
//chamada_de_processo: IDENT;
//comando_condicional: IDENT;
//declaracao_de_rotulos: IDENT;
//declaracao_de_subrotinas: IDENT;
//declaracao_de_tipos: IDENT;
//desvio: IDENT;

%%

int main (int argc, char** argv) {
	FILE* fp;
	extern FILE* yyin;

	if (argc<2 || argc>2) {
		printf("usage compilador <arq>a %d\n", argc);
		return(-1);
	}

	fp=fopen (argv[1], "r");
	if (fp == NULL) {
		printf("usage compilador <arq>b\n");
		return(-1);
	}

	init(&tabela_simbolos);
	tabela_simbolos->v = malloc(sizeof(void*)*TAM_MAX_TABELA_SIMBOLOS);

	yyin=fp;
	yyparse();

	return 0;
}

