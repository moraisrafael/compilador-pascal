
// Testar se funciona corretamente o empilhamento de parâmetros
// passados por valor ou por referência.


%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "compilador.h"
#include "pilha.h"
#include "tabela.h"
#include "rotulos.h"

int nivel_lexico, n_var, tam_ant, inicio_tipo;
char rotulo_mepa[8] = "", comando_mepa[128], erro[512];
void* lado_esquerdo;
pilha tabela_simbolos;


// tirando warnings chatos
int yylex(void);
int yyerror(char *);
%}

%token PROGRAM VAR T_BEGIN T_END IGUAL MAIS MENOS ASTERISTICO BARRA MOD DIV AND
%token OR PONTO VIRGULA PONTO_E_VIRGULA DOIS_PONTOS ATRIBUICAO ABRE_PARENTESES
%token FECHA_PARENTESES DO WHILE IF ELSE FUNCTION PROCEDURE TIPO IDENT NUMERO
%token LABEL GOTO READ WRITE MAIOR MENOR

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
	declaracao_de_rotulos
	//declaracao_de_tipos
	parte_de_declaracao_de_variaveis
	{
		char* rotulo = malloc(TAM_ROTULO);
		gera_rotulo(rotulo);
		push(rotulo, pilha_rotulos);
		sprintf(comando_mepa, "DSVS %s", rotulo);
		gera_codigo(NULL, comando_mepa);
	}
	//declaracao_de_subrotinas
	{
		char* rotulo = pop(pilha_rotulos);
		gera_codigo(rotulo, "NADA ");
		free(rotulo);
	}
	comando_composto
	{
		sprintf(comando_mepa, "DMEM %d", n_var);
		gera_codigo(NULL, comando_mepa);
	}
;

declaracao_de_rotulos:
	LABEL lista_rotulos PONTO_E_VIRGULA |
;

lista_rotulos:
	lista_rotulos VIRGULA NUMERO
	{
		insere_rotulo_tabela(token, nivel_lexico);
	}
	|
	NUMERO
	{
		insere_rotulo_tabela(token, nivel_lexico);
	}
;

// regra 8
parte_de_declaracao_de_variaveis:
	parte_de_declaracao_de_variaveis
	declaracao_de_variaveis
	{
		sprintf(comando_mepa, "AMEM %d", tabela_simbolos->tam - tam_ant);
		gera_codigo(NULL, comando_mepa);
	}
	|
	VAR
	{
		n_var = 0;
	}
	declaracao_de_variaveis
	{
		sprintf(comando_mepa, "AMEM %d", tabela_simbolos->tam - tam_ant);
		gera_codigo(NULL, comando_mepa);
	}
;

// regra 9
declaracao_de_variaveis:
	{
		tam_ant = tabela_simbolos->tam;
	}
	lista_de_identificadores DOIS_PONTOS TIPO
	{
		int i;
		int pos;

		for (pos = tam_ant; pos < tabela_simbolos->tam; pos++, n_var++) {
			transforma_identificador_variavel_simples(pos, simbolo, nivel_lexico, n_var);
		}
	}
	PONTO_E_VIRGULA
;

// regra 10
lista_de_identificadores:
	lista_de_identificadores VIRGULA IDENT
	{
		/* insere última var na tabela de símbolos */
		insere_identificador_tabela(token);
	}
	|
	IDENT
	{
		/* insere vars na tabela de símbolos */
		insere_identificador_tabela(token);
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
		tipo_rotulo entrada_tabela;
		//busca por rotulo na tabela de paginas;
		entrada_tabela = busca_tabela_simbolos(token);
		if (entrada_tabela == NULL) {
			sprintf(erro, "rotulo \"%s\" não declarado\n", token);
			imprime_erro(erro);
			exit(-1);
		}
		if (entrada_tabela->rotulo != rotulo) {
			sprintf(erro, "esperava um rotulo, recebeu \"%s\"", token);
			imprime_erro(erro);
			exit(-1);
		}
		sprintf(comando_mepa, "ENRT %d, %d", nivel_lexico, n_var);
		gera_codigo(entrada_tabela->rotulo_mepa, comando_mepa);
	}
	DOIS_PONTOS comando_sem_rotulo |
	comando_sem_rotulo
;

// regra 18
comando_sem_rotulo:
	atribuicao |
	//chamada_de_processo |
	desvio |
	comando_composto |
	//comando_condicional |
	comando_repetitivo |
	read |
	write
;

