.data
xx: .asciz "x: "
x: .string "%d"
yy: .asciz "y: "
y: .string "%d"
output: .asciz "x: %d y: %d \n"
row: .asciz "[%c][%c][%c]\n"
head: .asciz "[ ][1][2][3]\n"
side: .asciz "[%d]"
namen: .asciz "Namen von Spieler %d eingeben: "
spieler1: .string "%s"
name1: .asciz "Name 1: %c"
instruction: .asciz "%c ist an der Reihe: \n"
AIinstruction: .asciz "AI ist and der Reihe: \n"
winner: .asciz "%c hat gewonnen!\n"
AIwinner: .asciz "Die AI hat gewonnen!\n"
loop: .asciz "in loop: %d"
tab: .asciz " "
fieldA: .asciz "[X]"
fieldB: .asciz "[O]"
zeilenumbruch: .asciz "\n"
field: .asciz "[ ]"
AIName: .asciz "AI"
error: .asciz "Eingabe ist nicht legit. Versuche es nochmal:\n"
noWinner: .asciz "Es gibt keinen Gewinner.\n"
playerDecideInstr: .asciz "Waehlen Sie (1) einen Spieler oder (2) zwei Spieler: "
println: .asciz "wert in r11: %d\n"
coordinats: .asciz "x: %d  und y: %d\n"
offset: .asciz "time: %d\n"
errorPlayerDecide: .asciz "Es darf nur 1 oder 2 eingegeben werder.\nVersuche es nochmal: "
generalError: .asciz "Something went wrong!\n"


.text
.align 4
.global main

.extern clock
.extern printf
main:
        sub sp, sp, #4
        str lr, [sp]

        sub sp, sp, #44

        //initialice stack
        bl initialiceValues

	bl DecidePlayer

	cmp r11,#1
	beq AI1
	// 2 Spieler:
        bl getNames
	b Skip1

	AI1: //1 Spieler
	bl getName
	Skip1:

        bl printField


	//random selection of player:
	bl clock
	and r0, r0, #1
	mov r10, #0 //offset 0 is for Player 1
	cmp r0, #1 //when clock is even -> AI
	beq GameLoop
	mov r10, #4 //offset for player(eather 0 or 4)

        GameLoop:

        bl EndWithNoWinner
        cmp r0, #1
        bne NotFinished1
        ldr r0, =noWinner
        bl printf
        b End4


	NotFinished1:

	cmp r11,#1
        bne NoAI1
        cmp r10,#4
        beq TurnOfAI

        NoAI1:


        ldr r0, =instruction
        ldr r1, [sp,r10]
        bl printf

        Again1:

        bl getInput

        mov r0, r4
        mov r1, r5
        bl legit
        cmp r0, #1
        beq Ok1
        ldr r0, =error
        bl printf
        b Again1

        Ok1:

        mov r0,r4
        mov r1, r5
	lsr r2 ,r10, #2 //for r10=0 -> 1 r10=4 -> 2
        add r2, r2, #1
        bl addValue

        mov r0, r4
        mov r1, r5
        lsr r2 ,r10, #2 //for r10=0 -> 1 r10=4 -> 2
	add r2, r2, #1
	bl hasWon

        cmp r0, #1
        bne noWinner1
        ldr r0, =winner
        ldr r1, [sp, r10]
        bl printf
        b End4

        noWinner1:
	b NoAI2

	TurnOfAI:

	ldr r0, =AIinstruction
	bl printf


	bl AIcalcValues
	mov r4, r0
	mov r5, r1

	mov r0, r4
	mov r1, r5
	//r4 = x and r5 = y of selected field

	//value is already added

	//r0 = x und r1 = y (already because of AIcalcValues
        mov r2, #2
        bl hasWon

	cmp r0, #1
        bne NoAI2 //AI has not won
        ldr r0, =AIwinner
        bl printf
        b End4


	NoAI2:
        bl printField

	cmp r10,#0
	beq NewPlayer
	mov r10,#0
	b GameLoop
	NewPlayer:
	mov r10,#4


        b GameLoop

        End4:
        bl printField

        add sp, sp, #44

        ldr lr , [sp]
        add sp, sp, #4
        bx lr

