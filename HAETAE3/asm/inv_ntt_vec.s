//
//  inv_ntt_vec.s
//  HAETAE2_asm
//
//  Created by 심민주 on 5/6/24.
//
.globl invntt_tomont
.globl _invntt_tomont

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

.macro mont_reduce
    mul.4s v9, v9, v4
    
    smlsl v7.2d, v9.2s, v3.2s //하위
    sshr.2d v7, v7, #32
    
    smlsl2 v27.2d, v9.4s, v3.4s //상위
    sshr.2d v27, v27, #32
    
    XTN  v9.2s, v7.2d
    XTN2 v9.4s, v27.2d
.endm

.macro mont_reduce_2
    mul.4s v0, v0, v4

    smlsl v7.2d, v0.2s, v3.2s //하위
    sshr.2d v7, v7, #32

    smlsl2 v27.2d, v0.4s, v3.4s //상위
    sshr.2d v27, v27, #32

    XTN  v0.2s, v7.2d
    XTN2 v0.4s, v27.2d
.endm

.macro len1 //8개 한 번에
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
        
        zip1.2d         v8, v17, v12     //v8 : a[j]
        zip1.2d         v9, v18, v19    //v9 : a[j+len]
    
        mov.4s      v6, v8
        add.4s      v8, v9, v6
        sub.4s      v9, v6, v9
    
    
        SMULL       v7.2d, v9.2s, v2.2s
        SMULL2      v27.2d, v9.4s, v2.4s
        XTN         v9.2s, v7.2d
        XTN2        v9.4s, v27.2d              //t = v6
    
    
        mont_reduce
    
        zip1.4s         v0, v8, v9
        zip2.4s         v1, v8, v9
    
        add         x0, x0, #-24
        ST1         {v0.4s}, [x0], #16
        ST1         {v1.4s}, [x0], #16
        
        add         x13, x13, #-1
        cbnz        x13, loop_zeta7
.endm

.macro len2 //4개 한 번에
mov         x13, #32
loop_zeta6:
    ld1R        {v2.4s}, [x1],#4         //zeta
    ld1R        {v10.4s}, [x1],#4        //zeta
    zip1.2d        v11, v2, v10
    
    ld1         {v1.4s}, [x0],#16     //a[j]
    ld1         {v0.4s}, [x0]       //a[j+len]
    zip1.2d        v8, v1, v0
    zip2.2d         v9, v1, v0

    mov.4s      v6, v8
    add.4s      v8, v9, v6
    sub.4s      v9, v6, v9

    SMULL       v7.2d, v9.2s, v11.2s
    SMULL2      v27.2d, v9.4s, v11.4s
    XTN         v9.2s, v7.2d
    XTN2        v9.4s, v27.2d              //t = v6

    
    mul.4s      v9, v9, v4
    
    smlsl       v7.2d, v9.2s, v3.2s //하위
    sshr.2d     v7, v7, #32
    
    smlsl2      v27.2d, v9.4s, v3.4s //상위
    sshr.2d     v27, v27, #32
    
    XTN         v9.2s, v7.2d
    XTN2        v9.4s, v27.2d
    

    zip1.2d        v0, v8, v9
    zip2.2d         v1, v8, v9

    add         x0, x0, #-16
    ST1         {v0.4s}, [x0], #16
    ST1         {v1.4s}, [x0], #16
    
    add         x13, x13, #-1
    cbnz        x13, loop_zeta6
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

    mov.4s      v6, v1
    add.4s      v1, v0, v6
    sub.4s      v0, v6, v0

    SMULL       v7.2d, v0.2s, v2.2s
    SMULL2      v27.2d, v0.4s, v2.4s
    XTN         v0.2s, v7.2d
    XTN2        v0.4s, v27.2d              //t = v6

    mont_reduce_2

    ST1         {v0.4s}, [x0]
    add         x0, x0, #-16
    ST1         {v1.4s}, [x0], #16
    add         x15, x15, #-1
    cbnz        x15, loop_i4

    add         x0, x0, #16
    add         x13, x13, #-1
    cbnz        x13, loop_zeta5
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

    mov.4s      v6, v1
    add.4s      v1, v0, v6
    sub.4s      v0, v6, v0

    SMULL       v7.2d, v0.2s, v2.2s
    SMULL2      v27.2d, v0.4s, v2.4s
    XTN         v0.2s, v7.2d
    XTN2        v0.4s, v27.2d              //t = v6

    mont_reduce_2

    
    ST1         {v0.4s}, [x0]
    add         x0, x0, #-32
    ST1         {v1.4s}, [x0], #16
    add         x15, x15, #-1
    cbnz        x15, loop_i8

    add         x0, x0, #32
    add         x13, x13, #-1
    cbnz        x13, loop_zeta4
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

    mov.4s      v6, v1
    add.4s      v1, v0, v6
    sub.4s      v0, v6, v0

    SMULL       v7.2d, v0.2s, v2.2s
    SMULL2      v27.2d, v0.4s, v2.4s
    XTN         v0.2s, v7.2d
    XTN2        v0.4s, v27.2d              //t = v6

    mont_reduce_2
    
    ST1         {v0.4s}, [x0]
    add         x0, x0, #-64
    ST1         {v1.4s}, [x0], #16
    add         x15, x15, #-1
    cbnz        x15, loop_i16

    add         x0, x0, #64
    add         x13, x13, #-1
    cbnz        x13, loop_zeta3

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

    mov.4s      v6, v1
    add.4s      v1, v0, v6
    sub.4s      v0, v6, v0
    
    SMULL       v7.2d, v0.2s, v2.2s
    SMULL2      v27.2d, v0.4s, v2.4s
    XTN         v0.2s, v7.2d
    XTN2        v0.4s, v27.2d              //t = v6
    
    mont_reduce_2
        
    ST1         {v0.4s}, [x0]
    add         x0, x0, #-128
    ST1         {v1.4s}, [x0], #16
    add         x15, x15, #-1
    cbnz        x15, loop_i32

    add         x0, x0, #128
    add         x13, x13, #-1
    cbnz        x13, loop_zeta2

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
        
        mov.4s      v6, v1
        add.4s      v1, v0, v6
        sub.4s      v0, v6, v0
        
        SMULL       v7.2d, v0.2s, v2.2s
        SMULL2      v27.2d, v0.4s, v2.4s
        XTN         v0.2s, v7.2d
        XTN2        v0.4s, v27.2d              //t = v6
        
        mont_reduce_2
        
        ST1         {v0.4s}, [x0]
        add         x0, x0, #-256
        ST1         {v1.4s}, [x0], #16
        add         x15, x15, #-1
        cbnz        x15, loop_i64
    
        add         x0, x0, #256
        add         x13, x13, #-1
        cbnz        x13, loop_zeta1
    
