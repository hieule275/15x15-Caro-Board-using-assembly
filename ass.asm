.data
outfile: .asciiz "D:/result.txt" 
input1: .asciiz "Player 1, please input your coordinates: "
input2: .asciiz "Player 2, please input your coordinates: "
win1: .asciiz "Player 1 wins"
win2: .asciiz "Player 2 wins"
tie: .asciiz "Tie"
arr: .word 0:225 #mảng 15x15
newline: .asciiz "\n"
comma: .asciiz ", "
space: .ascii " "
line: .asciiz "|"
xy: .space 100
x: .space 5
y: .space 5
final: .asciiz "Final version of the board"
writex: .asciiz "X"
writeo: .asciiz "O"
msgInvalid: .asciiz "Input wrong format!\n"
reinput1: .asciiz "Please reinput your coordinates again, player 1: "
reinput2: .asciiz "Please reinput your coordinates again, player 2: "
outofrange: .asciiz "Out of range!\n"
same: .asciiz "That position has been inserted!\n"
.text
main:
# --- In 15 dòng, mỗi dòng có 15 dấu phân cách (ô trống) ---
    li $t8, 0              # $t8 = chỉ số dòng
loopout:
    li $v0, 4 
    la $a0, line
    syscall

    li $t1, 0              # $t1 = chỉ số cột
loopin:
    li $v0, 4 
    la $a0, space 
    syscall                # in khoảng trắng (ô rỗng)

    addi $t1, $t1, 1 
    bne $t1, 15, loopin

    addi $t8, $t8, 1  
    li $v0, 4 
    la $a0, newline 
    syscall                # xuống dòng mới

    beq $t8, 15, exitbegin  
    j loopout     

exitbegin:
li $t8,0 #đặt biến count=0
j loopinput

again1:
li $v0, 4 
la $a0, reinput1 
syscall# in "Please reinput your coordinates again, player 1: "
j split1

again2:
li $v0, 4 
la $a0, reinput2 
syscall# in "Please reinput your coordinates again, player 2: "
j split2

againrange1:
li $v0, 4 
la $a0, outofrange#in "Out of range! 
syscall
li $v0, 4 
la $a0, reinput1 
syscall
j split1

againrange2:
li $v0, 4 
la $a0, outofrange#in "Out of range! 
syscall
li $v0, 4 
la $a0, reinput2 
syscall
j split2

againsame1:
li $v0, 4 
la $a0, same#in "That position has been inserted!" 
syscall
li $v0, 4 
la $a0, reinput1 
syscall
j split1

againsame2:
li $v0, 4 
la $a0, same#in "That position has been inserted!" 
syscall
li $v0, 4 
la $a0, reinput2 
syscall
j split2

loopinput:
li $v0, 4 
la $a0, input1 
syscall# in "Player 1, please input your coordinates: "

split1:
# Đọc chuỗi
    li $v0, 8
    la $a0, xy
    li $a1, 100
    syscall

    # Loại bỏ ký tự '\n' nếu có trong inputStr
    la $t5, xy
remove_newline:
    lb $t6, 0($t5)
    beqz $t6, done_remove_newline
    li $t7, 10          # ASCII của '\n'
    beq $t6, $t7, replace_null
    addi $t5, $t5, 1
    j remove_newline

replace_null:
    sb $zero, 0($t5)

done_remove_newline:

    # Kiểm tra định dạng chuỗi
    la $a0, xy
    jal validate_input
    beqz $v0, continue_program

    # Nếu không hợp lệ
    li $v0, 4
    la $a0, msgInvalid
    syscall
    j again1

continue_program:


    # Tách chuỗi
    la $t0, xy   # đọc inputStr
    la $t1, x      # ghi num1
    la $t2, y       # ghi num2

read_loop:
    lb $t3, 0($t0)
    beqz $t3, end_copy
    li $t4, 44         # ASCII ',' (dấu phẩy)
    beq $t3, $t4, switch_to_num2

    sb $t3, 0($t1)
    addi $t1, $t1, 1
    addi $t0, $t0, 1
    j read_loop

switch_to_num2:
    sb $zero, 0($t1)   # kết thúc chuỗi num1
    addi $t0, $t0, 1   # bỏ qua dấu ','

copy_num2:
    lb $t3, 0($t0)
    beqz $t3, end_copy
    sb $t3, 0($t2)
    addi $t2, $t2, 1
    addi $t0, $t0, 1
    j copy_num2

end_copy:
    sb $zero, 0($t2)   # kết thúc chuỗi num2

    #### Convert num1 to integer ####
    la $a0, x
    jal atoi
    move $s0, $v0     # $s0 = số nguyên từ num1

    #### Convert num2 to integer ####
    la $a0, y
    jal atoi
    move $s1, $v0     # $s1 = số nguyên từ num2
    
blt $s0,0,againrange1
blt $s1,0,againrange1
bgt $s0,14,againrange1
bgt $s1,14,againrange1#xét điều kiện out of range của player1

#Tính offset=(x*15+y)*4
mul $t0,$s0,15#x*15
add $t0,$t0,$s1#x*15+y
mul $t0,$t0,4
la $t1,arr
add $t2,$t1,$t0
lw $t3,0($t2)
beq $t3,88,againsame1
beq $t3,79,againsame1#xét nếu vị trí đó đã bị trùng
li $t3,88
sw $t3,0($t2)
addi $t8,$t8,1#update count


