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
    csrw mtvec, t1 # The address where the trap handler is present in memory

    jal ra, set_rwx_permissions
    
    li t2, 0x24000000 # Bottom of the TOR address (should be 0x90000000)
    li t3, 0x240003FF # Bottom of the TOR address (should be 0x90000FFC for 4kB region)
    li t4, 0x600 # Value to set in pmp1cfg register

    
    
    csrs pmpcfg0, t4 # Setting pmp1cfg
    csrw pmpaddr1, t3 # Top of the address
    csrw pmpaddr0, t2 # Bottom of the address

    # Change to supervisor mode (gets instruction access fault exception because if single region is set you have to set whole region)
    li t1, 0x800 
    csrs mstatus, t1 #Set MPP to 1
    csrw mepc, ra
    mret
    

set_rwx_permissions:
    # Using TOR
    li t2, 0x20000000 # Bottom of the TOR address (should be 0x80000000)
    li t3, 0x2C000000 # Bottom of the TOR address (should be 0xB0000000)
    li t4, 0x0F00 # Value to set in pmpcfg2 register

    csrs pmpcfg1, t4 # Setting pmp5cfg
    csrw pmpaddr5, t3 # Top of the address
    csrw pmpaddr4, t2 # Bottom of the address
    ret

end_test:    
    j test_pass

.align 2
my_trap:
    csrr t4,  mcause # Read the cause of exception

.align 12
dummy_region_2:
  nop
  nop
  addi x0, x1, 0

.align 12
dummy_region_1:
  nop
  nop
  nop
  addi x0, x1, 0
    


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