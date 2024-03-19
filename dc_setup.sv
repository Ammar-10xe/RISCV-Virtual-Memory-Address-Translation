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
/// Description: This class is used to generate the device id (SSID),Non leaf
/// entries for DC and their respective memory address
///////////////////////////////////////////////////////////////////////////

class device_contex;
    
        randc bit [5:0]  ddi0;                                     // lvl1
        randc bit [8:0]  ddi1;                                     // lvl2
        randc bit [8:0]  ddi2;                                     // lvl3
              bit [23:0] device_id;                                // device_id   
              bit [11:0] ddi0_offset;                                           
              bit [11:0] ddi1_offset;
              bit [11:0] ddi2_offset;
              bit [39:0] mem_addr_lvl1;
              bit [39:0] mem_addr_lvl2;
              bit [39:0] mem_addr_lvl3;
              bit [63:0] nonleaf1_entry;
              bit [63:0] nonleaf2_entry;  
    
        function void post_randomize();
    
        ddi0_offset    = ddi0 << 6;                               // offset by 64 bytes
        ddi1_offset    = ddi1 << 3;                               // offset by 8 bytes    
        ddi2_offset    = ddi2 << 3;                               // offset by 8 bytes
        device_id      = {ddi2_offset,ddi1_offset,ddi0_offset};   // device id         
        nonleaf1_entry = ((`DC_LEAF_ADDR << 10) | (`PTE_V));      // Non leaf entry (lvl2)
        nonleaf2_entry = ((`DC_NONLEAF1_ADDR << 10) | (`PTE_V));  // Non leaf entry (lvl3)
        mem_addr_lvl1  = (`DC_LEAF_ADDR + ddi0_offset);           // DC is present always at this address (Lvl1)
        mem_addr_lvl2  = (`DC_NONLEAF1_ADDR + ddi1_offset);       // Non leaf entry address (lvl2) 
        mem_addr_lvl3  = (`DC_NONLEAF2_ADDR + ddi2_offset);       // Non leaf entry address (lvl3)
    
        endfunction
    
    
    endclass

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
/// Description: This class is used to generate the device id (SSID),Non leaf
/// entries for DC and their respective memory address
///////////////////////////////////////////////////////////////////////////

    class device_contex;
    
        randc bit [5:0]  ddi0;                                          // lvl1
        randc bit [8:0]  ddi1;                                          // lvl2
        randc bit [8:0]  ddi2;                                          // lvl3  
              bit [11:0] ddi0_offset;
              bit [11:0] ddi1_offset;
              bit [11:0] ddi2_offset;
              bit [39:0] mem_addr_lvl1;
              bit [39:0] mem_addr_lvl2;
              bit [39:0] mem_addr_lvl3;
              bit [63:0] nonleaf1_entry;
              bit [63:0] nonleaf2_entry;  
    
        function void post_randomize();
    
        ddi0_offset    = ddi0 << 6;                                     // offset by 64 bytes
        ddi1_offset    = ddi1 << 3;                                     // offset by 8 bytes    
        ddi2_offset    = ddi2 << 3;                                     // offset by 8 bytes            
        nonleaf1_entry = ((((`DC_LEAF_ADDR >>12) << 10))  | (`PTE_V));  // Non leaf entry (lvl2)
        nonleaf2_entry = (((`DC_NONLEAF1_ADDR>>12) << 10) | (`PTE_V));  // Non leaf entry (lvl3)
        mem_addr_lvl1  = (`DC_LEAF_ADDR + ddi0_offset);                 // DC is present always at this address (Lvl1)
        mem_addr_lvl2  = (`DC_NONLEAF1_ADDR + ddi1_offset);             // Non leaf entry address (lvl2) 
        mem_addr_lvl3  = (`DC_NONLEAF2_ADDR + ddi2_offset);             // Non leaf entry address (lvl3)
    
        endfunction

    endclass