.endm

.macro len128
    mov         x15, #32             //32*4=128 n = 256
    ld1R        {v2.4s}, [x1], #4          //zeta
    loop_i128:
        ld1         {v1.4s}, [x0]      //a[j]
        add         x0, x0, #512        //4*128=512  4(32bit)
        ld1         {v0.4s}, [x0]       //a[j+len]
    
        mov.4s      v6, v1
        add.4s      v1, v0, v6
        sub.4s      v0, v6, v0
        
        SMULL       v7.2d, v0.2s, v2.2s
        SMULL2      v27.2d, v0.4s, v2.4s
        XTN         v0.2s, v7.2d
        XTN2        v0.4s, v27.2d              //t = v6
        
        mont_reduce_2
            
        ST1         {v0.4s}, [x0]
        add         x0, x0, #-512
        ST1         {v1.4s}, [x0], #16
    
        add         x15, x15, #-1
        cbnz        x15, loop_i128
.endm


invntt_tomont:
_invntt_tomont:
mk_Q //v3
mk_Q_Inv  //v4

len1
add     x0, x0, #-1024       ///

len2
add     x0, x0, #-1024      //

len4
add     x0, x0, #-1024       //

len8
add     x0, x0, #-1024       //

len16
add     x0, x0, #-1024       //

len32
add     x0, x0, #-1024       //

len64
add     x0, x0, #-1024       //192*4 + 128

len128
add     x0, x0, #-512


mov         x15, #64             //32*4=128 n = 256
ld1R        {v2.4s}, [x1]          //F
loop_i:
    ld1         {v0.4s}, [x0]      //a[j]

    SMULL       v7.2d, v0.2s, v2.2s
    SMULL2      v27.2d, v0.4s, v2.4s
    XTN         v0.2s, v7.2d
    XTN2        v0.4s, v27.2d              //t = v6
    
    mont_reduce_2
        
    ST1         {v0.4s}, [x0], #16

    add         x15, x15, #-1
    cbnz        x15, loop_i

ret
