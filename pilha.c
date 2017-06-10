#include <stdlib.h>
#include "pilha.h"

int init(pilha* p, int tam_max) {
	*p = (pilha) malloc(sizeof(struct pilha));
	(*p)->v = malloc(sizeof(void*)*tam_max);
	(*p)->tam = 0;
	(*p)->tam_max = tam_max;
}

int push(void* s, pilha p) {
	if (p->tam == p->tam_max) {
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
