# Chuong trinh: Chia 2 so nguyen
#----------------------------------- 
# Data segment 
 .data 
# Cac dinh nghia bien 
so_bi_chia: .space 4 
so_chia: .space 4 
tenfile: .asciiz "INT2.BIN" 
fdescr: .word 0 
# Cac cau nhac nhap/xuat du lieu 
str_dl1: .asciiz "So bi chia la: " 
str_dl2: .asciiz "\nSo chia la: " 
str_loi: .asciiz "Mo file bi loi." 
str_thuong: .asciiz "\nThuong la: "
str_remainder: .asciiz "\nSo du la: "
#----------------------------------- 
# Code segment 
 .text 
 .globl main
#----------------------------------- 
# Chuong trinh chinh 
#----------------------------------- 
main: 
# Nhap (syscall) 
# Xu ly 
 # mo file doc 
	la $a0,tenfile 
	addi $a1,$zero,0 #a1=0 (read only)
	addi $v0,$zero,13 
	syscall 
	bltz $v0,baoloi 
	sw $v0,fdescr 
 # doc file 
 # so_bi_chia (4 byte dau)
 	lw $a0,fdescr 
 	la $a1,so_bi_chia 
 	addi $a2,$zero,4 
 	addi $v0,$zero,14 
	syscall 
 # so_chia (4 byte sau)
 	la $a1,so_chia 
 	addi $a2,$zero,4 
	addi $v0,$zero,14 
	syscall 
 # dong file 
	lw $a0,fdescr 
	addi $v0,$zero,16 
	syscall 
	
# Thuc hien phep chia
	lw $a0, so_bi_chia
	lw $a1, so_chia
		
	jal Tien_hanh
	
	addi $s2, $v0, 0
	addi $s1, $v1, 0
	
	j xuat_ket_qua
 	
baoloi: 
	la $a0,str_loi 
	addi $v0,$zero,4 
	syscall 
	addiu $v0,$zero,10 	# Neu loi, ket thuc chuong trinh (syscall) 
	syscall
	 
Tien_hanh:
	addi $sp, $sp, -4
	sw $ra, ($sp)

# $s0, $v1 chua so du (64 bits)
	addi $s0, $0, 0 
	addi $v1, $a0, 0 # 32 bits thap cua so du chua so bi chia
	
# $v0 chua thuong (32 bits)
	addi $v0, $0, 0 
	
# $s3 chua so chia (64 bits)
	addi $s4, $a1, 0 # 32 bits cao chua so chia 
	addi $s5, $0, 0 
	 
	addi $t0, $0, 33 # count = 0 thi dung lai sau 33 lan lap		
	
# Truoc khi vao chia, kiem tra 2 so co < 0, neu < 0 -> chuyen sang duong	

	addi $a0, $v1, 0	# Truyen so_bi_chia cho $a0	
	jal check_neg
	addi $t9, $v0, 0	# Tra ve 1 neu so_bi_chia < 0
	addi $v1, $a0, 0	# Tra ve gia tri tuyet doi cua so_bi_chia

	add $a0, $s4, 0		# Truyen so_chia cho $a0	
	jal check_neg
	addi $t8, $v0, 0	# Tra ve 1 neu so_chia < 0
	addi $s4, $a0, 0	# Tra ve gia tri tuyet doi cua so_chia
	
loop:
	addi $t0, $t0, -1

	addi $t3, $v1, 0	# $t3 = $v1
			
	# Tien hanh bu 2 cho so chia
	not $t5, $s5		# bu 1 cho 32 bit thap so chia, luu gia tri bu vao $t5
	# if($t5 va $t5 + 1 cung dau) carry = 0;
	# else carry = 1;
	slt $t2, $t5, $0 	# if($t5 < 0) $t2 = 1; else $t2 = 0;
	
	addiu $t5, $t5, 1	# bu 2 cho 32 bit thap so chia
	
	slt $t6, $t5, $0 	# if($t5 + 1 < 0) $t6 = 1; else $t6 = 0;
	
	not $t4, $s4		# bu 1 cho 32 bit cao so chia, luu gia tri bu vao $t4	
	
	#if($t6 == 0 && $t2 == 1 ) carry = 1; (if $t5 < 0 && $t5 + 1 >= 0) carry = 1 
	#else carry = 0;
	slt $t2, $t6, $t2	#  if($t6 < $t2) carry = 1;
	beq $t2, $0, Carry0
	
	addiu $t4, $t4, 1	# Cong carry vao 32 bit cao cua so chia
	
Carry0:
	# Truoc khi thuc hien so du - so chia, can kiem tra 32 bit thap cua so du va so chia co < 0 
	
	slt $t7, $t5, $0	# if($t5 < 0) $t7 = 1; else $t7 = 0; (32 bit thap so chia < 0)
	
	slt $t2, $v1, $0	# if($v1 < 0) $t2 = 1; else $t2 = 0; (32 bit thap so du < 0)
	
	or $t2, $t2, $t7	# Neu 1 trong 2 so < 0 thi kha nang cao se sinh ra carry = 1
	
	addu $v1, $t3, $t5 	# 32 bit thap cua so du + bu cua 32 bit thap so chia
	
	slt $t6, $v1, $0 	# if($t3 + $t5 < 0) $t6 = 1; else $t6 = 0;

	#if($t6 == 0 && $t2 == 1 ) carry = 1; (if $t5 < 0 && $t5 + 1 >= 0) carry = 1 
	#else carry = 0;
	
	addi $t3, $0, 0		#  $t3 = carry = 0
	slt $t3, $t6, $t2	#  if($t6 < $t2) carry = 1; 
	
	addu $s0, $s0, $t4 	# 32 bit cao cua so du - 32 bit cao so chia
	addu $s0, $s0, $t3 	# 32 bit cao so du + carry
	
	#if($s0 < 0) $s0 += $s4; $v1 += $s5; $v0 << 1;
	#else $v0 << 1; $v0 |= 1;
	slt $t4, $s0, $0
	bne $t4, $0, B4
