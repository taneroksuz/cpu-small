default: all

src_dir = $(BASEDIR)/soft/src/compliance
bld_dir = $(BASEDIR)/build/compliance/elf

include $(src_dir)/rv32c/Makefrag
include $(src_dir)/rv32i/Makefrag
include $(src_dir)/rv32m/Makefrag
include $(src_dir)/rv32p/Makefrag
include $(src_dir)/rv32z/Makefrag

RISCV_GCC ?= $(RISCV)/riscv64-unknown-elf-gcc
RISCV_GCC_OPTS ?= -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles
RISCV_INCL ?= -I $(src_dir)/env
RISCV_LINK_OPTS ?= -T $(src_dir)/env/link.ld -D RVMODEL_ASSERT
RISCV_OBJDUMP ?= $(RISCV)/riscv64-unknown-elf-objdump -Mnumeric,no-aliases --disassemble --disassemble-zeroes
RISCV_OBJCOPY ?= $(RISCV)/riscv64-unknown-elf-objcopy -O binary
RISCV_NM ?= $(RISCV)/riscv64-unknown-elf-nm -A

vpath %.S $(src_dir)

define compile_template

$$($(1)_tests): $(1)-%: $(1)/%.S
	$$(RISCV_GCC) $$(RISCV_GCC_OPTS) $(4) $$(RISCV_INCL) $$(RISCV_LINK_OPTS) $$< -o $(3)/$$@.elf
	$$(RISCV_NM) $(3)/$$@.elf | grep -sw 'tohost' | sed -e 's/.*:\(.*\) D.*/\1/' > $(3)/$$@.host
	$$(RISCV_OBJDUMP) $(3)/$$@.elf > $(3)/$$@.dump
	$$(RISCV_OBJCOPY) $(3)/$$@.elf $(3)/$$@.bin
tests += $$($(1)_tests)

endef

$(eval $(call compile_template,rv32c,$(src_dir),$(bld_dir),-march=rv32ic -mabi=ilp32 -DXLEN=32))
$(eval $(call compile_template,rv32i,$(src_dir),$(bld_dir),-march=rv32ic -mabi=ilp32 -DXLEN=32))
$(eval $(call compile_template,rv32m,$(src_dir),$(bld_dir),-march=rv32imc -mabi=ilp32 -DXLEN=32))
$(eval $(call compile_template,rv32p,$(src_dir),$(bld_dir),-march=rv32ic -mabi=ilp32 -DXLEN=32 -Drvtest_mtrap_routine=True))
$(eval $(call compile_template,rv32z,$(src_dir),$(bld_dir),-march=rv32ic -mabi=ilp32 -DXLEN=32))

all: $(tests)

clean:
	rm -rf $(tests)
