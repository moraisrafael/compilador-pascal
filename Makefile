$DEPURA=1

compilador: lex.yy.c y.tab.c compilador.o tabela.o
	gcc -g lex.yy.c compilador.tab.c compilador.o tabela.o -o compilador -ll -ly -lc

lex.yy.c: compilador.l compilador.h
	flex compilador.l

y.tab.c: compilador.y compilador.h
	bison compilador.y -d -v

compilador.o: compilador.h compiladorF.c
	gcc -g -c compiladorF.c -o compilador.o

tabela.o: tabela.h tabela.c
	gcc -g -c tabela.c -o tabela.o

clean : 
	rm -f compilador.tab.* lex.yy.c *.o MEPA 