B3:	
	sll $v0, $v0, 1   # Shift left thuong
	ori $v0, $v0, 1
	j B5
	
B4:	
	# Truoc khi thuc hien so du + so chia, can kiem tra 32 bit thap cua so du va so chia co < 0 
	slt $t7, $s5, $0	# if($s5 < 0) $t7 = 1; else $t7 = 0; (32 bit thap so chia < 0)
	
	slt $t2, $v1, $0	# if($v1 < 0) $t2 = 1; else $t2 = 0;
	
	or $t2, $t2, $t7	# Neu 1 trong 2 so < 0, co kha nang carry = 1
	
	addu $v1, $v1, $s5 	# 32 bit thap so du + 32 bit thap so chia
	
	slt $t6, $v1, $0 	# if($v1 + $s5 < 0) $t6 = 1; else $t6 = 0;
	
	#if($t6 == 0 && $t2 == 1 ) carry = 1; (if $t5 < 0 && $t5 + 1 >= 0) carry = 1 
	#else carry = 0;
	
	addi $t3, $0, 0		#  $t3 = carry = 0
	slt $t3, $t6, $t2	#  if($t6 < $t2) carry = 1; 
	
	addu $s0, $s0, $s4 	# 32 bit cao so du + 32 bit cao so chia
	addu $s0, $s0, $t3 	# 32 bit cao so du + carry

	sll $v0, $v0, 1   # Shift left thuong
	
B5:	srl $s5, $s5, 1 # Shift right 32 bit thap cua so chia
	and $t1, $s4, 1 # Kiem tra bit cuoi cua 32 bit cao cua so chia
	srl $s4, $s4, 1 # Shift right 32 bit cao cua so chia
		
	#if($t1 == 1) $s5 = $s5 | 2^31
	beq $t1, $0, dk_end_loop
	ori $s5, $s5, 0x80000000 
	
dk_end_loop:
	beq $t0, $0, end_Tien_hanh		
	j loop
	
end_Tien_hanh:
	lw $ra, ($sp)
	jr $ra
	
# Xuat ket qua (syscall) 
xuat_ket_qua:
	lw $a0, so_bi_chia	# Truyen so_bi_chia vao tham so $a0
	lw $a1, so_chia		# Truyen so_chia vao tham so $a1
	addi $a2, $s2, 0		# Truyen thuong vao tham so $a2
	addi $a3, $s1, 0		# Truyen so du vao tham so $a2
	jal check_thuong_so_du
	
	addi $s2, $v0, 0
	addi $s1, $v1, 0	
		
	# in so bi chia 
	la $a0,str_dl1 
	addi $v0,$zero,4 
	syscall 
	lw $a0,so_bi_chia 
	addi $v0,$zero,1 
	syscall 
 
 	# in so chia 
	la $a0,str_dl2 
	addi $v0,$zero,4 
	syscall 
	lw $a0,so_chia 
	addi $v0,$zero,1 
	syscall 
	
	#in thuong
	la $a0, str_thuong
	addi $v0, $0, 4
	syscall

	addi $a0, $s2, 0
	addi $v0, $0, 1
	syscall
	
	#in so du
	la $a0, str_remainder
	addi $v0, $0, 4
	syscall

	addi $a0, $s1, 0
	addi $v0, $0, 1
	syscall
	
	addi $v0, $0, 10
	syscall
	
check_thuong_so_du:
	addi $sp, $sp, -4
	sw $ra, ($sp)

	addi $v0, $a2, 0	# Tra ve thuong (da doi)
	addi $v1, $a3, 0	# Tra ve so_du (da doi)
		
	slt $t2, $a0, $0	# Neu so_bi_chia < 0 thi so_du < 0
	beq $t2, $0, Xet_dau_2_so
	
	#Bu 2 cho so_du
	not $v1, $v1
	addi $v1, $v1, 1
	
	slt $t3, $a1, $0	
	
Xet_dau_2_so:
	# if so_bi_chia va so_chia khac dau -> thuong < 0
	# else thuong > 0
		
	beq $t2, $t3, end_Tien_hanh	
	
	#Bu 2 cho thuong
	not $v0, $v0
	addi $v0, $v0, 1
	
	j end_Tien_hanh	

check_neg:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	slt $t2, $a0, $0	#if($a0 < 0) $a0 = ~($a0 - 1);
	beq $t2, $0, end_check

	addi $a0, $a0, -1	
	not $a0, $a0
	
end_check:
	addi $v0, $t2, 0	# Gia tri tra ve
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra
