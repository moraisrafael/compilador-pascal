#ifndef TABELA_SIMBOLOS
	#define TAM_MAX_TABELA_SIMBOLOS 256
	#define TAM_ROTULO 4
	#define TAM_IDENTIFICADOR 256
#endif
#include "compilador.h"


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
	tipo_identificador var_simples;
	simbolos tipo;
	int nivel_lexico;
	int deslocamento;
} *tipo_variavel_simples;

typedef struct parametro {
	char indentificador[TAM_IDENTIFICADOR];
	simbolos tipo;
	int referencia;
} parametro;

typedef struct tipo_procedimento {
	char identificador[TAM_IDENTIFICADOR];
	tipo_identificador procedimento;
	char rotulo[TAM_ROTULO];
	int nivel_lexico;
	int n_parametros;
	parametro lista_parametros[];
} *tipo_procedimento;

typedef struct pilha {
	int tam;
	void** v;
} *pilha;

int push(void* s, pilha p);
void* pop(pilha p);
void* busca_tabela_simbolos(char* s);
int init(pilha* p);
int insere_identificador_tabela(char* token);
int transforma_identificador_variavel_simples(int pos, simbolos tipo);

extern pilha tabela_simbolos;
