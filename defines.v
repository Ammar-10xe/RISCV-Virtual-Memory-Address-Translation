///////////////////////////////////////////////////////////////////////////
// Copyright 2023 DreamBig Semiconductor, Inc. All Rights Reserved.
//
// No portions of this material may be reproduced in any form without
// the written permission of DreamBig Semiconductor Inc.
// All information contained in this document is DreamBig Semiconductor Inc.
// company confidential, proprietary and trade secret.
//
/// Author: Ammar Sarwar <ammar.sarwar.EXT@dreambigsemi.com>:
/// Date Created: 6th March 2023
///
/// Description: This file contains all the defines that are used by 
/// reference model
///////////////////////////////////////////////////////////////////////////

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

// Different Modes

`define Sv39x4_MODE 64'h8000000000000000
`define Sv48x4_MODE 64'h9000000000000000
`define Sv57x4_MODE 64'hA000000000000000
`define DDTP_IOMMU_MODE_BARE 64'h1
`define DDTP_IOMMU_MODE_1LVL 64'h2
`define DDTP_IOMMU_MODE_2LVL 64'h3
`define DDTP_IOMMU_MODE_3LVL 64'h4

// For Device Context root base address

`define DC_LEAF_ADDR     40'h7000000000
`define DC_NONLEAF1_ADDR 40'h7000001000
`define DC_NONLEAF2_ADDR 40'h7000002000

// For Sv39x4 case root base address

`define SV39x4_LVL2_ADDR 40'h8000000000
`define SV39x4_LVL1_ADDR 40'h8000004000
`define SV39x4_LVL0_ADDR 40'h8000005000

// For Sv39 case root base address

`define SV39_LVL2_ADDR 40'h8000006000
`define SV39_LVL1_ADDR 40'h8000007000
`define SV39_LVL0_ADDR 40'h8000008000

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

// For Sv57 case root base address

`define SV57_LVL4_ADDR 40'h4000000000
`define SV57_LVL3_ADDR 40'h4000001000
`define SV57_LVL2_ADDR 40'h4000002000
`define SV57_LVL1_ADDR 40'h4000003000
`define SV57_LVL0_ADDR 40'h4000004000

// For Sv57x4 case root base address

`define SV57x4_LVL4_ADDR 40'h3000000000
`define SV57x4_LVL3_ADDR 40'h3000004000
`define SV57x4_LVL2_ADDR 40'h3000005000
`define SV57x4_LVL1_ADDR 40'h3000006000
`define SV57x4_LVL0_ADDR 40'h3000007000

// For APB scoreboard test defines

`define CAPABILITIES_REG_1 'h04020010
`define CAPABILITIES_REG_2 'h000001f4
`define FCTL_REG           'h00000000

// For AXI connection test defines
  
`define M_MSG_CON     'h0
`define S_MSG_CON     'h0
`define M_MSG_TRANS   'b0010
`define S_MSG_TRANS   'b0010
`define PROTOCOL      'b0
`define VERSION       'b0010
`define OAS           'b0110         //52b
`define TOK_INV_GNT   'b0
`define SUP_REG       'b1
`define SPD           'b1
`define STAGES        'b00
`define TRANS_REQ_GNT 'h80

// For AXI Translation test defines

`define QOS         'h0
`define SID         'h00000000
`define SEC_SID     'h00
`define NSE_NS      'h01
`define IDENT       'h0
`define IMP_DEF     'h0000
`define REQEX       'b0
`define MMUV        'b1
`define CONTIGIONUS 'h0
`define DRE         'b0
`define DCP         'b0
`define ASET        'b0
`define COMB_MT     'b0
`define NS          'b1
`define TBI         'b0
`define MPMANS      'b1
`define COMB_SH     'b0
`define COMB_ALLOC  'b0
`define NSE         'b0
`define MPAMNSE     'b0
`define ATTR        'hFF
`define SH          'b10
`define PMG         'b0
`define PART_ID     'b000000000

// Fault response from PWC 

`define FAULT_RESP 'h20001