#in ket qua ma tran sau moi lan nhap
li $t0,0#đặt x=0
li $t1,0#đặt y=0
innerloopforX:
#Tính offset=(x*15+y)*4
mul $t2,$t0,15#x*15
add $t2,$t2,$t1#x*15+y
mul $t2,$t2,4
la $t3,arr
add $t4,$t3,$t2
lw $t5,0($t4)
beq $t5,88,printXforX
beq $t5,79,printOforX

li $v0, 4 
la $a0, line 
syscall

li $a0,32
li $v0,11
syscall#in khoang trang

addi $t1,$t1,1#cap nhat y
beq $t1,15,outerloopforX#neu vuot qua số cột nhảy qua loop ngoài
j innerloopforX

outerloopforX:

li $v0, 4 
la $a0, line 
syscall

li $v0, 4 
la $a0, newline 
syscall# in xuống dòng

addi $t0,$t0,1#cap nhat x
beq $t0,15,exitforX# nếu vượt quá số hàng, thoát ra kết thúc
li $t1,0
j innerloopforX

printXforX:

li $v0, 4 
la $a0, line 
syscall

move $a0,$t5
li $v0,11
syscall#in X or O

addi $t1,$t1,1#cap nhat y
beq $t1,15,outerloopforX#neu vuot qua số cột nhảy qua loop ngoài
j innerloopforX

printOforX:

li $v0, 4 
la $a0, line 
syscall

move $a0,$t5
li $v0,11
syscall#in X or O

addi $t1,$t1,1#cap nhat y
beq $t1,15,outerloopforX#neu vuot qua số cột nhảy qua loop ngoài
j innerloopforX
exitforX:#thoat ra sau khi hien het ket qua cua lan nhap do

li $t6,1#đặt biến count để duyệt tìm người thắng
move $t0,$s0#x
move $t1,$s1#y
li $t9,1
loopforvertical1:#duyệt thắng đường dọc
mul $t2,$t9,1#dx*i
add $t2,$t0,$t2#x+dx*i
mul $t3,$t9,0#dy*i
add $t3,$t1,$t3#y+dy*i

blt $t2,0,breakloop1
bge $t2,15,breakloop1
blt $t3,0,breakloop1
bge $t3,15,breakloop1
#Tính offset=(x*15+y)*4
mul $t2,$t2,15#x*15
add $t2,$t2,$t3#x*15+y
mul $t2,$t2,4
la $t3,arr
add $t4,$t3,$t2
lw $t5,0($t4)
bne $t5,88,breakloop1
addi $t6,$t6,1#update count
beq $t6,5,printwinner1
addi $t9,$t9,1
beq $t9,5,exitloopforvertical2
j loopforvertical1
breakloop1:
addi $t9,$t9,1
beq $t9,5,exitloopforvertical2
j loopforvertical1
exitloopforvertical2:


li $t9,1
loopforvertical2:#duyệt thắng đường dọc hướng ngược lại
mul $t2,$t9,1#dx*i
sub $t2,$t0,$t2#x-dx*i
mul $t3,$t9,0#dy*i
sub $t3,$t1,$t3#y-dy*i

blt $t2,0,breakloop2
bge $t2,15,breakloop2
blt $t3,0,breakloop2
bge $t3,15,breakloop2
#Tính offset=(x*15+y)*4
mul $t2,$t2,15#x*15
add $t2,$t2,$t3#x*15+y
mul $t2,$t2,4
la $t3,arr
add $t4,$t3,$t2
lw $t5,0($t4)
bne $t5,88,breakloop2
addi $t6,$t6,1#update count
beq $t6,5,printwinner1
addi $t9,$t9,1
beq $t9,5,exitloopforhorizontal1
j loopforvertical2
breakloop2:
addi $t9,$t9,1
beq $t9,5,exitloopforhorizontal1
j loopforvertical2
exitloopforhorizontal1:

li $t6,1#đặt biến count để duyệt tìm người thắng
li $t9,1
loopforhorizontal1:#duyệt thắng đường ngang
mul $t2,$t9,0#dx*i
add $t2,$t0,$t2#x+dx*i
mul $t3,$t9,1#dy*i
add $t3,$t1,$t3#y+dy*i

blt $t2,0,breakloop3
bge $t2,15,breakloop3
blt $t3,0,breakloop3
bge $t3,15,breakloop3
#Tính offset=(x*15+y)*4
mul $t2,$t2,15#x*15
add $t2,$t2,$t3#x*15+y
mul $t2,$t2,4
la $t3,arr
add $t4,$t3,$t2
lw $t5,0($t4)
bne $t5,88,breakloop3
addi $t6,$t6,1#update count
beq $t6,5,printwinner1
addi $t9,$t9,1
beq $t9,5,exitloopforhorizontal2
j loopforhorizontal1
breakloop3:
addi $t9,$t9,1
beq $t9,5,exitloopforhorizontal2
j loopforhorizontal1
exitloopforhorizontal2:

li $t9,1
loopforhorizontal2:#duyệt thắng đường ngang hướng ngược lại
mul $t2,$t9,0#dx*i
sub $t2,$t0,$t2#x-dx*i
mul $t3,$t9,1#dy*i
sub $t3,$t1,$t3#y-dy*i

