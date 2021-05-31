draw START 0 
reset LDA screenColumns            .calling reset will calculate center:  X = (screenColumns/2) * screenRows  
	DIV #2
	MUL screenRows
	RMO A, X                   . set X to center coordinate
	J help                     . as the program start display help
	J printMousePtr            . jump to printMouseptr           
	
input RD #0

	COMP #10                   
	JEQ input                  . newline,basically like ignore
	COMP #104
	JEQ help                   . pressing h,will display the commands
	COMP #99
	JEQ clearScreen            . pressing c,clears the whole screen
	COMP #112
	JEQ fillScreen             . pressing p,fills the whole screen
	COMP #119
	JEQ moveUp                 . pressing w,will move the mousepointer upwards
	COMP #97
	JEQ moveLeft               . pressing a,will move the mousepointer leftwards
	COMP #115
	JEQ moveDown               . pressing s,will move the mousepointer downwards
	COMP #100
	JEQ moveRight              . pressing d,will move the mousepointer rightwards
	COMP #113
	JEQ halt                   . pressing q,will halt the running execution 
	COMP #102
	JEQ switch                 . pressing f along with the character will change the drawing symbol
	J input
	
	                          
switch RD #0                       .This is called when user enter f,for switching the drawing symbol 
	COMP #10                    
	JEQ switch                 
	STA symbol                 .The character entered along with f,is stored in the variable symbol
	J input                  


printMousePtr LDA mousePtr         .This will the print mousePtr to coordinate stored in X
	+STCH screen, X
	J input
	
	
	                          
fillScreen LDA symbol               .This will first load the symbol 
	JSUB screenFill             .Here it will then call the subroutine screenFill
	J reset
	
	                          
clearScreen JSUB screenClear        .On calling the clearScreen - it will call the subroutine screenClear
	J reset


screenClear STA tempA               .it will first store the value of accumulator to tempA
	LDA #32                     .It will then set Accumulator to space
	J writeLastA                .Then it will call writeLastA
	
screenFill STA tempA                .it will first store the value of accumulator to tempA
	J writeLastA                .Then it will call writeLastA
	
	                          
moveLeft LDA symbol               . First load the symbol into accumulator
	+STCH screen, X           . draw symbol in X to the screen
	RMO X, A                    
	DIV screenColumns         .calculate the current row i.e. by dividing X with screenColumns
	STA currentRow            .store in the currentRow,the value calculated
	LDA #1                    .load 1 in accumulator
	SUBR A, X                 .move X one to moveLeft
	RMO X, A                  .if X moved too far moveLeft, it will be one row higher on the moveRight side
	DIV screenColumns         .dividing X by screenColumns gives us the row X is on     
	COMP currentRow            
	JLT addScreenColoumns     .if calculated row is lower than currentRow, move one moveDown 
	J printMousePtr           .jump to printMousePointer

addScreenColoumns LDA screenColumns     .load screeColoumns into the Accumulator
	ADDR A, X                       .add screenColumns i.e. move X one moveDown
	J printMousePtr                 .jump to printMousePtr
	
	                          
moveRight LDA symbol                    . First load the symbol into accumulator
	+STCH screen, X                 . draw symbol, check if we went too far
	RMO X, A
	DIV screenColumns               . calculate the current row i.e. by dividing X with screenColumns
	STA currentRow                  . store in the currentRow,the value calculated
	LDA #1                          . load 1 in accumulator
	ADDR A, X                       .  move X to moveRight
	RMO X, A
	DIV screenColumns               . calculate again the calcualted row
	JGT subtractScreenColoumns      . if calculated row is too high, move X one row moveUp
	J printMousePtr



subtractScreenColoumns LDA screenColumns         . load screenColumns in Accumulator
	SUBR A, X                                . Subtract register A and X i.e. move X one moveUp
	J printMousePtr                          . jump to printMousePtr

	                          
moveUp LDA symbol                   . First Load the symbol
	+STCH screen, X             . Then print symbol on current X i.e. location of mousePtr
	LDA screenColumns           . load screenColumns into Accumulator. move X moveUp (X = X - screenColumns)
	SUBR A, X                   . Subtract register A and X
	LDA #0                      . Load 0 in the accumulator
	COMPR X, A                  . this will compare values stored in register X with A 
	JLT addLength               . if X is too far from moveUp, then move it to bottom of the screen
	J printMousePtr             . jump to printMousePtr

addLength LDA screenLength          . moves X from above the screen to bottom (adds screenLength)
	ADDR A, X                   . This will then add screenLength i.e. move X from top to bottom
	J printMousePtr             . jump to printMousePtr
	
	                          
moveDown LDA symbol                   . First load the symbol
	+STCH screen, X               . draw symbol to X, move X moveDown one row
	LDA screenColumns             . load screenColumns into Accumulator
	ADDR A, X                     . Add register A and X
	LDA screenLength              . load screenLength into Accumulator
	COMPR X, A                    . this will compare values stored in register X with A
	JGT subtractLength            . if X is too far from moveDown,then move it to top of screen
	J printMousePtr               . jump to printMousePtr

subtractLength LDA screenLength         .This will first load screenLength into the accumulator 
	SUBR A, X                       .This will then subtract the screenLength i.e. (move X from bottom to top)
	J printMousePtr                 .This will then jump to printMousePtr

help STX tempX                          .This will print help texts to stdout
	LDX #0                          .Load 0 into X
	LDA #helpLength                 .This calculates the length of help text
	SUB #helpText                    
	SUB #2
	STA helpLength

helpAndWrite LDA helpText, X         .This will read from helpText
	WD #1                        .This will write to stdout
	TIX helpLength               .This step increases X and then compare it to help length
	JEQ restoreX                 .if Equal,it will call restoreX
	J helpAndWrite               .else it will loop

restoreX LDX tempX                   . This will restore X 
	LDA #0                       . This will set A to 0
	J printMousePtr              . this will draw mousePtr on the screen and also wait for new input 
	

	
writeLastA  STX tempX            .This write the last bit of A to the whole screen
	LDX #0 

loop +STCH screen, X
	TIX screenLength
	JEQ return
	J loop
	
return LDX tempX             . This reloads X from tempX
	LDA tempA            . Also reloads A from tempA
	RSUB               
	
halt J halt
	
tempX RESW 1     
tempA RESW 1
symbol WORD 42                  . the symbol being drawn on the screen
mousePtr WORD 43                . the symbol for the mouseptr
currentRow WORD 12              . this stores the current row
screenColumns WORD 80           . no of columns in screen
screenRows WORD 25              . no of rows in screen  (screenColumns and screenRows should be same in simulator settings as intialized here)
screenLength WORD 2000


. help text
helpText BYTE C'  ---DRAW---'    
	BYTE 10
	BYTE C'Type a command (or more commands) to standard input and press enter to execute them'
	BYTE 10
	BYTE C'Command Lists:'
	BYTE 10
	BYTE C'- h: displays help on stdout'
	BYTE 10
	BYTE C'- w,a,s,d: moveUp, moveLeft, moveDown, moveRight'
	BYTE 10
	BYTE C'- f: changes drawing symbol to next typed character'
	BYTE 10
	BYTE C'- c: clears the screen and returns to center'
	BYTE 10
	BYTE C'- p: fills screen with drawing symbol'
	BYTE 10
	BYTE C'- q: halt'   
	BYTE 10
helpLength RESW 1         
	
	ORG 47104           . screen address in memory
screen RESB 1