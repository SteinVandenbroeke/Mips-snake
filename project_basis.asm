.globl main
.data
	filename:	.asciiz "input.txt"
	testString:	.asciiz "Geel vak"
	found:	.asciiz "U heeft de uitgang gevonden!"
	buffer:		.space 2048
	newLine:	.word 0x0000000d
.text

#################### READ FILE #######################

readFile:
	#stack frame
	sw	$fp, 0($sp)	# push oude frame pointer
	move	$fp, $sp	# frame pointer wijst nu naar bovenaan de stack
	subu	$sp, $sp, 12	# resserveer 12 bytes
	sw	$ra, -4($fp)	# slaag het return adress op op de stack
	sw	$s1, -8($fp)	# slaag alle lokale variabelen op in de stack

	#open file
	li	$v0, 13		#13: syscall open bestand
	la	$a0, filename	#open bestand met het pad filename
	li	$a1, 0		#open for read (0: read, 1: write)
	li	$a2, 0		#mode is ignored
	syscall

	move 	$s1, $v0	#file descriptor in $s1

	#read file -> buffer
	li 	$v0, 14		#syscall voor het bestand te lezen
	move	$a0, $s1	#plaatst het te lezen bestand ($s1) in $a0
	la	$a1, buffer	#plaatst de buffer in $a1
	li	$a2, 2048	#de grote van de buffer
	syscall

	#close file
	li 	$v0, 16		#syscall voor sluiten bestand
	move	$a0, $s1	#plaatst het te sluiten bestand in a0
	syscall

	#return text in $v0
	la	$v0, buffer	#plaatst de buffer (met text file text in) in a0
	
	
	#stack frame
	lw	$s0, -8($fp)	# zet $s1 terug
	lw	$ra, -4($fp)    # zet het return adres terug
	move	$sp, $fp        # 
	lw	$fp, ($sp)	# zet oude frame pointer terug
	jr	$ra		# ga terug naar de aanroeper
	

################# READ FILE  END #####################


################# Maak speelveld #####################

buildMaze:
	#maak de doolhof met het textfile 'filename' en returnt in $a0 de x possistie en $a1 de y possitie van de speler
	#stack frame
	sw	$fp, 0($sp)	# push oude frame pointer
	move	$fp, $sp	# frame pointer wijst nu naar bovenaan de stack
	subu	$sp, $sp, 40	# resserveer 32 bytes
	sw	$ra, -4($fp)	# slaag het return adress op op de stack
	sw	$s0, -8($fp)	# slaag alle lokale variabelen op in de stack
	sw	$s1, -12($fp)	# slaag alle lokale variabelen op in de stack
	sw	$s2, -16($fp)	# slaag alle lokale variabelen op in de stack
	sw	$s3, -20($fp)	# slaag alle lokale variabelen op in de stack
	sw	$s4, -24($fp)	# slaag alle lokale variabelen op in de stack
	sw	$s5, -28($fp)	# slaag alle lokale variabelen op in de stack
	sw	$s6, -32($fp)	# slaag alle lokale variabelen op in de stack
	sw	$s7, -36($fp)	# slaag alle lokale variabelen op in de stack
	
	jal 	readFile	#lees het bestand uit
	li	$s0, 0		#zet alle variable terug
	li	$s1, 0
	li	$s2, 0
	li	$s3, 0
	li	$s4, 0
	li	$s5, 0
	li	$s6, 0
	li	$s7, 0
	move	$s4, $v0	#plaats de text in $s4
	j 	loopChars	#ga elk teken af van $s4
	
endBuildMaze:
	#stack frame end
	move	$v0, $s6	#x location player
	move	$v1, $s7	#y location player
	lw	$s7, -36($fp)	# zet $s1 terug
	lw	$s6, -32($fp)	# zet $s1 terug
	lw	$s5, -28($fp)	# zet $s1 terug
	lw	$s4, -24($fp)	# zet $s1 terug
	lw	$s3, -20($fp)	# zet $s1 terug
	lw	$s2, -16($fp)	# zet $s1 terug
	lw	$s1, -12($fp)	# zet $s1 terug
	lw	$s0, -8($fp)	# zet $s1 terug
	lw	$ra, -4($fp)    # zet het return adres terug
	move	$sp, $fp        # 
	lw	$fp, ($sp)	# zet oude frame pointer terug
	jr	$ra		# ga terug naar de aanroeper
	
