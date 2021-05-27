. DRAW
. enter a command (or more commands) to stdin and press enter to draw
. commands:
. - h : displays help on stdout
. - w, a, s, d : moveUp, moveLeft, moveDown, moveRight
. - f : changes drawing symbol to next typed character
. - c : clears the screen and returns to center
. - p : fills the screen with drawing symbol
. - q : halt
.
. examples:    'aaaa wwww dddd ssss' -> draws a 4x4 square
.              'f.' -> changes drawing symbol to '.'
.              'f-dddf df-dddf df-ddd' -> draws a dashed line '--- --- ---'
.
draw START 0 
reset LDA screenColumns            . calculate center:  X = (screenColumns/2) * screenRows  
	DIV #2
	MUL screenRows
	RMO A, X                   . set X to center coordinate
	J help                     . display help (comment this line to skip it)
	J printMousePtr                         
	
input RD #0
	COMP #10                   
	JEQ input                  . newline, ignore
	COMP #113
	JEQ halt                   . q, halt 
	COMP #102
	JEQ switch                 . f, change drawing symbol
	COMP #99
	JEQ clearScreen                  . c, clearScreen screen
	COMP #112
	JEQ fillScreen                   . p, fillScreen screen
	COMP #104
	JEQ help                   . h, help
	COMP #119
	JEQ moveUp                     . w a s d za premikanje kurzorja
	COMP #97
	JEQ moveLeft
	COMP #115
	JEQ moveDown
	COMP #100
	JEQ moveRight
	J input
	
	                          . switch the drawing symbol 
switch RD #0                
	COMP #10                    
	JEQ switch                . newline is ignored, read another character
	STA symbol
	J input                  


printMousePtr LDA mousePtr         . print mousePtr to coordinate in X
	+STCH screen, X
	J input
	
	
	                          . fillScreen screen - load symbol and call screenFill
fillScreen LDA symbol
	JSUB screenFill
	J reset
	
	                          . clearScreen screen - call screenClear
clearScreen JSUB screenClear    
	J reset


screenClear STA tempA           . save A to tempA, set it to space and call writeLastA
	LDA #32 
	J writeLastA
	
screenFill STA tempA            . save A to tempA and call writeLastA
	J writeLastA
	
	                          . move moveLeft
moveLeft LDA symbol             
	+STCH screen, X           . draw symbol to X
	RMO X, A
	DIV screenColumns               . calculate current row ( X / screenColumns)
	STA currentRow
	LDA #1
	SUBR A, X                 . move X one to moveLeft
	RMO X, A                  . if X moved too far moveLeft, it will be one row higher on the moveRight side
	DIV screenColumns               
	COMP currentRow               . X / screenColumns gives us the row X is on
	JLT addScreenColoumns               . if calculated row is lower than currentRow, move one moveDown 
	J printMousePtr

addScreenColoumns LDA screenColumns         . add screenColumns (move X one moveDown)
	ADDR A, X
	J printMousePtr
	
	                          . move moveRight - almost the same as moveUp
moveRight LDA symbol
	+STCH screen, X           . draw symbol, move X to moveRight, check if we went too far
	RMO X, A
	DIV screenColumns
	STA currentRow
	LDA #1
	ADDR A, X
	RMO X, A
	DIV screenColumns
	JGT subtractScreenColoumns              . if calculated row is too high, move X one row moveUp
	J printMousePtr



subtractScreenColoumns LDA screenColumns        . subtract screenColumns (move X one moveUp)
	SUBR A, X
	J printMousePtr

	                          . move moveUp
moveUp LDA symbol
	+STCH screen, X           . print symbol on current X (location of mousePtr) 
	LDA screenColumns               . move X moveUp (X = X - screenColumns)
	SUBR A, X
	LDA #0                    
	COMPR X, A                . if X is too far moveUp, move it to bottom of the screen 
	JLT addLength               
	J printMousePtr  

addLength LDA screenLength          . moves X from above the screen to bottom (adds screenLength)
	ADDR A, X
	J printMousePtr                . add screenLength (move X from top to bottom)
	
	                          . move moveDown - almost the same as moveUp
moveDown LDA symbol             
	+STCH screen, X           . draw symbol to X, move X moveDown one row
	LDA screenColumns
	ADDR A, X                 
	LDA screenLength
	COMPR X, A
	JGT subtractLength              . if X is too far moveDown, move it to top of screen
	J printMousePtr 

subtractLength LDA screenLength         . subtract screenLength (move X from bottom to top)
	SUBR A, X
	J printMousePtr                

help STX tempX               . print help to stdout
	LDX #0
	LDA #helpLength              .calculate length of help text
	SUB #helpText
	SUB #2
	STA helpLength

helpAndWrite LDA helpText, X        . read from helpText, write to stdout
	WD #1
	TIX helpLength               . increment X and compare it to help length
	JEQ restoreX               
	J helpAndWrite    

restoreX LDX tempX . restore X, set A to 0 and go to input
	LDA #0
	J printMousePtr                . draw mousePtr on the screen and wait for new input 
	

	
writeLastA  STX tempX            . write last bit of A to whole screen
	LDX #0 

loop +STCH screen, X
	TIX screenLength
	JEQ return
	J loop
	
return LDX tempX             . reload A and X from tempA and tempX
	LDA tempA
	RSUB               
	
halt J halt
	
tempX RESW 1     
tempA RESW 1
symbol WORD 42                  . drawing symbol
mousePtr WORD 43                . mousePtr symbol
currentRow WORD 12              . current row
screenColumns WORD 80           . screen columns - should be the same as settings in simulator
screenRows WORD 25              . screen rows    
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