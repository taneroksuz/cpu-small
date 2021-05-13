#**************************************************************
# This .sdc file is created by Terasic Tool.
# Users are recommended to modify this file to match users logic.
#**************************************************************

#**************************************************************
# Create Clock
#**************************************************************
create_clock -period "50.0 MHz" [get_ports clk]

#**************************************************************
# Create Generated Clock
#**************************************************************
derive_pll_clocks
derive_clock_uncertainty