// regra 19
atribuicao:
	IDENT
	{
		// busca por variavel na tabela de simbolos
		lado_esquerdo = busca_tabela_simbolos(token);
		if (lado_esquerdo == NULL) {
			sprintf(erro, "identificador \"%s\" não declarado\n", token);
			imprime_erro(erro);
			exit(-1);
		}
	}
	ATRIBUICAO expressao
	{
		switch (((tipo_simbolo)lado_esquerdo)->tipo) {
			case variavel_simples:
				sprintf(comando_mepa, "ARMZ %d, %d",
					((tipo_variavel_simples)lado_esquerdo)->nivel_lexico,
					((tipo_variavel_simples)lado_esquerdo)->deslocamento);
				break;
			case parametro_formal:
				break;
			default:
				sprintf(erro, "\"%s\" nao esperado\n Esperava uma variavel\n", token);
				imprime_erro(erro);
				exit(-1);
		}
		gera_codigo(NULL, comando_mepa);
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
	gera_codigo(NULL, "DISJ");
	} |
	expressao MENOR T {
	gera_codigo(NULL, "CMME");
	} |
	expressao MAIOR T {
	gera_codigo(NULL, "CMMA");
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
	gera_codigo(NULL, "CONJ");
	} |
	T MENOR IGUAL F {
	gera_codigo(NULL, "CMEG");
	} |
	T MAIOR IGUAL F {
	gera_codigo(NULL, "CMAG");
	} |
	T IGUAL F {
	gera_codigo(NULL, "CMIG");
	} |
	F
;

// regra 22
F:
	IDENT {
		void* entrada_tabela;
		//busca por variavel ou funcao na tabela de paginas;
		entrada_tabela = busca_tabela_simbolos(token);
		if (entrada_tabela == NULL) {
			sprintf(erro, "identificador \"%s\" não declarado\n", token);
			imprime_erro(erro);
			exit(-1);
		}
		switch (((tipo_simbolo)entrada_tabela)->tipo) {
			case variavel_simples:
				sprintf(comando_mepa, "CRVL %d, %d",
					((tipo_variavel_simples)entrada_tabela)->nivel_lexico,
					((tipo_variavel_simples)entrada_tabela)->deslocamento);
				gera_codigo(NULL, comando_mepa);
				break;
			case parametro_formal:
				break;
			case funcao:
				break;
			default:
				sprintf(erro, "\"%s\" nao esperado\n Esperava integer\n", token);
				imprime_erro(erro);
				exit(-1);
		}
	}
	|
	ABRE_PARENTESES expressao FECHA_PARENTESES |
	NUMERO
	{
		sprintf(comando_mepa, "CRCT %s", token);
		gera_codigo(NULL, comando_mepa);
	}
;

desvio:
	GOTO NUMERO
	{
		tipo_rotulo entrada_tabela;
		//busca por rotulo na tabela de paginas;
		entrada_tabela = busca_tabela_simbolos(token);
		if (entrada_tabela == NULL) {
			sprintf(erro, "rotulo \"%s\" não declarado\n", token);
			imprime_erro(erro);
			exit(-1);
		}
		if (entrada_tabela->rotulo != rotulo) {
			sprintf(erro, "esperava um rotulo, recebeu \"%s\"", token);
			imprime_erro(erro);
			exit(-1);
		}
		sprintf(comando_mepa, "DSVR %s, %d, %d", entrada_tabela->rotulo_mepa, entrada_tabela->nivel_lexico, nivel_lexico);
		gera_codigo(NULL, comando_mepa);
	}
;

//regra 23
comando_repetitivo:
	WHILE {
		char *inicio_while, *fim_while;
		inicio_while = malloc(sizeof(TAM_ROTULO));
		fim_while = malloc(sizeof(TAM_ROTULO));
		gera_rotulo(inicio_while);
		gera_rotulo(fim_while);
		push(fim_while, pilha_rotulos);
		push(inicio_while, pilha_rotulos);
		gera_codigo(inicio_while, "NADA ");
	}
	expressao {
		sprintf(comando_mepa, "DSVF %s", (char*)pilha_rotulos->v[pilha_rotulos->tam-2]);
		gera_codigo(NULL, comando_mepa); // desvia para fim do while se falso
	}
	DO comando_sem_rotulo {
		char* rotulo;
		rotulo = pop(pilha_rotulos);
		sprintf(comando_mepa, "DSVS %s", rotulo); // volta ao inicio do while
		free(rotulo);
		gera_codigo(NULL, comando_mepa);
		rotulo = pop(pilha_rotulos);
		gera_codigo(rotulo, "NADA "); // fim do while
		free(rotulo);
	}
;



// falta implementar regras:
//chamada_de_processo: IDENT;
//comando_condicional: IDENT;
//declaracao_de_subrotinas: IDENT;
//declaracao_de_tipos: IDENT;

