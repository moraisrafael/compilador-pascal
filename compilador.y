
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

typedef enum tipos { integer = simb_integer, boolean } tipos;

int nivel_lexico, n_var, tam_ant, inicio_tipo, n_parametros;
char rotulo_mepa[8] = "", comando_mepa[128], erro[512];
void* lado_esquerdo;
pilha tabela_simbolos;
tipos tipo_E, tipo_T, tipo_F;

void verifica_tipo(tipos recebido, tipos esperado) {
	if (recebido != esperado)
		imprime_erro("conflito de tipo esperado");
}



// tirando warnings chatos
int yylex(void);
int yyerror(char *);
%}

%token PROGRAM VAR T_BEGIN T_END IGUAL MAIS MENOS ASTERISTICO BARRA MOD DIV AND
%token OR PONTO VIRGULA PONTO_E_VIRGULA DOIS_PONTOS ATRIBUICAO ABRE_PARENTESES
%token FECHA_PARENTESES DO WHILE IF THEN ELSE FUNCTION PROCEDURE TIPO IDENT NUMERO
%token LABEL GOTO READ WRITE MAIOR MENOR MAIOR_IGUAL MENOR_IGUAL

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

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
	{
		char* rotulo = malloc(TAM_ROTULO);
		gera_rotulo(rotulo);
		push(rotulo, pilha_rotulos);
	}
	declaracao_de_rotulos
	//declaracao_de_tipos
	parte_de_declaracao_de_variaveis
	{
		char* rotulo;
		rotulo = pop(pilha_rotulos);
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
	comando_condicional |
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
				verifica_tipo(((tipo_variavel_simples)lado_esquerdo)->tipo, tipo_E);
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
	expressao {
		verifica_tipo(tipo_E, integer);
	} MAIS T {
		verifica_tipo(tipo_T, integer);
		tipo_E = integer;
		gera_codigo(NULL, "SOMA");
	} |
	expressao {
		verifica_tipo(tipo_E, integer);
	} MENOS T {
		verifica_tipo(tipo_T, integer);
		tipo_E = integer;
		gera_codigo(NULL, "SUBT");
	} |
	expressao {
		verifica_tipo(tipo_E, boolean);
	} OR T {
		verifica_tipo(tipo_T, boolean);
		tipo_E = boolean;
		gera_codigo(NULL, "DISJ");
	} |
	expressao {
		verifica_tipo(tipo_E, integer);
	} MENOR T {
		verifica_tipo(tipo_T, integer);
		tipo_E = boolean;
		gera_codigo(NULL, "CMME");
	} |
	expressao {
		verifica_tipo(tipo_E, integer);
	} MAIOR T {
		verifica_tipo(tipo_T, integer);
		tipo_E = boolean;
		gera_codigo(NULL, "CMMA");
	} |
	T
	{
		tipo_E = tipo_T;
	}
;

// regra 21
T:
	T {
		verifica_tipo(tipo_T, integer);
	} ASTERISTICO F {
		verifica_tipo(tipo_F, integer);
		tipo_T = integer;
		gera_codigo(NULL, "MULT");
	} |
	T {
		verifica_tipo(tipo_T, integer);
	} DIV F {
		verifica_tipo(tipo_F, integer);
		tipo_T = integer;
		gera_codigo(NULL, "DIVI");
	} |
	T {
		verifica_tipo(tipo_T, boolean);
	} AND F {
		verifica_tipo(tipo_F, boolean);
		tipo_T = boolean;
		gera_codigo(NULL, "CONJ");
	} |
	T MENOR_IGUAL  {
		verifica_tipo(tipo_T, integer);
	} F {
		verifica_tipo(tipo_F, integer);
		tipo_T = boolean;
		gera_codigo(NULL, "CMEG");
	} |
	T MAIOR_IGUAL  {
		verifica_tipo(tipo_T, integer);
	} F {
		verifica_tipo(tipo_F, integer);
		tipo_T = boolean;
		gera_codigo(NULL, "CMAG");
	} |
	T IGUAL {
		verifica_tipo(tipo_T, integer);
	} F {
		verifica_tipo(tipo_F, integer);
		tipo_T = boolean;
		gera_codigo(NULL, "CMIG");
	} |
	F
	{
		tipo_T = tipo_F;
	}
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
				tipo_F = ((tipo_variavel_simples)entrada_tabela)->tipo;
				break;
			/*case parametro_formal:
				break;
			case funcao:
				break;*/
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
		tipo_F = integer;
	}