blt $t2,0,breakloop4
bge $t2,15,breakloop4
blt $t3,0,breakloop4
bge $t3,15,breakloop4
#Tính offset=(x*15+y)*4
mul $t2,$t2,15#x*15
add $t2,$t2,$t3#x*15+y
mul $t2,$t2,4
la $t3,arr
add $t4,$t3,$t2
lw $t5,0($t4)
bne $t5,88,breakloop4
addi $t6,$t6,1#update count
beq $t6,5,printwinner1
addi $t9,$t9,1
beq $t9,5,exitloopfordiagonal1
j loopforhorizontal2
breakloop4:
addi $t9,$t9,1
beq $t9,5,exitloopfordiagonal1
j loopforhorizontal2
exitloopfordiagonal1:

li $t6,1#đặt biến count để duyệt tìm người thắng
li $t9,1
loopfordiagonal1:#duyệt thắng đường chéo \
mul $t2,$t9,1#dx*i
add $t2,$t0,$t2#x+dx*i
mul $t3,$t9,1#dy*i
add $t3,$t1,$t3#y+dy*i

blt $t2,0,breakloop5
bge $t2,15,breakloop5
blt $t3,0,breakloop5
bge $t3,15,breakloop5
#Tính offset=(x*15+y)*4
mul $t2,$t2,15#x*15
add $t2,$t2,$t3#x*15+y
mul $t2,$t2,4
la $t3,arr
add $t4,$t3,$t2
lw $t5,0($t4)
bne $t5,88,breakloop5
addi $t6,$t6,1#update count
beq $t6,5,printwinner1
addi $t9,$t9,1
beq $t9,5,exitloopfordiagonal2
j loopfordiagonal1
breakloop5:
addi $t9,$t9,1
beq $t9,5,exitloopfordiagonal2
j loopfordiagonal1
exitloopfordiagonal2:

li $t9,1
loopfordiagonal2:#duyệt thắng đường chéo \ hướng ngược lại
mul $t2,$t9,1#dx*i
sub $t2,$t0,$t2#x-dx*i
mul $t3,$t9,1#dy*i
sub $t3,$t1,$t3#y-dy*i

blt $t2,0,breakloop6
bge $t2,15,breakloop6
blt $t3,0,breakloop6
bge $t3,15,breakloop6
#Tính offset=(x*15+y)*4
mul $t2,$t2,15#x*15
add $t2,$t2,$t3#x*15+y
mul $t2,$t2,4
la $t3,arr
add $t4,$t3,$t2
lw $t5,0($t4)
bne $t5,88,breakloop6
addi $t6,$t6,1#update count
beq $t6,5,printwinner1
addi $t9,$t9,1
beq $t9,5,exitloopfordiagonal3
j loopfordiagonal2
breakloop6:
addi $t9,$t9,1
beq $t9,5,exitloopfordiagonal3
j loopfordiagonal2
exitloopfordiagonal3:

li $t6,1#đặt biến count để duyệt tìm người thắng
li $t9,1
loopfordiagonal3:#duyệt thắng đường chéo /
mul $t2,$t9,1#dx*i
add $t2,$t0,$t2#x+dx*i
mul $t3,$t9,-1#dy*i
add $t3,$t1,$t3#y+dy*i

blt $t2,0,breakloop7
bge $t2,15,breakloop7
blt $t3,0,breakloop7
bge $t3,15,breakloop7
#Tính offset=(x*15+y)*4
mul $t2,$t2,15#x*15
add $t2,$t2,$t3#x*15+y
mul $t2,$t2,4
la $t3,arr
add $t4,$t3,$t2
lw $t5,0($t4)
bne $t5,88,breakloop7
addi $t6,$t6,1#update count
beq $t6,5,printwinner1
addi $t9,$t9,1
beq $t9,5,exitloopfordiagonal4
j loopfordiagonal3
breakloop7:
addi $t9,$t9,1
beq $t9,5,exitloopfordiagonal4
j loopfordiagonal3
exitloopfordiagonal4:

li $t9,1
loopfordiagonal4:#duyệt thắng đường chéo / hướng ngược lại
mul $t2,$t9,1#dx*i
sub $t2,$t0,$t2#x-dx*i
mul $t3,$t9,-1#dy*i
sub $t3,$t1,$t3#y-dy*i

blt $t2,0,breakloop8
bge $t2,15,breakloop8
blt $t3,0,breakloop8
bge $t3,15,breakloop8
#Tính offset=(x*15+y)*4
mul $t2,$t2,15#x*15
add $t2,$t2,$t3#x*15+y
mul $t2,$t2,4
la $t3,arr
add $t4,$t3,$t2
lw $t5,0($t4)
bne $t5,88,breakloop8
addi $t6,$t6,1#update count
beq $t6,5,printwinner1
addi $t9,$t9,1
beq $t9,5,exitforinput2
j loopfordiagonal4
breakloop8:
addi $t9,$t9,1
beq $t9,5,exitforinput2
j loopfordiagonal4
exitforinput2:

beq $t8,225,exitinput

li $v0, 4 
la $a0, input2 
syscall# in "Player 2, please input your coordinates: "

split2:
# Đọc chuỗi
    li $v0, 8
    la $a0, xy
    li $a1, 100
    syscall

    # Loại bỏ ký tự '\n' nếu có trong inputStr
    la $t5, xy
remove_newlineforO:
    lb $t6, 0($t5)
    beqz $t6, done_remove_newlineforO
    li $t7, 10          # ASCII của '\n'
    beq $t6, $t7, replace_nullforO
    addi $t5, $t5, 1
    j remove_newlineforO