loopChars:
	#s0 = kleur
	#s1 = x
	#s2 = y
	#s3 = charCounter
	#s4 = textFile
	#s5 = kleur
	#loop chars van $a0
	lb	$t0, 0($s4)
	
	#if w			#plaatst 'w' in $t7
	beq 	$t0, 'w', createWall	#indien de input 'w' is ga naar 'createWall'
	
	#if p
	beq 	$t0, 'p', passage	#indien de input 'p' is ga naar 'passage'
	
	#if s
	beq 	$t0, 's', playerPos	#indien de input 's' is ga naar 'playerPos'
	
	#if u
	beq 	$t0, 'u', exitLocation	#indien de input 'u' is ga naar 'exitLocation'
	
	#if e
	beq 	$t0, 'e', enemy		#indien de input 'e' is ga naar 'enemy'
	
	#if c
	beq 	$t0, 'c', candy		#indien de input 'e' is ga naar 'candy'
	
	#if newLine
	lw 	$t7, newLine		#plaatst 'u' in $t7
	beq 	$t0, $t7, endOfRow	#indien de input 'newLine' is ga naar 'endOfRow'
	j endBuildMaze
	
createWall:
	li $s5, 0x000000ff		#zet in $t1 de kleur (blauw)
	j sendToScreen			#print de kleur uit op de x,y ($s1, $s2) locatie

passage:
	li $s5, 0x00000000		#zet in $t1 de kleur (zwart)
	j sendToScreen			#print de kleur uit op de x,y ($s1, $s2) locatie

playerPos:
	move 	$s6, $s1
	move 	$s7, $s2
	
	li $s5, 0x00ffff00		#zet in $t1 de kleur (geel)
	j sendToScreen			#print de kleur uit op de x,y ($s1, $s2) locatie

exitLocation:
	li $s5, 0x0000ff00		#zet in $t1 de kleur (groen)
	j sendToScreen			#print de kleur uit op de x,y ($s1, $s2) locatie

enemy:
	li $s5, 0x00ff0000		#zet in $t1 de kleur (rood)
	j sendToScreen			#print de kleur uit op de x,y ($s1, $s2) locatie

candy:
	li $s5, 0x00ffffff		#zet in $t1 de kleur (wit)
	j sendToScreen			#print de kleur uit op de x,y ($s1, $s2) locatie
	
endOfRow:
	addi $s2, $s2, 1
	li   $s1, 0
	addi 	$s4, $s4, 2
	j loopChars

sendToScreen:
	move 	$a0, $s1		#plaats de x in argument 0
	move 	$a1, $s2		#plaats de y in argument 1
	jal 	pixelLocation		#bereken de pixel locatie
	sw	$s5,($v0) 		#s5 = kleur; $v0 = adres
	addi 	$s1, $s1, 1		#x = x + 1
	addi 	$s4, $s4, 1		#verwijder het eerste teken van de sting
	j loopChars			#ge terug naar loop chars
	
############## Maak speelveld END ####################


############## Bereken pixel Locatie ###############
pixelLocation:
	#berekend de locatie van de pixel op het scherm
	# $a0 = x, $a1 = y, print 
	sw	$fp, 0($sp)	# push oude frame pointer
	move	$fp, $sp	# frame pointer wijst nu naar bovenaan de stack
	subu	$sp, $sp, 8	# resserveer 32 bytes
	sw	$ra, -4($fp)	# slaag het return adress op op de stack
	
	li	$t1, 4
	mul	$t0, $a0, $t1	#berekend de possitie van de x'ste pixel door x*4 te doen
	
	li	$t1, 128	
	mul	$t1, $a1, $t1	#berekend de possitie van de y'de pixel door y*128 te doen (128 = 4*32) (32 pixel breed)
	add	$t0, $t0, $t1	#tel de X en Y op
	add	$t0, $t0, $gp	#tel de $gp (pixel 0,0) er bij op
    	move 	$v0, $t0	#laad het adres in $v0
    	
	lw	$ra, -4($fp)    # zet het return adres terug
	move	$sp, $fp        # 
	lw	$fp, ($sp)	# zet oude frame pointer terug
	jr	$ra		# ga terug naar de aanroeper

