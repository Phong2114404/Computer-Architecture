#Chuong trinh: ten chuong trinh
#Data segment
	.data
#Cac dinh nghia bien
flo_f: .space 40
tenfile:	.asciiz	"FLOAT10.BIN"
fdescr:	.word	0
#Cac cau nhac nhap du lieu
str_loi:	.asciiz	"Mo file bi loi."
str_: .asciiz ", "
str_newline: .asciiz "\n"
#Code segment
	.text
	.globl	main
main:	
#Nhap (syscall)
#Xu ly
  # mo file doc
	la	$a0,tenfile
	addi	$a1,$zero,0	#flag=0:read only
	addi	$v0,$zero,13
	syscall
	bltz	$v0,baoloi
	sw	$v0,fdescr
  # ghi file
  	lw	$a0,fdescr
    # 40 byte so thuc
  	la	$a1,flo_f
  	addi	$a2,$zero,40
  	addi	$v0,$zero,14
  	syscall
  # dong file
	lw	$a0,fdescr
	addi	$v0,$zero,16
	syscall
  #nhay toi program
	j	prog
  #bao loi neu co loi doc file
baoloi:	la	$a0,str_loi
	addi	$v0,$zero,4
	syscall
	j endprog
#program:
prog:
#t3 = i; t4 = 9
#for (int i = 0; i < 9; i++)
#a1 = arr[] 
addi $t3, $zero, 0
addi $t4, $zero, 9
la $a1, flo_f
#if i = 9, j endsort
sortcond: beq $t3, $t4, endsort
	#t1 = so phan tu chua duoc sap xep
	#t1 = t4 - t3 + 1
	sub $t1, $t4, $t3
	addi $t1, $t1, 1
	jal min_day 
	#hàm min_day tra ve t0 = vi tri phan tu nho nhat trong phan mang chua duoc sap xep
	#if t0 != 0, can thay doi vi tri cac phan tu va in mang
	bne $t0, $zero, swap1
	#if t0 = 0, phan tu dau tien la phan tu nho nhat nen chi can tang i và tang dia chi a1
continue:
	#i++, tang dia chi a1
	addi $t3, $t3, 1
	addi $a1, $a1, 4
	#nhay ve sortcond
j sortcond
	#swap1: 
	#swap: phan tu dau tien trong phan mang chua duoc sap xep và phan tu co vi tri t0
	#printarr: in mang, input a2 = arr[]
	#continue nhay den continue va tiep tuc giai thuat sort
	swap1: 
		jal swap
		la $a2, flo_f
		jal printarr
		j continue
endsort:

#Xuat ket qua (syscall)
xuat_kq:	

#ket thuc chuong trinh (syscall)
endprog:
	addiu	$v0,$zero,10
	syscall

#input: a1=arr[]
min_day: 
 # a1=addr(a[]), f0=a[0]/min, f1=a[i], s0=i(=1) t0=index of min, t1 = so phan tu cua mang chua duoc sap xep
 	la $a2, 0($a1)
 	lwc1 $f0,0($a2) 
 # for4-init 
 #t0=0
 	addi $t0, $zero, 0
 	addi $s0, $zero, 1 
 	addi $a2,$a2,4 
 # cond4 
	cond4: beq $s0, $t1, endfor4 
 # bodyf4 
 	lwc1 $f1, 0($a2) 
 # if4 (a[i]<min) 
 	c.lt.s $f1,$f0 #kiem tra (a[i]<min)
 	bc1f endif4 #sai, không cap nhat
 # then4 min=a[i] 
 	mov.s $f0,$f1 
 	move $t0, $s0
 # endif4 
endif4: 
 # loop4 
 	addi $s0,$s0,1 
 	addi $a2,$a2,4 
 	j cond4 
 # endfor4 
endfor4: # return index in t0
 jr $ra 

#function swap: a1=arr[], t0=index of n, a2=arr[t0]
swap:
	la $a2, 0($a1) #a2 = arr[0]
	sll $t0, $t0, 2 #t0 = t0 * 4
	add $a2, $a2, $t0 #a2 = arr[t0]

	lwc1 $f1, 0($a2) #f1 = giá tri tai arr[t0]
	lwc1 $f2, 0($a1) #f2 = giá tri tai arr[0]

	swc1 $f1, 0($a1) #giá tri tai arr[0] = f1
	swc1 $f2, 0($a2) #giá tri tai arr[t0] = f2
jr $ra
#function: printarr
#a2=arr[], t0=i, t1=10
printarr:
	#f12  = arr[0]
	#in gia tri arr[0]
	lwc1 $f12, 0($a2)
	addi $v0, $zero, 2
	syscall
	addi $a2, $a2, 4
	
	#in mang tu i = 1 toi i = 9
	addi $t0, $zero, 1
	addi $t1, $zero, 10
	printcond: beq $t0, $t1, endprint
	#in khoang trang
	la $a0, str_
	addi $v0, $zero, 4
	syscall
	#f12  = arr[i]
	lwc1 $f12, 0($a2)
	addi $v0, $zero, 2
	syscall
	#i++
	addi $t0, $t0, 1
	addi $a2, $a2, 4
	j printcond
endprint:
#print new line
	la $a0, str_newline
	addi $v0, $zero, 4
	syscall
jr $ra
