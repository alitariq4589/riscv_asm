CC=riscv32-unknown-elf-gcc
CFLAGS=-march=rv32g -mabi=ilp32 -nostdlib -T link.ld
SPIKE_FLAGS=--isa=rv32g -l --log-commits
SPIKE_OUTPUT=spike.out
SPIKE_LOG=spike.log
DISASSEMBLY=test.disass
TARGET=test.o
SRCS=test.S link.ld

all: build disass run

#Build Executables:
build: $(TARGET)
disass: $(DISASSEMBLY)

$(TARGET): $(SRCS)
	$(CC) $(CFLAGS) -o $@ test.S

$(DISASSEMBLY): $(TARGET)
	riscv32-unknown-elf-objdump -D $(TARGET) > $(DISASSEMBLY)

run: $(TARGET) $(DISASSEMBLY)
	spike $(SPIKE_FLAGS) $(TARGET) 1>$(SPIKE_OUTPUT) 2>$(SPIKE_LOG)

clean:
	rm $(TARGET) $(SPIKE_OUTPUT) $(SPIKE_LOG) $(DISASSEMBLY)