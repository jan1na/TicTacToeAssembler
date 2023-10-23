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
winner: .asciz "%c hat gewonnen!\n"
loop: .asciz "in loop: %d"
tab: .asciz " "
fieldA: .asciz "[X]"
fieldB: .asciz "[O]"
zeilenumbruch: .asciz "\n"
field: .asciz "[ ]"
error: .asciz "Eingabe ist nicht legit. Versuche es nochmal:\n"
noWinner: .asciz "Es gibt keinen Gewinner.\n"


.text
.align 4
.global main

.extern printf
main:
	sub sp, sp, #4
	str lr, [sp]

	sub sp, sp, #44

	//initialice stack
	bl initialiceValues

	bl getNames

	bl printField

	GameLoop:

	bl EndWithNoWinner
	cmp r0, #1
	bne NotFinished1
	ldr r0, =noWinner
	bl printf
	b End4

	NotFinished1:

	ldr r0, =instruction
	ldr r1, [sp]
	bl printf

	Again1:

	bl getInput

//	mov r1, r4
//	mov r2, r5
//	ldr r0, =output
//	bl printf


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
	mov r2, #1
	bl addValue

	mov r0, r4
	mov r1, r5
	mov r2, #1
	bl hasWon

	cmp r0, #1
	bne noWinner1
	ldr r0, =winner
	ldr r1, [sp]
	bl printf
	b End4

	noWinner1:

	bl printField


	bl EndWithNoWinner
        cmp r0, #1
        bne NotFinished2
        ldr r0, =noWinner
        bl printf
        b End4

	NotFinished2:

	ldr r0, =instruction
        ldr r1, [sp,#4]
        bl printf

	Again2:

        bl getInput

//      mov r1, r4
//      mov r2, r5
//      ldr r0, =output
//      bl printf

	mov r0, r4
        mov r1, r5
        bl legit
        cmp r0, #1
        beq Ok2
        ldr r0, =error
	bl printf
        b Again2

        Ok2:

        mov r0,r4
        mov r1, r5
	mov r2, #2
        bl addValue

        mov r0, r4
        mov r1, r5
        mov r2, #2
        bl hasWon

        cmp r0, #1 //wenn 1 dann gewonnen
        bne noWinner2
        ldr r0, =winner
        ldr r1, [sp, #4]
        bl printf
	b End4

        noWinner2:

        bl printField


	b GameLoop

	End4:
	bl printField

	add sp, sp, #44

	ldr lr , [sp]
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

hasWon: //in r0 ist x und r1 ist y vom grade hinzugefuegten, r2=1 bei Spieler 1 und r2=2 bei Spieler 2
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