;


/*chamada_de_processo:
	IDENT
	{
		tipo_procedimento entrada_tabela;
		//busca por procedimento na tabela de paginas;
		entrada_tabela = busca_tabela_simbolos(token);
		if (entrada_tabela == NULL) {
			sprintf(erro, "procedure \"%s\" não declarado\n", token);
			imprime_erro(erro);
			exit(-1);
		}
		if (entrada_tabela->procedimento != procedimento) {
			sprintf(erro, "Esperava procedure, recebeu \"%s\"", token);
			imprime_erro(erro);
			exit(-1);
		}
		lado_esquerdo = entrada_tabela;
	}
	ABRE_PARENTESES lista_parametros_chamada
	{
		if (n_parametros != ((tipo_procedimento)lado_esquerdo)->n_parametros) {
			sprintf(erro, "%s esperava %d parametros, mas recebeu %d",
				((tipo_procedimento)lado_esquerdo)->identificador,
				((tipo_procedimento)lado_esquerdo)->n_parametros,
				n_parametros);
			imprime_erro(erro);
			exit(-1);
		}
		sprintf(comando_mepa, "CHPR %s, %d", ((tipo_procedimento)lado_esquerdo)->rotulo, nivel_lexico);
		gera_codigo(NULL, comando_mepa);
	}
	FECHA_PARENTESES
;

lista_parametros_chamada:
	lista_parametros_chamada VIRGULA expressao
	{
		tipo_procedimento procedimento = lado_esquerdo;
		tipo_parametro_formal parametro;

		n_parametros++;
		if (procedimento->n_parametros < n_parametros)
			imprime_erro("numero incorreto de parametros");
		parametro = tabela_simbolos->v[procedimento->pos + n_parametros];
		verifica_tipo(parametro->tipo, tipo_E);
	}
	|
	expressao
	{
		tipo_procedimento procedimento = lado_esquerdo;
		tipo_parametro_formal parametro;

		n_parametros++;
		if (procedimento->n_parametros < n_parametros)
			imprime_erro("numero incorreto de parametros");
		parametro = tabela_simbolos->v[procedimento->pos + n_parametros];
		verifica_tipo(parametro->tipo, tipo_E);
	}
;*/

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

comando_condicional:
	if_then cond_else 
    { 
		// em_if_finaliza ();
		char* rot_fim = pop(pilha_rotulos);
		gera_codigo(rot_fim, "NADA");
		free(rot_fim);
	}
;

if_then:
	IF expressao 
	{
		//em_if_apos_expr ();
		char *rot_else, *rot_fim;
		rot_else = malloc(TAM_ROTULO);
		rot_fim = malloc(TAM_ROTULO);
		gera_rotulo(rot_else);
		gera_rotulo(rot_fim);
		push(rot_else, pilha_rotulos);
		push(rot_fim, pilha_rotulos);
		sprintf(comando_mepa, "DSVF, %s", rot_else);
		gera_codigo(NULL, comando_mepa);
	}
	THEN comando_sem_rotulo
	{
		//em_if_apos_then ();
		char *rot_else, *rot_fim;
		rot_fim = pop(pilha_rotulos);
		sprintf(comando_mepa, "DSVS %s", rot_fim);
		gera_codigo(NULL, comando_mepa);
		rot_else = pop(pilha_rotulos);
		gera_codigo(rot_else, "NADA");
		free(rot_else);
		push(rot_fim, pilha_rotulos);
	}
;

cond_else:
	ELSE comando_sem_rotulo
	| %prec LOWER_THAN_ELSE
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
		
	} |
	lista_ident_write VIRGULA NUMERO
	{
		sprintf(comando_mepa, "CRCT %s", token);
		gera_codigo(NULL, comando_mepa);
		gera_codigo(NULL,"IMPR");
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
		
	} |
	NUMERO
	{
		sprintf(comando_mepa, "CRCT %s", token);
		gera_codigo(NULL, comando_mepa);
		gera_codigo(NULL,"IMPR");
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