read:
	READ ABRE_PARENTESES lista_ident_read FECHA_PARENTESES
;

lista_ident_read:
	lista_ident_read VIRGULA IDENT
	{
		tipo_simbolo entrada_tabela;
		//busca por variavel ou parametro formal na tabela de paginas;
		entrada_tabela = busca_tabela_simbolos(token);
		if (entrada_tabela == NULL) {
			sprintf(erro, "identificador \"%s\" não declarado\n", token);
			imprime_erro(erro);
			exit(-1);
		}
		gera_codigo(NULL,"LEIT");
		switch (entrada_tabela->tipo) {
			case variavel_simples:
				sprintf(comando_mepa, "ARMZ %d, %d",
					((tipo_variavel_simples)entrada_tabela)->nivel_lexico,
					((tipo_variavel_simples)entrada_tabela)->deslocamento);
				gera_codigo(NULL, comando_mepa);
				break;
			case parametro_formal:
				break;
			case funcao:
				break;
			default:
				sprintf(erro, "\"%s\" nao esperado\n Esperava integer\n", token);
				imprime_erro(erro);
				exit(-1);
		}
		
	}
	|
	IDENT
	{
		tipo_simbolo entrada_tabela;
		//busca por variavel ou parametro formal na tabela de paginas;
		entrada_tabela = busca_tabela_simbolos(token);
		if (entrada_tabela == NULL) {
			sprintf(erro, "identificador \"%s\" não declarado\n", token);
			imprime_erro(erro);
			exit(-1);
		}
		gera_codigo(NULL,"LEIT");
		switch (entrada_tabela->tipo) {
			case variavel_simples:
				sprintf(comando_mepa, "ARMZ %d, %d",
					((tipo_variavel_simples)entrada_tabela)->nivel_lexico,
					((tipo_variavel_simples)entrada_tabela)->deslocamento);
				gera_codigo(NULL, comando_mepa);
				break;
			case parametro_formal:
				break;
			case funcao:
				break;
			default:
				sprintf(erro, "\"%s\" nao esperado\n Esperava integer\n", token);
				imprime_erro(erro);
				exit(-1);
		}
		
	}
;

write:
	WRITE ABRE_PARENTESES lista_ident_write FECHA_PARENTESES
;

lista_ident_write:
	lista_ident_write VIRGULA IDENT
	{
		tipo_simbolo entrada_tabela;
		//busca por variavel ou parametro formal na tabela de paginas;
		entrada_tabela = busca_tabela_simbolos(token);
		if (entrada_tabela == NULL) {
			sprintf(erro, "identificador \"%s\" não declarado\n", token);
			imprime_erro(erro);
			exit(-1);
		}
		switch (entrada_tabela->tipo) {
			case variavel_simples:
				sprintf(comando_mepa, "CRVL %d, %d",
					((tipo_variavel_simples)entrada_tabela)->nivel_lexico,
					((tipo_variavel_simples)entrada_tabela)->deslocamento);
				gera_codigo(NULL, comando_mepa);
				gera_codigo(NULL,"IMPR");
				break;
			case parametro_formal:
				break;
			case funcao:
				break;
			default:
				sprintf(erro, "\"%s\" nao esperado\n Esperava integer\n", token);
				imprime_erro(erro);
				exit(-1);
		}
		
	}
	|
	IDENT
	{
		tipo_simbolo entrada_tabela;
		//busca por variavel ou parametro formal na tabela de paginas;
		entrada_tabela = busca_tabela_simbolos(token);
		if (entrada_tabela == NULL) {
			sprintf(erro, "identificador \"%s\" não declarado\n", token);
			imprime_erro(erro);
			exit(-1);
		}
		switch (entrada_tabela->tipo) {
			case variavel_simples:
				sprintf(comando_mepa, "CRVL %d, %d",
					((tipo_variavel_simples)entrada_tabela)->nivel_lexico,
					((tipo_variavel_simples)entrada_tabela)->deslocamento);
				gera_codigo(NULL, comando_mepa);
				gera_codigo(NULL,"IMPR");
				break;
			case parametro_formal:
				break;
			case funcao:
				break;
			default:
				sprintf(erro, "\"%s\" nao esperado\n Esperava integer\n", token);
				imprime_erro(erro);
				exit(-1);
		}
		
	}
;

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

	init(&tabela_simbolos, TAM_MAX_TABELA_SIMBOLOS);
	init(&pilha_rotulos, TAM_MAX_TABELA_SIMBOLOS);

	yyin=fp;
	yyparse();

	return 0;
}

