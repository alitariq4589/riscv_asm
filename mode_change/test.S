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
    la t1, my_trap
    csrw mtvec, t1
    
    li a2, 0 # Give the argument here! (0 for supervisor mode, 1 for user mode)
    jal ra, change_to_higher_mode

    ecall

end_test:    
    j test_pass
    
change_to_higher_mode:
    
    bnez a2, change_to_user_mode

change_to_supervisor_mode:
    # Change to supervisor mode
    li t1, 0x800 
    csrs mstatus, t1 #Set MPP to 1
    csrw mepc, ra
    mret


change_to_user_mode:
    # Change to user mode
    li t1, 0x1800
    csrc mstatus, t1 #Set MPP to 0
    csrw mepc, ra
    mret

.align 2
my_trap:
    csrr t4,  mcause # Read the cause of exception
    
    # Now check the mode
    li t1, 8 #Representing cause of exception to be U mode exception
    li t2, 9 #Representing cause of exception to be S mode exception
    li t3, 11 #Representing cause of exception to be M mode exception
    
    and t4, t4, t3

    beq t4, t1, user_mode_detected
    beq t4, t2, supervisor_mode_detected
    beq t4, t3, machine_mode_detected

user_mode_detected:
    # Change to supervisor mode
    li t1, 0x800 
    csrs mstatus, t1 #Set MPP to 1
    la t2, end_test # set the returning address
    csrw mepc, t2
    mret

supervisor_mode_detected:
    # Change to machine mode
    li t1, 0x1800 
    csrs mstatus, t1 #Set MPP to 3
    la t2, end_test # set the returning address
    csrw mepc, t2
    mret 

machine_mode_detected:
    # Good to go!
    la t2, end_test # set the returning address
    csrw mepc, t2
    mret


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