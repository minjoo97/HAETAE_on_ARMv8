//
//  polyadd_vec.s
//  HAETAE2_vec
//
//  Created by 심민주 on 4/29/24.
//

.globl poly_add
.globl _poly_add

/*
 x0 : output
 x1: input a
 x2: input b
 
 v0 : result add
 v1 : load a
 v2: load b
 
 */
poly_add:
_poly_add:

mov         x5, #64

loop_i:
    LD1 {v1.4s}, [x1], #16
    LD1 {v2.4s}, [x2], #16
    ADD.4s v0, v1, v2
    ST1 {v0.4s}, [x0], #16
    
    add         x5, x5, #-1
    cbnz        x5, loop_i

ret