replace_nullforO:
    sb $zero, 0($t5)

done_remove_newlineforO:

 # Kiểm tra định dạng chuỗi
    la $a0, xy
    jal validate_input
    beqz $v0, continue_program2

    # Nếu không hợp lệ
    li $v0, 4
    la $a0, msgInvalid
    syscall
    j again2

continue_program2:

    # Tách chuỗi
    la $t0, xy   # đọc inputStr
    la $t1, x      # ghi num1
    la $t2, y       # ghi num2

read_loopforO:
    lb $t3, 0($t0)
    beqz $t3, end_copyforO
    li $t4, 44         # ASCII ',' (dấu phẩy)
    beq $t3, $t4, switch_to_num2forO

    sb $t3, 0($t1)
    addi $t1, $t1, 1
    addi $t0, $t0, 1
    j read_loopforO

switch_to_num2forO:
    sb $zero, 0($t1)   # kết thúc chuỗi num1
    addi $t0, $t0, 1   # bỏ qua dấu ','

copy_num2forO:
    lb $t3, 0($t0)
    beqz $t3, end_copyforO
    sb $t3, 0($t2)
    addi $t2, $t2, 1
    addi $t0, $t0, 1
    j copy_num2forO

end_copyforO:
    sb $zero, 0($t2)   # kết thúc chuỗi num2

    #### Convert num1 to integer ####
    la $a0, x
    jal atoi
    move $s0, $v0     # $s0 = số nguyên từ num1

    #### Convert num2 to integer ####
    la $a0, y
    jal atoi
    move $s1, $v0     # $s1 = số nguyên từ num2

blt $s0,0,againrange2
blt $s1,0,againrange2
bgt $s0,14,againrange2
bgt $s1,14,againrange2#xét điều kiện out of range của player2

#Tính offset=(x*15+y)*4
mul $t0,$s0,15#x*15
add $t0,$t0,$s1#x*15+y
mul $t0,$t0,4
la $t1,arr
add $t2,$t1,$t0
lw $t3,0($t2)
beq $t3,88,againsame2
beq $t3,79,againsame2#xét nếu vị trí đó đã bị trùng
li $t3,79
sw $t3,0($t2)
addi $t8,$t8,1#update count

#in ket qua ma tran sau moi lan nhap
li $t0,0#đặt x=0
li $t1,0#đặt y=0
innerloopforO:
#Tính offset=(x*15+y)*4
mul $t2,$t0,15#x*15
add $t2,$t2,$t1#x*15+y
mul $t2,$t2,4
la $t3,arr
add $t4,$t3,$t2
lw $t5,0($t4)
beq $t5,88,printXforO
beq $t5,79,printOforO

li $v0, 4 
la $a0, line 
syscall

li $a0,32
li $v0,11
syscall#in khoang trang
addi $t1,$t1,1#cap nhat y
beq $t1,15,outerloopforO#neu vuot qua số cột nhảy qua loop ngoài
j innerloopforO

outerloopforO:

li $v0, 4 
la $a0, line 
syscall

li $v0, 4 
la $a0, newline 
syscall# in xuống dòng
addi $t0,$t0,1#cap nhat x
beq $t0,15,exitforO# nếu vượt quá số hàng, thoát ra kết thúc
li $t1,0
j innerloopforO

printXforO:

li $v0, 4 
la $a0, line 
syscall

move $a0,$t5
li $v0,11
syscall#in X or O
addi $t1,$t1,1#cap nhat y
beq $t1,15,outerloopforO#neu vuot qua số cột nhảy qua loop ngoài
j innerloopforO

printOforO:

li $v0, 4 
la $a0, line 
syscall

move $a0,$t5
li $v0,11
syscall#in X or O
addi $t1,$t1,1#cap nhat y
beq $t1,15,outerloopforO#neu vuot qua số cột nhảy qua loop ngoài
j innerloopforO

exitforO:#thoat ra sau khi hien het ket qua cua lan nhap do

li $t6,1#đặt biến count để duyệt tìm người thắng
move $t0,$s0#x
move $t1,$s1#y
li $t9,1
loopforvertical1forO:#duyệt thắng đường dọc
mul $t2,$t9,1#dx*i
add $t2,$t0,$t2#x+dx*i
mul $t3,$t9,0#dy*i
add $t3,$t1,$t3#y+dy*i

blt $t2,0,breakloop9
bge $t2,15,breakloop9
blt $t3,0,breakloop9
bge $t3,15,breakloop9
#Tính offset=(x*15+y)*4
mul $t2,$t2,15#x*15
add $t2,$t2,$t3#x*15+y
mul $t2,$t2,4
la $t3,arr
add $t4,$t3,$t2
lw $t5,0($t4)
bne $t5,79,breakloop9
addi $t6,$t6,1#update count
beq $t6,5,printwinner2
addi $t9,$t9,1
beq $t9,5,exitloopforvertical2forO
j loopforvertical1forO
breakloop9:
addi $t9,$t9,1
beq $t9,5,exitloopforvertical2forO
j loopforvertical1forO
exitloopforvertical2forO:


li $t9,1
loopforvertical2forO:#duyệt thắng đường dọc hướng ngược lại
mul $t2,$t9,1#dx*i
sub $t2,$t0,$t2#x-dx*i
mul $t3,$t9,0#dy*i
sub $t3,$t1,$t3#y-dy*i

