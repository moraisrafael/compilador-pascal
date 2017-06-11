#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "rotulos.h"
#include "tabela.h"

pilha pilha_rotulos;

void gera_rotulo(char* rotulo) {
	static int i = 0;
	
	sprintf(rotulo, "R%03d", i);
	i++;
}

void insere_rotulo_tabela(char* identificador, int nivel_lexico) {
	tipo_rotulo novo_rotulo;
	
	novo_rotulo = malloc(sizeof(struct tipo_rotulo));
	strncpy(novo_rotulo->identificador, identificador, TAM_IDENTIFICADOR);
	novo_rotulo->rotulo = rotulo;
	novo_rotulo->nivel_lexico = nivel_lexico;
	gera_rotulo(novo_rotulo->rotulo_mepa);
	push(novo_rotulo, tabela_simbolos);
}
