// page table entry (PTE) fields
`define PTE_V     10'h001 // Valid
`define PTE_R     10'h002 // Read
`define PTE_W     10'h004 // Write
`define PTE_X     10'h008 // Execute
`define PTE_U     10'h010 // User
`define PTE_G     10'h020 // Global
`define PTE_A     10'h040 // Accessed
`define PTE_D     10'h080 // Dirty
`define PTE_SOFT  10'h300 // Reserved for Software

// For Sv39 case root base address

`define SV39_LVL2_ADDR 40'h8000000000
`define SV39_LVL1_ADDR 40'h8000001000
`define SV39_LVL0_ADDR 40'h8000002000


// For Sv39x4 case root base address

`define SV39x4_LVL2_ADDR 40'h8000000000
`define SV39x4_LVL1_ADDR 40'h8000004000
`define SV39x4_LVL0_ADDR 40'h8000005000


// For Sv48 case root base address

`define SV48_LVL3_ADDR 40'h6000000000
`define SV48_LVL2_ADDR 40'h6000001000
`define SV48_LVL1_ADDR 40'h6000002000
`define SV48_LVL0_ADDR 40'h6000003000

// For Sv48x4 case root base address

`define SV48x4_LVL3_ADDR 40'h5000000000
`define SV48x4_LVL2_ADDR 40'h5000004000
`define SV48x4_LVL1_ADDR 40'h5000005000
`define SV48x4_LVL0_ADDR 40'h5000006000
