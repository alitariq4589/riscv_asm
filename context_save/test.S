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
    
    # Address of machine mode trap
    la t1, m_trap
    csrw mtvec, t1 # The address where the machine mode trap handler is present in memory

    # Test starts from here
    li a1, 0x00 # Initial value

    jal ra, fs_bit_off_check #Writing to floating point with fs=off
    add a1, a0, a1
    
    jal ra, fs_bit_dirty_check #Set initial value and then check the value
    add a1, a0, a1
    
    li t1, 0x02 # Final value if test passes
    beq a1, t1, end_test_pass

end_test_fail:    
    j test_fail

end_test_pass:    
    j test_pass

fs_bit_off_check:
    li a0, 0x0 # This will be the return value
    
    li t1, 0x6000
    
    csrc mstatus, t1 # Clear the FS bits in mstatus
    
    fcvt.s.wu f1, x0 # Write to floating point register (should provide illegal instruction exception)
    

fs_bit_off_check_fail:
    li a0, 0x0
    ret

fs_bit_off_check_pass:
    addi a0, a0, 0x01 # Meaning first test passed
    ret

fs_bit_dirty_check:
    li a0, 0x0 # This will be the return value
    
    li t1, 0x2000 # FS set to initial
    
    csrs mstatus, t1 # Set the FS bit to initial in mstatus
    fcvt.s.wu f1, x0
    csrr t2, mstatus # Read back the FS bit

    li t1, 0x6000 # The FS bits
    and t2, t1, t2 # Check only the FS bits

    li t3, 0x6000 # The dirty bits
    beq t2, t3, fs_bit_dirty_check_pass


fs_bit_dirty_check_fail:
    li a0, 0x0
    ret

fs_bit_dirty_check_pass:
    addi a0, a0, 0x01 # Meaning first test passed
    ret  

.align 2
m_trap:
    csrr t4,  mcause # Read the cause of exception

    li t1, 0x02 # illegal instruction exception

    beq t4, t1, mepc_to_test_pass

mepc_to_test_fail:
    la t2, fs_bit_off_check_fail
    csrw mepc, t2
    mret

mepc_to_test_pass:
    la t2, fs_bit_off_check_pass
    csrw mepc, t2
    mret
    


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