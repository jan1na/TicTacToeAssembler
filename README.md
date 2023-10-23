# TicTacToeAssembler

## Game with 2 Players

Play TicTacToe in the terminal based on ARM Assembler Code. You need an ARM server for the compilation and execution.

At first the .s assembler code file needs to be compiled. This can be done by using the Makefile.
```bash
make
```
or 
```bash
make normal
```

This command creates an executalbe (`tictactoe`). You can now execute it using:
```bash
./tictactoe
```
At first you are ased to enter names for the players
```bash
Namen von Spieler 1 eingeben: j
Namen von Spieler 2 eingeben: n
```
and then you can start playing by entering the coordinate for your `X` or `O`.
```bash
[ ][1][2][3]
[1][ ][ ][ ]
[2][ ][ ][ ]
[3][ ][ ][ ]
j ist an der Reihe: 
x: 2
y: 2
[ ][1][2][3]
[1][ ][ ][ ]
[2][ ][X][ ]
[3][ ][ ][ ]
```
The game ends when either one player has 3 in a row or all fields are full.
```bash
j hat gewonnen!
[ ][1][2][3]
[1][O][X][O]
[2][ ][X][ ]
[3][ ][X][ ]
```
```bash
Es gibt keinen Gewinner.
[ ][1][2][3]
[1][O][X][X]
[2][X][X][O]
[3][O][O][X]
```

## Game with 1 Player

I programmed another assembler file, which allows to play TicTacToe on your own against an "AI". This AI is based on rules to make the best desicions for each case (I hope I did not forget a case). It is the `tictactoe2.s` file which can be compiled using:
```bash
make ai
```
The code can then be executed with:
```bash
./tictactoe2
```
The operations are similar to the previous version, but here you can deside how many players are participating.
```bash
Waehlen Sie (1) einen Spieler oder (2) zwei Spieler: 1
```
Then again you can enter a name. After that the you and the ai can alternately choose coordinates until one wins or all fields are full.
