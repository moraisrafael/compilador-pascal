#ifndef ROTULO_H
#define ROTULO_H

#define TAM_ROTULO 4
#include "pilha.h"

extern pilha pilha_rotulos;

void gera_rotulo(char* rotulo);
void insere_rotulo_tabela(char* identificador, int nivel_lexico);
#endif