############## Bereken pixel locatie END ############



############## Update player posistion ##############
updatePossition:
	#$a0 = x pos nu
	#$a1 = y pos nu
	#$a2 = x pos to
	#$a3 = y pos to
	sw	$fp, 0($sp)	# push oude frame pointer
	move	$fp, $sp	# frame pointer wijst nu naar bovenaan de stack
	subu	$sp, $sp, 8	# resserveer 32 bytes
	sw	$ra, -4($fp)	# slaag het return adress op op de stack
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	
	move $a0, $s2
	move $a1, $s3
	jal pixelLocation
	move $s4, $v0
	lw $t1, ($s4)
	
	beq $t1, 0x00000000,Go		#bij een passage
	beq $t1, 0x0000ff00,exitGo	#bij de exit
	beq $t1, 0x00ffffff,Go		#Bij de candy
	
	beq $t1, 0x000000ff,NotGO	#bij een muur
	
	j updatePossitionVervolg
	
Go:
	move $a0, $s0
	move $a1, $s1
	jal pixelLocation
	li $s5, 0x00000000		#zet in $t1 de kleur (zwart)
	sw	$s5,($v0) 		#s5 = kleur; $v0 = adres
	
	move $a0, $s2
	move $a1, $s3
	jal pixelLocation
	li $s5, 0x00ffff00		#zet in $t1 de kleur (zwart)		
	sw	$s5,($v0) 		#s5 = kleur; $v0 = adres
	
	move $v0, $s2
	move $v1, $s3
	j updatePossitionVervolg
	
NotGO:
	move $v0, $s0
	move $v1, $s1
	j updatePossitionVervolg
exitGo:
	move $a0, $s0
	move $a1, $s1
	jal pixelLocation
	li $s5, 0x00000000		#zet in $t1 de kleur (zwart)
	sw	$s5,($v0) 		#s5 = kleur; $v0 = adres
	
	move $a0, $s2
	move $a1, $s3
	jal pixelLocation
	li $s5, 0x00ffff00		#zet in $t1 de kleur (zwart)		
	sw	$s5,($v0) 		#s5 = kleur; $v0 = adres
	
	la $a0, found
	li $v0, 4
	syscall
	
	li $v0, 10
	syscall
	

	
updatePossitionVervolg:
	lw	$ra, -4($fp)    # zet het return adres terug
	move	$sp, $fp        # 
	lw	$fp, ($sp)	# zet oude frame pointer terug
	jr	$ra		# ga terug naar de aanroeper
	
########### Update player posistion END #############


##################### Main LOOP #####################
MainLoop:
	#v0 = x & v1 = y
	move $a0, $s0
	move $a1, $s1
	
	lw $t0, 0xffff0000	#is 1 wanneer er een input beschikbaar is
	beq $t0, 1, input	#indien er een input is ga naar 'input'
	
	li $a0, 60
	li $v0, 32
	syscall
	
	j MainLoop		#indien er geen input is kijk terug of er een input is
	
input:
	lw $t5, 0xffff0004	#lees de input in $t5
	
	beq $t5, 'z', up	#indien de input 'z' is ga naar 'up'

	beq $t5,'s', down	#indien de input 's' is ga naar 'up'

	beq $t5, 'q', left	#indien de input 'q' is ga naar 'left'
	
	beq $t5, 'd', right
	
	j MainLoop
down:
	addi $a3,$s1, 1
	move $a2,$s0
	j ex
left:
	subi $a2,$s0, 1
	move $a3,$s1
	j ex
right:
	addi $a2,$s0, 1
	move $a3,$s1
	j ex
up:
	subi $a3,$s1, 1
	move $a2,$s0
	j ex
	
ex:
	jal updatePossition
	move $s0, $v0
	move $s1, $v1
	j MainLoop
################## Main LOOP END ####################


main:
	jal 	buildMaze	#$v0 = x van speler, $v1 = y van speler
	move $s0, $v0
	move $s1, $v1
	j 	MainLoop
		
	move	$a0, $s1	#plaatst de buffer (met text file text in) in a0
	li 	$v0, 10		#syscall voor string print
	syscall
