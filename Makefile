all: minishell

minishell: main.o
	aarch64-linux-gnu-ld -o minishell main.o

main.o: main.s
	aarch64-linux-gnu-as -g -o main.o main.s

clean:
	rm -f *.o minishell