scanner: lex.yy.c
	gcc lex.yy.c -o scanner -lfl
lex.yy.c:
	flex scanner.l
clean:
	rm scanner lex.yy.c