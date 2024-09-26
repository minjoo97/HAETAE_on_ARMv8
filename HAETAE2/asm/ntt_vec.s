//
//  ntt_vec.s
//  HAETAE2_vec
//
//  Created by Minjoo on 4/30/24.
//

.globl ntt
.globl _ntt

/*
 x0 : output
 x1: zeta
 
 
 v0 : result add
 v1 : load a
 v2: zeta
 v3 :Q
 v4: Q_INV
 v5: temp1
 v6: t
 v7 : temp2
 */

.macro mk_Q_Inv
    movi.4s v4, #0x38
    movi.4s v5, #0x0f
    rev32   v4.16b, v4.16b
    shl.4s  v5, v5, #16
    orr.16b v4, v4, v5
    
    movi.4s v5, #0x04
    rev16   v5.16b, v5.16b
    orr.16b v4, v4, v5
    movi.4s v5, #0x01
    orr.16b v4, v4, v5
.endm

.macro mk_Q
    movi.4s v3, #0xfc
    rev16   v3.16b, v3.16b
    movi.4s v5, #0x01
    orr.16b v3, v3, v5

.endm


.macro len128
    mov         x15, #32             //32*4=128 n = 256
    ld1R        {v2.4s}, [x1], #4          //zeta
    loop_i128:
        ld1         {v1.4s}, [x0]      //a[j]
        add         x0, x0, #512        //4*128=512  4(32bit)
        ld1         {v0.4s}, [x0]       //a[j+len]


sqdmulh v6.4s, v0.4s, v2.4s
mul.4s  v27, v2, v4

mul.4s  v7, v0, v27

sqdmulh v16.4s, v7.4s, v3.4s
shsub.4s    v6, v6, v16

        
        sub.4s      v0, v1,v6
        ST1         {v0.4s}, [x0]
        add         x0, x0, #-512
        add.4s      v1, v1, v6
        ST1         {v1.4s}, [x0], #16
    
        add         x15, x15, #-1
        cbnz        x15, loop_i128
.endm

.macro len64
mov         x13, #2
loop_zeta1:
    mov         x15, #16             ///16*4=64
    ld1R        {v2.4s}, [x1],#4         //zeta
    
loop_i64:
        ld1         {v1.4s}, [x0]      //a[j]
        add         x0, x0, #256        //4*64=256  4(32bit)
        ld1         {v0.4s}, [x0]       //a[j+len]
        
sqdmulh v6.4s, v0.4s, v2.4s
mul.4s  v27, v2, v4

mul.4s  v7, v0, v27

sqdmulh v16.4s, v7.4s, v3.4s
shsub.4s    v6, v6, v16


        sub.4s      v0, v1,v6
        ST1         {v0.4s}, [x0]
        add         x0, x0, #-256
        add.4s      v1, v1, v6
        ST1         {v1.4s}, [x0], #16
        add         x15, x15, #-1
        cbnz        x15, loop_i64
    
        add         x0, x0, #256
        add         x13, x13, #-1
        cbnz        x13, loop_zeta1
    
.endm

.macro len32
    mov         x13, #4
loop_zeta2:
    mov         x15, #8             ///8*4=32
    ld1R        {v2.4s}, [x1],#4         //zeta
loop_i32:
    ld1         {v1.4s}, [x0]      //a[j]
    add         x0, x0, #128        //4*32=128  4(32bit)
    ld1         {v0.4s}, [x0]       //a[j+len]

sqdmulh v6.4s, v0.4s, v2.4s
mul.4s  v27, v2, v4

mul.4s  v7, v0, v27

sqdmulh v16.4s, v7.4s, v3.4s
shsub.4s    v6, v6, v16


    sub.4s      v0, v1,v6
    ST1         {v0.4s}, [x0]
    add         x0, x0, #-128
    add.4s      v1, v1, v6
    ST1         {v1.4s}, [x0], #16
    add         x15, x15, #-1
    cbnz        x15, loop_i32

    add         x0, x0, #128
    add         x13, x13, #-1
    cbnz        x13, loop_zeta2

.endm

.macro len16
    mov         x13, #8
loop_zeta3:
    mov         x15, #4            ///4*4=16
    ld1R        {v2.4s}, [x1],#4         //zeta
loop_i16:
    ld1         {v1.4s}, [x0]      //a[j]
    add         x0, x0, #64        //4*16=64  4(32bit)
    ld1         {v0.4s}, [x0]       //a[j+len]

sqdmulh v6.4s, v0.4s, v2.4s
mul.4s  v27, v2, v4

mul.4s  v7, v0, v27

sqdmulh v16.4s, v7.4s, v3.4s
shsub.4s    v6, v6, v16

    sub.4s      v0, v1,v6
    ST1         {v0.4s}, [x0]
    add         x0, x0, #-64
    add.4s      v1, v1, v6
    ST1         {v1.4s}, [x0], #16
    add         x15, x15, #-1
    cbnz        x15, loop_i16

    add         x0, x0, #64
    add         x13, x13, #-1
    cbnz        x13, loop_zeta3

