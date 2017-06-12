#ifndef TABELA_H
#define TABELA_H

#define TAM_MAX_TABELA_SIMBOLOS 256
#define TAM_IDENTIFICADOR 256
#include "compilador.h"
#include "pilha.h"
#include "rotulos.h"

typedef enum tipo_identificador {
	variavel_simples, rotulo, parametro_formal, procedimento, funcao
} tipo_identificador;

typedef char* tipo_token;

typedef struct tipo_simbolo {
	char identificador[TAM_IDENTIFICADOR];
	tipo_identificador tipo;
} *tipo_simbolo;

typedef struct tipo_variavel_simples {
	char identificador[TAM_IDENTIFICADOR];
	tipo_identificador variavel_simples;
	simbolos tipo;
	int nivel_lexico;
	int deslocamento;
} *tipo_variavel_simples;

typedef struct tipo_rotulo {
	char identificador[TAM_IDENTIFICADOR];
	tipo_identificador rotulo;
	int nivel_lexico;
	char rotulo_mepa[TAM_ROTULO];
} *tipo_rotulo;

typedef struct tipo_parametro_formal {
	char indentificador[TAM_IDENTIFICADOR];
	tipo_identificador parametro_formal;
	simbolos tipo;
	int nivel_lexico;
	int deslocamento;
	int referencia;
} *tipo_parametro_formal;

typedef struct tipo_procedimento {
	char identificador[TAM_IDENTIFICADOR];
	tipo_identificador procedimento;
	char rotulo[TAM_ROTULO];
	int nivel_lexico;
	int n_parametros;
	int pos;
} *tipo_procedimento;

void* busca_tabela_simbolos(char* s);
int insere_identificador_tabela(char* token);
int transforma_identificador_variavel_simples(int pos, simbolos tipo, int nivel_lexico, int deslocamento);
void insere_rotulo_tabel(char* identificador, int nivel_lexico);

extern pilha tabela_simbolos;

#endif
