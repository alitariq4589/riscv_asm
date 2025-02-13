#define RVTEST_DATA_BEGIN                                               \
        .pushsection .tohost,"aw",@progbits;                            \
        .align 6; .global tohost; tohost: .dword 0; .size tohost, 8;    \
        .align 6; .global fromhost; fromhost: .dword 0; .size fromhost, 8;\
        .popsection;                                                    \
        .align 4; .global begin_signature; begin_signature:
#define RVTEST_CODE_BEGIN                                               \
        .section .text.init;                                            \
        .align  6;                                                      \
        .global _start;                         \
_start:                                 \
        j main;                             \
trap_vector:                                                            \
    csrr t5, mcause ;                       \
    nop;                                \
    nop;                                \
    nop;                                \
    nop;                                \
    nop;                                \
    j write_tohost
RVTEST_CODE_BEGIN
main: 
    la t1, m_trap
    la t2, s_trap
    csrw mtvec, t1 # The address where the machine mode trap handler is present in memory
    csrw stvec, t2 # The address where the supervisor mode trap handler is present in memory

    li t3, 0b100 # Exception code for illegal instruction exception

    csrw medeleg, t3 # Delegating illegal instruction exception to S mode

    jal ra, change_to_usermode

    csrs mstatus, x0

end_test:    
    j test_pass

change_to_usermode:
    # Change to user mode
    li t1, 0x1800
    csrc mstatus, t1 #Set MPP to 0
    csrw mepc, ra
    mret


.align 2
m_trap:
    csrr t4,  mcause # Read the cause of exception

s_trap:
    csrr t3,  scause # Read the cause of exception
    


test_fail:
	j test_fail
    
test_pass:
    j write_tohost
.align 2    
write_tohost:
    li gp, 1
    sw gp, tohost, t5
    j write_tohost
    
.data
base:
.word 0xcafebeef
RVTEST_DATA_BEGIN