.endm


.macro len8
    mov         x13, #16
loop_zeta4:
    mov         x15, #2            ///2*4=8
    ld1R        {v2.4s}, [x1],#4         //zeta
loop_i8:

    ld1         {v1.4s}, [x0]      //a[j]
    add         x0, x0, #32        //4*8=32  4(32bit)
    ld1         {v0.4s}, [x0]       //a[j+len]

    

sqdmulh v6.4s, v0.4s, v2.4s
mul.4s  v27, v2, v4

mul.4s  v7, v0, v27

sqdmulh v16.4s, v7.4s, v3.4s
shsub.4s    v6, v6, v16
    
    sub.4s      v0, v1,v6
    ST1         {v0.4s}, [x0]
    add         x0, x0, #-32
    add.4s      v1, v1, v6
    ST1         {v1.4s}, [x0], #16
    add         x15, x15, #-1
    cbnz        x15, loop_i8

    add         x0, x0, #32
    add         x13, x13, #-1
    cbnz        x13, loop_zeta4
.endm

.macro len4
    mov         x13, #32
loop_zeta5:
    mov         x15, #1           ///1*4=8
    ld1R        {v2.4s}, [x1],#4         //zeta

loop_i4:

    ld1         {v1.4s}, [x0]      //a[j]
    add         x0, x0, #16        //4*4=16  4(32bit)
    ld1         {v0.4s}, [x0]       //a[j+len]

sqdmulh v6.4s, v0.4s, v2.4s
mul.4s  v27, v2, v4

mul.4s  v7, v0, v27

sqdmulh v16.4s, v7.4s, v3.4s
shsub.4s    v6, v6, v16

    
    sub.4s      v0, v1,v6
    ST1         {v0.4s}, [x0]
    add         x0, x0, #-16
    add.4s      v1, v1, v6
    ST1         {v1.4s}, [x0], #16
    add         x15, x15, #-1
    cbnz        x15, loop_i4

    add         x0, x0, #16
    add         x13, x13, #-1
    cbnz        x13, loop_zeta5
.endm

.macro len2
mov         x13, #32
loop_zeta6:
    ld1R        {v2.4s}, [x1],#4         //zeta
    ld1R        {v10.4s}, [x1],#4        //zeta
    zip1.2d        v11, v2, v10
    
    ld1         {v1.4s}, [x0],#16     //a[j]
    ld1         {v0.4s}, [x0]       //a[j+len]
    zip1.2d        v8, v1, v0
    zip2.2d         v9, v1, v0


sqdmulh v6.4s, v9.4s, v11.4s
mul.4s  v27, v11, v4

mul.4s  v7, v9, v27

sqdmulh v16.4s, v7.4s, v3.4s
shsub.4s    v6, v6, v16


    
    sub.4s      v9, v8,v6
    add.4s      v8, v8, v6

    zip1.2d        v0, v8, v9
    zip2.2d         v1, v8, v9

    add         x0, x0, #-16
    ST1         {v0.4s}, [x0], #16
    ST1         {v1.4s}, [x0], #16
    
    add         x13, x13, #-1
    cbnz        x13, loop_zeta6
.endm


.macro len1
mov         x13, #32
loop_zeta7:
    ld1        {v2.4s}, [x1],#16         //zeta


    ld1         {v1.2s}, [x0],#8     //a[j]
    ld1         {v0.2s}, [x0],#8      //a[j+len]
    
    trn1.4s        v17, v1, v0
    trn2.4s         v18, v1, v0
    
    ld1         {v1.2s}, [x0],#8     //a[j]
    ld1         {v0.2s}, [x0]       //a[j+len]
    trn1.2s        v12, v1, v0
    trn2.2s        v19, v1, v0
    
    zip1.2d         v8, v17, v12     //a[j]
    zip1.2d         v9, v18, v19    //a[j+len]
   
sqdmulh v6.4s, v9.4s, v2.4s
mul.4s  v27, v2, v4

mul.4s  v7, v9, v27

sqdmulh v16.4s, v7.4s, v3.4s
shsub.4s    v6, v6, v16


    sub.4s      v9, v8, v6
    add.4s      v8, v8, v6

    zip1.4s         v0, v8, v9
    zip2.4s         v1, v8, v9

    add         x0, x0, #-24
    ST1         {v0.4s}, [x0], #16
    ST1         {v1.4s}, [x0], #16
    
    add         x13, x13, #-1
    cbnz        x13, loop_zeta7

.endm


ntt:
_ntt:

mk_Q //v3
mk_Q_Inv  //v4


add         x1, x1, #4


len128
add     x0, x0, #-512       //128*4

len64
add     x0, x0, #-1024       //192*4 + 128

len32
add     x0, x0, #-1024       //

len16
add     x0, x0, #-1024       //

len8
add     x0, x0, #-1024       //

len4
add     x0, x0, #-1024       //

len2
add     x0, x0, #-1024       //

len1





ret