blt $t2,0,breakloop10
bge $t2,15,breakloop10
blt $t3,0,breakloop10
bge $t3,15,breakloop10
#Tính offset=(x*15+y)*4
mul $t2,$t2,15#x*15
add $t2,$t2,$t3#x*15+y
mul $t2,$t2,4
la $t3,arr
add $t4,$t3,$t2
lw $t5,0($t4)
bne $t5,79,breakloop10
addi $t6,$t6,1#update count
beq $t6,5,printwinner2
addi $t9,$t9,1
beq $t9,5,exitloopforhorizontal1forO
j loopforvertical2forO
breakloop10:
addi $t9,$t9,1
beq $t9,5,exitloopforhorizontal1forO
j loopforvertical2forO
exitloopforhorizontal1forO:

li $t6,1#đặt biến count để duyệt tìm người thắng
li $t9,1
loopforhorizontal1forO:#duyệt thắng đường ngang
mul $t2,$t9,0#dx*i
add $t2,$t0,$t2#x+dx*i
mul $t3,$t9,1#dy*i
add $t3,$t1,$t3#y+dy*i

blt $t2,0,breakloop11
bge $t2,15,breakloop11
blt $t3,0,breakloop11
bge $t3,15,breakloop11
#Tính offset=(x*15+y)*4
mul $t2,$t2,15#x*15
add $t2,$t2,$t3#x*15+y
mul $t2,$t2,4
la $t3,arr
add $t4,$t3,$t2
lw $t5,0($t4)
bne $t5,79,breakloop11
addi $t6,$t6,1#update count
beq $t6,5,printwinner2
addi $t9,$t9,1
beq $t9,5,exitloopforhorizontal2forO
j loopforhorizontal1forO
breakloop11:
addi $t9,$t9,1
beq $t9,5,exitloopforhorizontal2forO
j loopforhorizontal1forO
exitloopforhorizontal2forO:

li $t9,1
loopforhorizontal2forO:#duyệt thắng đường ngang hướng ngược lại
mul $t2,$t9,0#dx*i
sub $t2,$t0,$t2#x-dx*i
mul $t3,$t9,1#dy*i
sub $t3,$t1,$t3#y-dy*i

blt $t2,0,breakloop12
bge $t2,15,breakloop12
blt $t3,0,breakloop12
bge $t3,15,breakloop12
#Tính offset=(x*15+y)*4
mul $t2,$t2,15#x*15
add $t2,$t2,$t3#x*15+y
mul $t2,$t2,4
la $t3,arr
add $t4,$t3,$t2
lw $t5,0($t4)
bne $t5,79,breakloop12
addi $t6,$t6,1#update count
beq $t6,5,printwinner2
addi $t9,$t9,1
beq $t9,5,exitloopfordiagonal1forO
j loopforhorizontal2forO
breakloop12:
addi $t9,$t9,1
beq $t9,5,exitloopfordiagonal1forO
j loopforhorizontal2forO
exitloopfordiagonal1forO:

li $t6,1#đặt biến count để duyệt tìm người thắng
li $t9,1
loopfordiagonal1forO:#duyệt thắng đường chéo \
mul $t2,$t9,1#dx*i
add $t2,$t0,$t2#x+dx*i
mul $t3,$t9,1#dy*i
add $t3,$t1,$t3#y+dy*i

blt $t2,0,breakloop13
bge $t2,15,breakloop13
blt $t3,0,breakloop13
bge $t3,15,breakloop13
#Tính offset=(x*15+y)*4
mul $t2,$t2,15#x*15
add $t2,$t2,$t3#x*15+y
mul $t2,$t2,4
la $t3,arr
add $t4,$t3,$t2
lw $t5,0($t4)
bne $t5,79,breakloop13
addi $t6,$t6,1#update count
beq $t6,5,printwinner2
addi $t9,$t9,1
beq $t9,5,exitloopfordiagonal2forO
j loopfordiagonal1forO
breakloop13:
addi $t9,$t9,1
beq $t9,5,exitloopfordiagonal2forO
j loopfordiagonal1forO
exitloopfordiagonal2forO:

li $t9,1
loopfordiagonal2forO:#duyệt thắng đường chéo \ hướng ngược lại
mul $t2,$t9,1#dx*i
sub $t2,$t0,$t2#x-dx*i
mul $t3,$t9,1#dy*i
sub $t3,$t1,$t3#y-dy*i

blt $t2,0,breakloop14
bge $t2,15,breakloop14
blt $t3,0,breakloop14
bge $t3,15,breakloop14
#Tính offset=(x*15+y)*4
mul $t2,$t2,15#x*15
add $t2,$t2,$t3#x*15+y
mul $t2,$t2,4
la $t3,arr
add $t4,$t3,$t2
lw $t5,0($t4)
bne $t5,79,breakloop14
addi $t6,$t6,1#update count
beq $t6,5,printwinner2
addi $t9,$t9,1
beq $t9,5,exitloopfordiagonal3forO
j loopfordiagonal2forO
breakloop14:
addi $t9,$t9,1
beq $t9,5,exitloopfordiagonal3forO
j loopfordiagonal2forO
exitloopfordiagonal3forO:

