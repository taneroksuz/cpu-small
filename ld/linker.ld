OUTPUT_ARCH( "riscv" )

MEMORY
{
  tim (rwx) : ORIGIN = 0x10000000, LENGTH = 0x100000
  boot (rwx) : ORIGIN = 0x80000000, LENGTH = 0x1000
  ram (rwx) : ORIGIN = 0x80001000, LENGTH = 0xFF000
  host (rwx) : ORIGIN = 0x90000000, LENGTH = 0x100
}

SECTIONS
{

  OVERLAY :
  {
    .text.init
    {
      *(.text.init)
    }
  } >boot AT>boot

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
    }
    .heap
    {
      _end = .;
    }
    .stack
    {
      _sp = ORIGIN(tim) + LENGTH(tim);
    }
  } >tim AT>ram

  .tohost :
  {
    *(.tohost)
  } >host

  PROVIDE(__tim_start = ORIGIN(tim));
  PROVIDE(__tim_end = ORIGIN(tim) + LENGTH(tim));

}

