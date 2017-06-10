#ifndef PILHA_H
#define PILHA_H

typedef struct pilha {
	int tam, tam_max;
	void** v;
} *pilha;

int init(pilha* p, int tam_max);
int push(void* s, pilha p);
void* pop(pilha p);

#endif
