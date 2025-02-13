# riscv_asm

Contains the most commonly used RISC-V privilege assembly programs.

The assembly programs are tested on spike simulator and are kept here for safe keeping

You need to have:

1. RISC-V GNU 32-bit GNU cross-compiler toolchain
2. RISC-V spike simulator

Use following command to compile the assembly program.

```
riscv32-unknown-elf-gcc -march=rv32g -mabi=ilp32 -nostdlib -T link.ld <assembly_file.S> -o <output_file.elf>
```

Use the following command to execute the compiled binary with log file .

```
spike --isa=rv32g -l --log-commits  <output_file.elf> 1>spike.out 2>spike.log
```