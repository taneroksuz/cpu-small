OUTPUT_ARCH( "riscv" )
ENTRY(_start)

MEMORY
{
  tim (rwx) : ORIGIN = 0x10000000, LENGTH = 0x100000
  ram (rwx) : ORIGIN = 0x80000000, LENGTH = 0x100000
  host (rwx) : ORIGIN = 0x90000000, LENGTH = 0x100
}

SECTIONS
{

  OVERLAY :
  {
    .text.init
    {
      _text_start = .;
      _start = .;
      *(.text.init)
      . = ALIGN(8);
    }
  } >ram AT>ram

  OVERLAY :
  {
    .text
    {
      *(.text*)
      *(.rodata*)
      *(.srodata*)
      *(.data*)
      *(.sdata*)
      *(.bss*)
      *(.sbss*)
      _end = .;
    }
  } >tim AT>ram

  .tohost :
  {
    *(.tohost)
  } >host

  PROVIDE(__tim_start = ORIGIN(tim));
  PROVIDE(__tim_end = ORIGIN(tim) + LENGTH(tim));

  PROVIDE(__freertos_irq_stack_top = (__tim_end - 8K));
  PROVIDE(_stack = (__tim_end));

}

