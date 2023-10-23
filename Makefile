all: normal

normal:
	arm-linux-gnueabihf-as -o tictactoe.o tictactoe.s
	arm-linux-gnueabihf-gcc -o tictactoe tictactoe.o

ai:
	arm-linux-gnueabihf-as -o tictactoe2.o tictactoe2.s
	arm-linux-gnueabihf-gcc -o tictactoe2 tictactoe2.o