li $t6,1#đặt biến count để duyệt tìm người thắng
li $t9,1
loopfordiagonal3forO:#duyệt thắng đường chéo /
mul $t2,$t9,1#dx*i
add $t2,$t0,$t2#x+dx*i
mul $t3,$t9,-1#dy*i
add $t3,$t1,$t3#y+dy*i

blt $t2,0,breakloop15
bge $t2,15,breakloop15
blt $t3,0,breakloop15
bge $t3,15,breakloop15
#Tính offset=(x*15+y)*4
mul $t2,$t2,15#x*15
add $t2,$t2,$t3#x*15+y
mul $t2,$t2,4
la $t3,arr
add $t4,$t3,$t2
lw $t5,0($t4)
bne $t5,79,breakloop15
addi $t6,$t6,1#update count
beq $t6,5,printwinner2
addi $t9,$t9,1
beq $t9,5,exitloopfordiagonal4forO
j loopfordiagonal3forO
breakloop15:
addi $t9,$t9,1
beq $t9,5,exitloopfordiagonal4forO
j loopfordiagonal3forO
exitloopfordiagonal4forO:

li $t9,1
loopfordiagonal4forO:#duyệt thắng đường chéo / hướng ngược lại
mul $t2,$t9,1#dx*i
sub $t2,$t0,$t2#x-dx*i
mul $t3,$t9,-1#dy*i
sub $t3,$t1,$t3#y-dy*i

blt $t2,0,breakloop16
bge $t2,15,breakloop16
blt $t3,0,breakloop16
bge $t3,15,breakloop16
#Tính offset=(x*15+y)*4
mul $t2,$t2,15#x*15
add $t2,$t2,$t3#x*15+y
mul $t2,$t2,4
la $t3,arr
add $t4,$t3,$t2
lw $t5,0($t4)
bne $t5,79,breakloop16
addi $t6,$t6,1#update count
beq $t6,5,printwinner2
addi $t9,$t9,1
beq $t9,5,exitinput2forO
j loopfordiagonal4forO
breakloop16:
addi $t9,$t9,1
beq $t9,5,exitinput2forO
j loopfordiagonal4forO
exitinput2forO:

beq $t8,225,exitinput
j loopinput

printwinner1:
# Open (for writing) a file that does not exist
 li $v0 , 13 
 la $a0 , outfile 
 li $a1 , 1 
 li $a2 , 0 
 syscall 
 move $s6 , $v0 

li $t0,0#đặt x=0
li $t1,0#đặt y=0

 li $v0 , 15 
 move $a0 , $s6 
 la $a1 , final
 li $a2 , 26 
 syscall #ghi "Final version of the board" ra file output


li $v0, 4 
la $a0, final 
syscall#in "Final version of the board"

 li $v0 , 15 
 move $a0 , $s6 
 la $a1 ,newline
 li $a2 , 1 
 syscall #ghi xuống dòng ở file output

li $v0, 4 
la $a0, newline 
syscall
innerloopwinner1:
#Tính offset=(x*15+y)*4
mul $t2,$t0,15#x*15
add $t2,$t2,$t1#x*15+y
mul $t2,$t2,4
la $t3,arr
add $t4,$t3,$t2
lw $t5,0($t4)
beq $t5,88,printXforwinner1
beq $t5,79,printOforwinner1

li $v0 , 15 
 move $a0 , $s6 
 la $a1 ,line
 li $a2 , 1 
 syscall #ghi xuống dòng ở file output

li $v0, 4 
la $a0, line 
syscall

li $a0,32
li $v0,11
syscall#in khoang trang

 li $v0 , 15 
 move $a0 , $s6 
 la $a1 ,space
 li $a2 , 1 
 syscall #in khoảng trắng ra file output


addi $t1,$t1,1#cap nhat y
beq $t1,15,outerloopwinner1#neu vuot qua số cột nhảy qua loop ngoài
j innerloopwinner1

outerloopwinner1:

li $v0, 4 
la $a0, line 
syscall

li $v0, 4 
la $a0, newline 
syscall# in xuống dòng

 li $v0 , 15 
 move $a0 , $s6 
 la $a1 ,line
 li $a2 , 1 
 syscall

 li $v0 , 15 
 move $a0 , $s6 
 la $a1 ,newline
 li $a2 , 1 
 syscall 

addi $t0,$t0,1#cap nhat x
beq $t0,15,exitwinner1# nếu vượt quá số hàng, thoát ra kết thúc
li $t1,0
j innerloopwinner1

printXforwinner1:

li $v0, 4 
la $a0, line 
syscall

move $a0,$t5
li $v0,11
syscall#in X or O

li $v0 , 15 
 move $a0 , $s6 
 la $a1 ,line
 li $a2 , 1 
 syscall #ghi xuống dòng ở file output

 li $v0 , 15 
 move $a0 , $s6 
 la $a1 ,writex
 li $a2 , 1 
 syscall #ghi giá trị X vào file output


addi $t1,$t1,1#cap nhat y
beq $t1,15,outerloopwinner1#neu vuot qua số cột nhảy qua loop ngoài
j innerloopwinner1

printOforwinner1:

li $v0, 4 
la $a0, line 
syscall

move $a0,$t5
li $v0,11
syscall#in X or O

li $v0 , 15 
 move $a0 , $s6 
 la $a1 ,line
 li $a2 , 1 
 syscall #ghi xuống dòng ở file output

 li $v0 , 15 
 move $a0 , $s6 
 la $a1 ,writeo
 li $a2 , 1 
 syscall #ghi giá trị O vào file output
 

