FONTE = json
PROBA = example.json
#PROBA = exemploFAIL.json

all: compile run

compile:
	flex $(FONTE).l
	bison -o $(FONTE).tab.c $(FONTE).y -yd
	gcc -o $(FONTE) lex.yy.c $(FONTE).tab.c -lfl -ly
	#gcc -o $(FONTE) lex.yy.c -lfl	#Esto fai que so execute o lexer

run:
	./$(FONTE) < $(PROBA)

clean:
	rm $(FONTE) lex.yy.c $(FONTE).tab.c $(FONTE).tab.h