AIcalcValues: // r0 = x und r1 = y

	sub sp, sp, #4
	str lr, [sp]

	//find coordinate to stop player 1 -> row with 2x 1

	//check rows
	//r7: offset
	mov r7, #12 //start offest
	//after 3 iterations counter of 1 is checked
	//r6: iteration counter
	mov r6,#0
	//r9: save possible offset
	mov r9,#0

	//first search for row of 2 from player1 and then for row of 2 from AI to complete
	//and win: 1) r4 = #1  2) r4 = #2

	mov r4, #1

	BigLoop:
	cmp r4,#3
	beq EndBigLoop

	//search in rows
	AILoop1:
	cmp r7,#48
	bge EndAILoop1
	ldr r1,[sp,r7]
	cmp r1,r4
	beq NextRound1 //player1 found
	cmp r1,#0
	beq FreeSpot
	//already belongs to AI
	b CalcNextRow
	FreeSpot:
	cmp r9,#0
	beq FirstFreeSpot
	//too many free spots
	b CalcNextRow
	FirstFreeSpot:
	mov r9, r7
	b NextRound1

	CalcNextRow:
	mov r9, #0 //clear saved spot
	cmp r6,#0
	bne Else2
	add r7, r7, #12
	b NewRow

	Else2:
	cmp r6, #1
	bne NextRound1
	add r7, r7, #8
	b NewRow

	NextRound1:
	add r7, r7, #4
	add r6, r6, #1

	cmp r6, #3
	beq NewRow
	b AILoop1

	NewRow:
	mov r6, #0
	cmp r9, #0
	beq AILoop1 //no spot was found

	b SpotIsFound

	EndAILoop1:

	mov r8, #1 //coloumn
	mov r7, #12
	mov r6, #0
	mov r9, #0
	//search in coloumns:
	 AILoop2:
        ldr r1,[sp,r7]
        cmp r1,r4
        beq NextRound2 //player1 found
        cmp r1,#0
        beq FreeSpot2
        //already belongs to AI
        b CalcNextRow2
        FreeSpot2:
        cmp r9,#0
        beq FirstFreeSpot2
        //too many free spots
        b CalcNextRow2
        FirstFreeSpot2:
        mov r9, r7
        b NextRound2

        CalcNextRow2:
        mov r9, #0 //clear saved spot
        cmp r6,#0
        bne Else22
        add r7, r7, #4
        b NewRow2

        Else22:
        cmp r6, #1
        bne NextRound2
        sub r7, r7, #8
        b NewRow2

        NextRound2:
        add r6, r6, #1
	add r7, r7, #12

	cmp r6, #3
        bne AILoop2
	sub r7, r7, #12
	sub r7, r7, #20

	NewRow2:
	cmp r8,#3
	beq EndAILoop2
        mov r6, #0
        cmp r9, #0
	add r8, r8, #1
        beq AILoop2 //no spot was found

        b SpotIsFound

        EndAILoop2:

	//diagonal
	mov r6, #0 //iteration
	mov r9, #0
	mov r5, #16 //offset to next spot
	mov r7, #12 //offset start
	AILoop3:
	cmp r6, #3
	beq EndAILoop3
	ldr r2, [sp, r7]
	cmp r2, r4 //player1 found -> next iteration
	beq NextAILoop3
	cmp r2, #0
	bne EndAILoop3 //already belongs to AI
	cmp r9, #0
	bne EndAILoop3 //already free spot found
	mov r9, r7
	NextAILoop3:
	add r6, r6, #1
	add r7,r7, r5
	b AILoop3

	EndAILoop3:
	cmp r6, #3
	bne NextTry
	cmp r9, #0
	beq NextTry
	b SpotIsFound
	NextTry:
	cmp r5, #16
	bne EndAILoop3End
	mov r5, #8
	mov r7, #20 //new start
	mov r6, #0
	mov r9, #0
	b AILoop3

	EndAILoop3End:

	add r4, r4, #1
	b BigLoop

	EndBigLoop:


	//find persional best option, player one has nothing in a row

	//search for own spots in a row:



	ldr r5, [sp, #28] //middle
	mov r9, #28
	cmp r5, #0
	beq SpotIsFound






	mov r9, #0
	mov r7, #12
	AILoop4:
	cmp r7,#48
	beq EndAILoop4
	ldr r9, [sp, r7]
	cmp r9, #0
	beq FreeSpace4
	add r7, r7, #4
	b AILoop4

	FreeSpace4:
	mov r9, r7
	b SpotIsFound

	EndAILoop4:
	//error
	ldr r0, =generalError
	bl printf

	SpotIsFound:

	mov r3,#2
        str r3,[sp,r9] //new spot

	//calc coordinates out of offset
	sub r3, r9, #12
	mov r4, #0 //x
	mov r5, #0 //y
	CalcLoopY:
	cmp r5, #3
	beq EndCalcLoop
	CalcLoopX:
	cmp r4, #3
	beq NewRow3
	mov r6, #3
	mul r7,r5, r6
	add r7, r7, r4 //(3*y+x)*4
	lsl r7, r7, #2
	cmp r7, r3 //coordinate is fitting to offset
	beq FoundCoordinate
	add r4, r4, #1
	b CalcLoopX

	NewRow3:
	mov r4, #0
	add r5, r5, #1
	b CalcLoopY

	EndCalcLoop:
	//error!!!!!
	ldr r0, =generalError
	bl printf


	FoundCoordinate:
	add r4, r4, #1
	add r5, r5, #1

	mov r0, r4
	mov r1, r5



	ldr lr, [sp]
	add sp, sp, #4
	bx lr


getName:
//vorher muss sub sp #8 gemacht werden
        sub sp, sp, #4
        str lr, [sp]


        ldr r0,=namen
        mov r1, #1
        bl printf

        ldr r0, =spieler1

        add r1, sp, #4 //spieler 1
        bl scanf

	//Spieler 2 ist die AI
	//sp,#4 ist leer

        ldr lr, [sp]
        add sp, sp, #4
        bx lr


DecidePlayer: //retrurns 1 for 1 Player and 2 for 2 Player
	sub sp, sp, #4
	str lr,[sp]

	ldr r0, =playerDecideInstr
	bl printf

	sub sp, sp, #4

	TryAgain:

	ldr r0, =x

	mov r1, sp
	bl scanf

	ldr r11, [sp]

	//controll:
	cmp r11, #1
	beq LegitValue
	cmp r11, #2
	beq LegitValue
	//error:
	ldr r0,=errorPlayerDecide
	bl printf
	b TryAgain

	LegitValue:

	add sp, sp, #4

	ldr lr, [sp]
	add sp, sp, #4
	bx lr

EndWithNoWinner: //r0 = 1 wenn es keinen Gewinner gibt
        mov r6, #8 //start
        Loop7:
        cmp r6, #44
        beq End7
        ldr r7, [sp, r6]
        cmp r7, #0
        bne NotEmpty
        mov r0, #0
        bx lr

        NotEmpty:
        add r6, r6, #4
        b Loop7

        End7:
        mov r0, #1
        bx lr



legit://r0 = 1 wenn value legit ist, r0 = x , r1 = y
        cmp r0, #1
        beq ValueAIsLegit
        cmp r0, #2
        beq ValueAIsLegit
        cmp r0, #3
        beq ValueAIsLegit

        ValueAIsLegit:
        cmp r1, #1
        beq ValueBIsLegit
        cmp r1, #2
        beq ValueBIsLegit
        cmp r1, #3
        beq ValueBIsLegit

        ValueBIsLegit:

 	mov r6, #8 //start offset
        mov r7, #3
        sub r9, r1, #1
        mul r9, r9 , r7
        sub r8, r0, #1
        add r9, r9, r8
        mov r7, #4
        mul r9, r9, r7
        add r6, r6, r9
        ldr r8, [sp, r6]
        cmp r8, #0
        beq NewValueIsLegit

        NotLegit:
        mov r0, #0
        bx lr



        NewValueIsLegit:
        mov r0, #1
        bx lr

getNames:
//vorher muss sub sp #8 gemacht werden
 	sub sp, sp, #4
        str lr, [sp]


        ldr r0,=namen
        mov r1, #1
        bl printf

        ldr r0, =spieler1

        add r1, sp, #4 //spieler 1
        bl scanf

        ldr r0,=namen
        mov r1, #2
        bl printf


        ldr r0, =spieler1
        add r1, sp, #8 //spieler 2
        bl scanf

        ldr lr, [sp]
        add sp, sp, #4
        bx lr

addValue: // r0 = x r1 = y r2 = spieler 1 oder 2
 	sub sp, sp, #4
        str lr, [sp]

        mov r4, r0
        mov r5, r1
         //faktor m=r6
        sub r6, r5, #1
        //offset in stack r6
        mov r8,#3
        mul r6, r6, r8
        sub r9, r4, #1
        add r6, r6, r9
        mov r8, #4
        mul r6, r6, r8
        // 1 2 3
        // 4 5 6
        // 7 8 9
        add r6,r6, #12 //wegen dem gespeicherten lr

 	mov r7, r2
        str r7, [sp, r6]

        ldr lr, [sp]
        add sp, sp, #4
        bx lr

getInput: // r4 = x und r5 = y
        sub sp, sp, #4
        str lr, [sp]

        ldr r0, =xx
        bl printf
        //x einlesen
        ldr r0, =x
        sub sp, sp, #4
        mov r1, sp
        bl scanf
        ldr r4, [sp]
        add sp, sp, #4

        ldr r0, =yy
        bl printf

        //y einlesen
 	ldr r0, =y
        sub sp, sp, #4
        mov r1, sp
        bl scanf
        ldr r5, [sp]
        add sp, sp, #4

        ldr lr, [sp]
        add sp, sp, #4
        bx lr

printField2:
        sub sp, sp, #4
        str lr, [sp]

        ldr r0, =head
        bl printf
        mov r6, #12 //offset start wegen lr name1 und name2

        mov r7, #1 // start row
        NextRow2:
	cmp r7, #4
        beq End20
        ldr r0, =side
        mov r1, r7
        bl printf

        mov r8, r6
        ldr r0, =row
        ldr r1,[sp,r8]
        add r8,r8, #4
        ldr r2, [sp,r8]
        add r8, r8, #4
        ldr r3, [sp, r8]
        bl printf

        add r6, #12
        add r7, r7, #1
        b NextRow2

        End20:
	ldr lr, [sp]
        add sp, sp, #4
        bx lr

printField:
        sub sp, sp, #4
        str lr, [sp]

        ldr r0, =head
        bl printf
        mov r6, #12 //offset start wegen lr name1 und name2

        mov r7, #0 // start row
        NextRow:
        cmp r7, #0
        beq FirstIteration
        ldr r0, =zeilenumbruch
        bl printf

        FirstIteration:
	add r7, r7, #1
        cmp r7, #4
        beq End
        ldr r0, =side
        mov r1, r7
        bl printf

        mov r8, #1
        Column:
        cmp r8, #4
        beq NextRow
        ldr r5,[sp, r6]

        cmp r5, #0
        beq Leer

        cmp r5, #1
        beq Player1

        //jetzt ist es Player2 - trivial
        ldr r0, =fieldB
        b Print


        Player1:
	ldr r0, =fieldA
        b Print

        Leer:
        ldr r0, =field
        b Print

        Print:
        bl printf


        add r8, r8, #1
        add r6, r6, #4 //next value
        b Column //loop



        End:
        ldr lr, [sp]
        add sp, sp, #4
        bx lr

initialiceValues:
        sub sp, sp, #4
        str lr, [sp]

        mov r7, #12 //offset start
        mov r1, #0 //initial value
        Loop:
        cmp r7, #40
        beq End2
        str r6, [sp, r7]
        add r7, r7, #4
        b Loop

        End2:
        ldr lr, [sp]
        add sp, sp, #4
        bx lr


hasWon: //in r0 ist x und r1 ist y vom grade hinzugefuegten, r2=1 bei Spieler 1 und r2=2 bei$
        mov r4, #1
        mov r5, #8 //start of offset
        mov r6, #3
        sub r7, r1, #1
        mul r7, r7, r6
        mov r6, #4
        mul r7, r7, r6
        add r5, r5, r7 //offset start for y row
        //check row
        mov r9, #1 //result true is default
        Loop1:
        cmp r4, #4
        beq End3
        ldr r8, [sp, r5]
        cmp r2, r8
        beq Same
        mov r9, #0 //not same
        b NextLoop //end loop

        Same:
        add r4, r4, #1
        add r5, r5, #4
        b Loop1

        //check column
	NextLoop:

        cmp r9, #1
        beq End3 //solution found



        mov r9, #1 //reset
        mov r4, #1 //reset
        mov r5,#8 //start
        mov r6, #4
        sub r7, r0, #1
        mul r6, r6, r7
        add r5, r5, r6

        Loop2:
	 cmp r4, #4
        beq NextLoop2

        ldr r8, [sp, r5]
        cmp r2, r8
        beq Same2
        mov r9, #0 //not same
        b NextLoop2 //end loop

        Same2:
        add r4, r4, #1
        add r5, r5, #12 //next row
        b Loop2

        NextLoop2:

        cmp r9, #1
        beq End3 //solution found


        //quer links oben nach rechts unten
        cmp r0, r1
        bne NextLoop3 //der Punkt liegt nicht auf der Linie
        mov r5,#8 //reset
        mov r4, #1
        mov r9, #1 //reset

	 Loop3:
        cmp r4, #4
        beq NextLoop3

        ldr r8, [sp, r5]
        cmp r2, r8
        beq Same3
        mov r9, #0
        b NextLoop3

        Same3:

        add r5, r5, #16 //diagonal nach recht gehen
        add r4, r4, #1
        b Loop3


        NextLoop3:

        cmp r9, #1
        beq End3 //solution found

	  //quer links oben nach rechts unten
        add r6, r1, r2
        cmp r6, #4
        bne End3 //der Punkt liegt nicht auf der Linie
        mov r5,#16 //reset
        mov r4, #1
        mov r9, #1 //reset

        Loop4:
        cmp r4, #4
        beq End3

        ldr r8, [sp, r5]
        cmp r2, r8
        beq Same4
        mov r9, #0
        b End3

	Same4:
        add r5, r5, #8 //diagonal nach links gehen
        add r4, r4, #1
        b Loop4


        End3:

        mov r0, r9 //return result
        bx lr
