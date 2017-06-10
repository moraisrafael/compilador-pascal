#include <stdlib.h>
#include <string.h>
#include "tabela.h"
#include "compilador.h"

pilha tabela_simbolos;

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

int insere_identificador_tabela(char* token) {
	tipo_token identificador;

	identificador = malloc(TAM_IDENTIFICADOR);
	strncpy(identificador, token, TAM_IDENTIFICADOR);

	push(identificador, tabela_simbolos);
}

int transforma_identificador_variavel_simples(int pos, simbolos tipo, int nivel_lexico, int deslocamento) {
	tipo_variavel_simples variavel;

	variavel = malloc(sizeof(struct tipo_variavel_simples));
	variavel->variavel_simples = variavel_simples;

	strncpy(variavel->identificador, tabela_simbolos->v[pos], TAM_IDENTIFICADOR);
	variavel->tipo = tipo;
	variavel->nivel_lexico = nivel_lexico;
	variavel->deslocamento = deslocamento;

	free(tabela_simbolos->v[pos]);
	tabela_simbolos->v[pos] = variavel;
}
