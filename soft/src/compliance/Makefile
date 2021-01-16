default: all

src_dir = $(BASEDIR)/soft/src/compliance
bld_dir = $(BASEDIR)/build/compliance/elf

include $(src_dir)/rv32i/Makefrag
include $(src_dir)/rv32im/Makefrag
include $(src_dir)/rv32imc/Makefrag
include $(src_dir)/rv32Zicsr/Makefrag
include $(src_dir)/rv32Zifencei/Makefrag

RISCV_GCC ?= $(RISCV)/riscv64-unknown-elf-gcc
RISCV_GCC_OPTS ?= -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles
RISCV_INCL ?= -I $(src_dir)/../env -I $(src_dir)/../common -I $(src_dir)/macros/scalar
RISCV_LINK_OPTS ?= -T $(src_dir)/../env/link.ld
RISCV_OBJDUMP ?= $(RISCV)/riscv64-unknown-elf-objdump -Mnumeric,no-aliases --disassemble-all --disassemble-zeroes
RISCV_OBJCOPY ?= $(RISCV)/riscv64-unknown-elf-objcopy -O binary
RISCV_NM ?= $(RISCV)/riscv64-unknown-elf-nm -A

vpath %.S $(src_dir)

define compile_template

$$($(1)_tests): $(1)-%: $(1)/src/%.S
	$$(RISCV_GCC) $$(RISCV_GCC_OPTS) $(4) $$(RISCV_INCL) $$(RISCV_LINK_OPTS) $$< -o $(3)/$$@.elf
	$$(RISCV_NM) $(3)/$$@.elf | grep -sw 'tohost' | sed -e 's/.*:\(.*\) D.*/\1/' > $(3)/$$@.host
	$$(RISCV_OBJDUMP) $(3)/$$@.elf > $(3)/$$@.dump
	$$(RISCV_OBJCOPY) $(3)/$$@.elf $(3)/$$@.bin
tests += $$($(1)_tests)

endef

$(eval $(call compile_template,rv32i,$(src_dir),$(bld_dir),-march=rv32i -mabi=ilp32))
$(eval $(call compile_template,rv32im,$(src_dir),$(bld_dir),-march=rv32im -mabi=ilp32))
$(eval $(call compile_template,rv32imc,$(src_dir),$(bld_dir),-march=rv32imc -mabi=ilp32))
$(eval $(call compile_template,rv32Zicsr,$(src_dir),$(bld_dir),-march=rv32i -mabi=ilp32))
$(eval $(call compile_template,rv32Zifencei,$(src_dir),$(bld_dir),-march=rv32i -mabi=ilp32))

all: $(tests)

clean:
	rm -rf $(tests)
