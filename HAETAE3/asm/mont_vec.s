//
//  mont_vec.s
//  HAETAE2_vec
//
//  Created by Minjoo on 5/1/24.
//

.globl mont_vec
.globl _mont_vec

.macro mk_montsQ
    movi.4s v14, #0x42
    rev16   v14.16b, v4.16b
    movi.4s v5, #0x14
    orr.16b v14, v14, v5
.endm

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

mont_vec:
_mont_vec:

mk_Q //v3
mk_Q_Inv  //v4

mov         x5, #64

loop_i:

    ld1     {v1.4s}, [x1], #16
    
    SMULL   v7.2d, v1.2s, v14.2s
    SMULL2  v27.2d, v1.4s, v14.4s
    XTN  v6.2s, v7.2d
    XTN2 v6.4s, v27.2d

    mul.4s v6, v6, v4

    smlsl v7.2d, v6.2s, v3.2s
    sshr.2d v7, v7, #32

    smlsl2 v27.2d, v6.4s, v3.4s 
    sshr.2d v27, v27, #32
    
    XTN  v6.2s, v7.2d
    XTN2 v6.4s, v27.2d
    

    ST1 {v6.4s}, [x0], #16

    add         x5, x5, #-1
    cbnz        x5, loop_i




ret