addi $t1,$t1,1#cap nhat y
beq $t1,15,outerloopwinner1#neu vuot qua số cột nhảy qua loop ngoài
j innerloopwinner1
exitwinner1:
li $v0, 4 
la $a0, win1
syscall#in "Player 1 wins"

 li $v0 , 15 
 move $a0 , $s6 
 la $a1 ,win1
 li $a2 , 14 
 syscall #in "Player 1 wins" ra file output
 j exit


printwinner2:
# Open (for writing) a file that does not exist
 li $v0 , 13 
 la $a0 , outfile 
 li $a1 , 1 
 li $a2 , 0 
 syscall 
 move $s6 , $v0 

li $t0,0#đặt x=0
li $t1,0#đặt y=0

 li $v0 , 15 
 move $a0 , $s6 
 la $a1 , final
 li $a2 , 26 
 syscall #ghi "Final version of the board" ra file output


li $v0, 4 
la $a0, final 
syscall#in "Final version of the board"

 li $v0 , 15 
 move $a0 , $s6 
 la $a1 ,newline
 li $a2 , 1 
 syscall #ghi xuống dòng ở file output

li $v0, 4 
la $a0, newline 
syscall
innerloopwinner2:
#Tính offset=(x*15+y)*4
mul $t2,$t0,15#x*15
add $t2,$t2,$t1#x*15+y
mul $t2,$t2,4
la $t3,arr
add $t4,$t3,$t2
lw $t5,0($t4)
beq $t5,88,printXforwinner2
beq $t5,79,printOforwinner2

 li $v0 , 15 
 move $a0 , $s6 
 la $a1 ,line
 li $a2 , 1 
 syscall #ghi xuống dòng ở file output
 
 li $v0, 4 
la $a0, line 
syscall

li $a0,32
li $v0,11
syscall#in khoang trang

 li $v0 , 15 
 move $a0 , $s6 
 la $a1 ,space
 li $a2 , 1 
 syscall #in khoảng trắng ra file output


addi $t1,$t1,1#cap nhat y
beq $t1,15,outerloopwinner2#neu vuot qua số cột nhảy qua loop ngoài
j innerloopwinner2

outerloopwinner2:

li $v0, 4 
la $a0, line 
syscall

li $v0, 4 
la $a0, newline 
syscall# in xuống dòng

 li $v0 , 15 
 move $a0 , $s6 
 la $a1 ,line
 li $a2 , 1 
 syscall

 li $v0 , 15 
 move $a0 , $s6 
 la $a1 ,newline
 li $a2 , 1 
 syscall 

addi $t0,$t0,1#cap nhat x
beq $t0,15,exitwinner2# nếu vượt quá số hàng, thoát ra kết thúc
li $t1,0
j innerloopwinner2

printXforwinner2:

li $v0, 4 
la $a0, line 
syscall

move $a0,$t5
li $v0,11
syscall#in X or O

li $v0 , 15 
 move $a0 , $s6 
 la $a1 ,line
 li $a2 , 1 
 syscall #ghi xuống dòng ở file output

 li $v0 , 15 
 move $a0 , $s6 
 la $a1 ,writex
 li $a2 , 1 
 syscall #ghi giá trị X vào file output


addi $t1,$t1,1#cap nhat y
beq $t1,15,outerloopwinner2#neu vuot qua số cột nhảy qua loop ngoài
j innerloopwinner2

printOforwinner2:

li $v0, 4 
la $a0, line 
syscall

move $a0,$t5
li $v0,11
syscall#in X or O

li $v0 , 15 
 move $a0 , $s6 
 la $a1 ,line
 li $a2 , 1 
 syscall #ghi xuống dòng ở file output

 li $v0 , 15 
 move $a0 , $s6 
 la $a1 ,writeo
 li $a2 , 1 
 syscall #ghi giá trị O vào file output
 

addi $t1,$t1,1#cap nhat y
beq $t1,15,outerloopwinner2#neu vuot qua số cột nhảy qua loop ngoài
j innerloopwinner2
exitwinner2:
li $v0, 4 
la $a0, win2
syscall#in "Player 2 wins"

 li $v0 , 15 
 move $a0 , $s6 
 la $a1 ,win2
 li $a2 , 14 
 syscall #in "Player 2 wins" ra file output
 j exit




exitinput:
# Open (for writing) a file that does not exist
 li $v0 , 13 
 la $a0 , outfile 
 li $a1 , 1 
 li $a2 , 0 
 syscall 
 move $s6 , $v0 

li $t0,0#đặt x=0
li $t1,0#đặt y=0

 li $v0 , 15 
 move $a0 , $s6 
 la $a1 , final
 li $a2 , 26 
 syscall #ghi "Final version of the board" ra file output


li $v0, 4 
la $a0, final 
syscall#in "Final version of the board"

 li $v0 , 15 
 move $a0 , $s6 
 la $a1 ,newline
 li $a2 , 1 
 syscall #ghi xuống dòng ở file output

li $v0, 4 
la $a0, newline 
syscall

innerloop:
#Tính offset=(x*15+y)*4
mul $t2,$t0,15#x*15
add $t2,$t2,$t1#x*15+y
mul $t2,$t2,4
la $t3,arr
add $t4,$t3,$t2
lw $t5,0($t4)
beq $t5,88,printX
beq $t5,79,printO

