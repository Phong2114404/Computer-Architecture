#Chuong trinh: tinh Pi
#Thuat toan 
#1. Khoi tao circle_points, square_points và interval bang 0. 
#2. Tao ngau nhien diem x. 
#3. Tao ngau nhiên diem y. 
#4. Tinh d = x*x + y*y. 
#5. Neu d <= 1, tang circle_points. 
#6. Tang so diem vuong. 
#7. Khoang tang dan. 
#8. Neu so gia tang < NO_OF_ITERATIONS, lap lai tu 2. 
#9. Tính pi = 4*(circle_points/square_points). 
#10. Ket thuc.
#Data segment
	.data
#Cac dinh nghia bien
float_so_1: .float 1.0
diem_trong_hinh_tron: .float 13.0
diem_trong_hinh_vuong: .float 100000.0
#Cac cau nhac nhap du lieu
khoang_trang: 	.asciiz " " 
Xuat_diem_trong_hinh_tron: .asciiz "So diem trong hinh tron: "
Xuat_pi: .asciiz "\nPi = "
#Code segment
	.text
	.globl	main
main:	
#Nhap (syscall)
#Xu ly
# get the time
li	$v0, 30		# get time in milliseconds (as a 64-bit value)
syscall

move	$t0, $a0	# save the lower 32-bits of time

# seed the random generator (just once)
li	$a0, 1		# random generator id (will be used later)
move 	$a1, $t0	# seed from time
li	$v0, 40		# seed random number generator syscall
syscall

##############################################################################
# seeding done
##############################################################################

# seeded generator (whose id is 1)
jal tinh_so_diem_trong_hinh_tron # nhay toi ham tinh_so_diem_trong_hinh_tron
#Xuat ket qua (syscall)
xuat_kq:
# print circle point
la $a0, Xuat_diem_trong_hinh_tron
li $v0, 4
syscall	
li $v0, 1
move $a0, $a2
syscall
# pi = 4 * so diem trong hinh tron / so diem trong hinh vuong = 4 * so diem trong hinh tron / 100000
# calculate and print pi
mul $a2, $a2, 4 # a2 = 4 * so diem trong hinh tron
mtc1 $a2, $f11 
cvt.s.w $f11, $f11 # f11 = 4 * so diem trong hinh tron (so thuc)

la $a0, diem_trong_hinh_vuong
lwc1 $f12, diem_trong_hinh_vuong #f12 = so diem trong hinh vuong = 100000

div.s $f12, $f11, $f12 #f12 = pi
# xuat pi
la $a0, Xuat_pi
li $v0, 4
syscall	
li $v0, 2
syscall
#ket thuc chuong trinh (syscall)
EXIT:
	addiu	$v0,$zero,10
	syscall
	
# ham so tra ve so diem trong hinh tron luu trong a2
tinh_so_diem_trong_hinh_tron:
	li	$t2, 100000	# t2 = 100001
	li	$t3, 0		# t3 = i/0
	li $a2, 0 #a2 = so diem trong hinh tron = 0
	la $a3, float_so_1 
	lwc1 $f5, 0($a3) #f5 = 1 (so thuc)
	LOOP:
	addi	$t3, $t3, 1	# i++
	beq	$t3, $t2, ket_thuc_tinh_so_diem_trong_hinh_tron # ket thuc vong lap
	# random so thuc thu 1
	li	$a0, 1
	li	$v0, 43
	syscall
	# $f0 giu gia tri so thuc thu 1 
	mov.s $f1, $f0 # chuyen f0 sang f1. f1 = x
	
	#random so thuc thu 2
	li	$a0, 1		
	li	$v0, 43		
	syscall
	# $f0 giu gia tri so thuc thu 2
	mov.s $f2, $f0 # chuyen f0 sang f2. f2 = y
	#tinh d = x * x + y *y
	mul.s $f3, $f1, $f1 #f3 = f1 * f1
	mul.s $f4, $f2, $f2 #f4 = f2 * f2
	add.s $f3, $f3, $f4 #f3 = f3 + f4 = f1 * f1 + f2 * f2 = x * x + y * y = d
	# neu d <= 1 thi so diem trong hinh tron ++  
	c.lt.s $f3, $f5 # if d   <= 1
	bc1f LOOP # sai, khong tang so diem trong hinh tron
	# dung so diem trong hinh tron ++
	addi $a2, $a2, 1 

	# Do another iteration 
	j	LOOP
ket_thuc_tinh_so_diem_trong_hinh_tron:
jr $ra
	
