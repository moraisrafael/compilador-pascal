#include <stdio.h>
#include "rotulos.h"

pilha pilha_rotulos;

void gera_rotulo(char* rotulo) {
	static int i = 0;
	
	sprintf(rotulo, "R%03d", i);
	i++;
}