li $v0 , 15 
 move $a0 , $s6 
 la $a1 ,line
 li $a2 , 1 
 syscall #ghi xuống dòng ở file output

li $v0, 4 
la $a0, line 
syscall

li $a0,32
li $v0,11
syscall#in khoang trang

 li $v0 , 15 
 move $a0 , $s6 
 la $a1 ,space
 li $a2 , 1 
 syscall #in khoảng trắng ra file output

addi $t1,$t1,1#cap nhat y
beq $t1,15,outerloop#neu vuot qua số cột nhảy qua loop ngoài
j innerloop

outerloop:

li $v0, 4 
la $a0, line 
syscall

li $v0, 4 
la $a0, newline 
syscall# in xuống dòng

 li $v0 , 15 
 move $a0 , $s6 
 la $a1 ,line
 li $a2 , 1 
 syscall

 li $v0 , 15 
 move $a0 , $s6 
 la $a1 ,newline
 li $a2 , 1 
 syscall 


addi $t0,$t0,1#cap nhat x
beq $t0,15,exittie# nếu vượt quá số hàng, thoát ra kết thúc
li $t1,0
j innerloop

printX:

li $v0, 4 
la $a0, line 
syscall

move $a0,$t5
li $v0,11
syscall#in X or O

 li $v0 , 15 
 move $a0 , $s6 
 la $a1 ,line
 li $a2 , 1 
 syscall #ghi xuống dòng ở file output

 li $v0 , 15 
 move $a0 , $s6 
 la $a1 ,writex
 li $a2 , 1 
 syscall #ghi giá trị X vào file output

addi $t1,$t1,1#cap nhat y
beq $t1,15,outerloop#neu vuot qua số cột nhảy qua loop ngoài
j innerloop

printO:

li $v0, 4 
la $a0, line 
syscall

move $a0,$t5
li $v0,11
syscall#in X or O

li $v0 , 15 
 move $a0 , $s6 
 la $a1 ,line
 li $a2 , 1 
 syscall #ghi xuống dòng ở file output

 li $v0 , 15 
 move $a0 , $s6 
 la $a1 ,writeo
 li $a2 , 1 
 syscall #ghi giá trị O vào file output

addi $t1,$t1,1#cap nhat y
beq $t1,15,outerloop#neu vuot qua số cột nhảy qua loop ngoài
j innerloop

exittie:
li $v0, 4 
la $a0, tie
syscall#in "Tie"

 li $v0 , 15 
 move $a0 , $s6 
 la $a1 ,tie
 li $a2 , 3 
 syscall #in "Tie" ra file output
exit:
li $v0 , 16 # system call for close file
 move $a0 , $s6 
 syscall 
li $v0,10
syscall

# --------- atoi: chuyển chuỗi sang số nguyên ---------
# Input : $a0 trỏ vào chuỗi số (vd "123")
# Output: $v0 = số nguyên
# atoi: string to int, supports negative numbers
atoi:
    li $v0, 0
    li $t4, 1        # sign

    lb $t1, 0($a0)
    li $t2, 45       # '-'
    bne $t1, $t2, atoi_loop_start
    li $t4, -1
    addi $a0, $a0, 1

atoi_loop_start:
atoi_loop:
    lb $t1, 0($a0)
    beqz $t1, atoi_end
    li $t2, 10
    mul $v0, $v0, $t2
    li $t3, 48
    sub $t1, $t1, $t3
    add $v0, $v0, $t1
    addi $a0, $a0, 1
    j atoi_loop

atoi_end:
    mul $v0, $v0, $t4
    jr $ra


# ------------ validate_input: kiểm tra định dạng num1,num2 --------------
# input: $a0 = chuỗi cần kiểm tra
# output: $v0 = 0 nếu hợp lệ, 1 nếu không hợp lệ
# validate_input: ensures format is num1,num2 (optional '-' sign)
validate_input:
    li $v0, 0
    li $t0, 0          # comma count
    move $t1, $a0
    li $t5, 0          # digit before comma
    li $t6, 0          # digit after comma
    li $t8, 0          # current part: 0 = before comma, 1 = after
    li $t9, 0          # allow '-' only at beginning of part

validate_loop:
    lb $t2, 0($t1)
    beqz $t2, check_flags

    li $t3, 44         # ','
    beq $t2, $t3, handle_comma

    li $t4, 45         # '-'
    beq $t2, $t4, handle_negative

    li $t7, 48
    blt $t2, $t7, invalid
    li $t7, 57
    bgt $t2, $t7, invalid

    # digit ok
    beqz $t8, set_before_digit
    li $t6, 1
    j continue_val

set_before_digit:
    li $t5, 1

continue_val:
    li $t9, 1          # once digit appears, disallow '-'
    addi $t1, $t1, 1
    j validate_loop

handle_negative:
    beqz $t9, continue_val   # only allowed if t9 == 0 (start of part)
    j invalid

handle_comma:
    addi $t0, $t0, 1
    bgt $t0, 1, invalid
    beqz $t5, invalid
    li $t8, 1        # switch to second part
    li $t9, 0        # allow '-' at start of second part
    addi $t1, $t1, 1
    j validate_loop

check_flags:
    li $t7, 1
    bne $t0, $t7, invalid
    beqz $t5, invalid
    beqz $t6, invalid
    jr $ra

invalid:
    li $v0, 1
    jr $ra
