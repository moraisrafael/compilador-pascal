$DEPURA=1

compilador: lex.yy.c compilador.tab.c compilador.o pilha.o tabela.o rotulos.o
	gcc -g lex.yy.c compilador.tab.c compilador.o pilha.o tabela.o rotulos.o -o compilador -ll -ly -lc

lex.yy.c: compilador.l compilador.h
	flex compilador.l

compilador.tab.c: compilador.y compilador.h
	bison compilador.y -d -v

compilador.o: compilador.h compiladorF.c
	gcc -g -c compiladorF.c -o compilador.o

tabela.o: tabela.h tabela.c
	gcc -g -c tabela.c -o tabela.o

pilha.o: pilha.h pilha.c
	gcc -g -c pilha.c -o pilha.o

rotulos.o: rotulos.h rotulos.c
	gcc -g -c rotulos.c -o rotulos.o

clean : 
	rm -f compilador.output compilador.tab.* lex.yy.c *.o MEPA 
