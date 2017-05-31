#include <stddef.h>
#include <string.h>
#include <stdlib.h>
#include "tabela.h"

pilha tabela_simbolos;

int push(void* s, pilha p) {
	if (p->tam == TAM_MAX_TABELA_SIMBOLOS) {
		return 0;
	}

	p->v[p->tam] = s;
	p->tam++;

	return 1;
}

void* pop(pilha p) {
	if (p->tam <= 0) {
		return NULL;
	}
	p->tam--;
	return p->v[p->tam];
}

void* busca_tabela_simbolos(char* s) {
	int i;

	for (i = tabela_simbolos->tam - 1; i >= 0; i--) {
	// busca de baixo para cima para procurar sempre no nivel lexico mais alto
		if (strcmp(s, ((tipo_simbolo)tabela_simbolos->v[i])->identificador) == 0) {
			return tabela_simbolos->v[i];
		}
	}
	return NULL;
}

int init(pilha* p) {
	*p = (pilha) malloc(sizeof(struct pilha));
	(*p)->tam = 0;
}

int insere_variavel_tabela(char* token, int nivel_lexico) {
	tipo_variavel_simples variavel;

	variavel = malloc(sizeof(struct tipo_variavel_simples));
	strncpy(variavel->identificador, token, TAM_IDENTIFICADOR);
	variavel->nivel_lexico = nivel_lexico;
	variavel->var_simples = variavel_simples;

	push(variavel, tabela_simbolos);
}