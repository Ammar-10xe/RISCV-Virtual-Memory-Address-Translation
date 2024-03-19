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
/// Description: This class is used to calculate the virtual address(IA)
/// according to the mode selected and also calculte the offset for memory 
/// setup for non leaf PTEs 
///////////////////////////////////////////////////////////////////////////

class calculate_va;
  `ifdef MODE_SV39x4
    rand bit [10:0] vpn2;
         bit [40:0] sv39_va;
         bit [13:0] mem_lvl2_offset;

  `elsif MODE_48x4
    rand bit [10:0] vpn3;      
         bit [49:0] sv48_va;
         bit [13:0] mem_lvl3_offset;

  `elsif MODE_57x4
    rand bit [10:0] vpn4;      
         bit [58:0] sv57_va;
         bit [13:0] mem_lvl4_offset;
  `endif

  randc bit [8:0]  vpn4;
  randc bit [8:0]  vpn3;
  randc bit [8:0]  vpn2;
  randc bit [8:0]  vpn1;
  randc bit [8:0]  vpn0;
  randc bit [11:0] offset;
        bit [38:0] sv39_va;             
        bit [47:0] sv48_va;
        bit [56:0] sv57_va;
        bit [11:0] mem_lvl4_offset;
        bit [11:0] mem_lvl3_offset;
        bit [11:0] mem_lvl2_offset;        
        bit [11:0] mem_lvl1_offset;        
        bit [11:0] mem_lvl0_offset;        
        bit [63:0] mem_addr_level0;
        bit [63:0] mem_addr_level1;
        bit [63:0] mem_addr_level2;
        bit [63:0] mem_addr_level3;
        bit [63:0] mem_addr_level4;  
        bit [63:0] sv39_level1_pointer;  
        bit [63:0] sv39_level0_pointer;  
        bit [63:0] sv39x4_level1_pointer;
        bit [63:0] sv39x4_level0_pointer; 
        bit [63:0] sv48_level2_pointer;
        bit [63:0] sv48_level1_pointer;
        bit [63:0] sv48_level0_pointer;
        bit [63:0] sv48x4_level2_pointer;
        bit [63:0] sv48x4_level1_pointer;
        bit [63:0] sv48x4_level0_pointer;
        bit [63:0] sv57_level3_pointer;
        bit [63:0] sv57_level2_pointer;
        bit [63:0] sv57_level1_pointer;
        bit [63:0] sv57_level0_pointer;
        bit [63:0] sv57x4_level3_pointer;
        bit [63:0] sv57x4_level2_pointer;
        bit [63:0] sv57x4_level1_pointer;
        bit [63:0] sv57x4_level0_pointer;
       
    function void post_randomize();

        sv39_va = {vpn2,vpn1,vpn0,offset};
        sv48_va = {vpn3,vpn2,vpn1,vpn0,offset};
        sv57_va = {vpn4,vpn3,vpn2,vpn1,vpn0,offset};
        mem_lvl4_offset = vpn4  <<  3;
        mem_lvl3_offset = vpn3  <<  3;
        mem_lvl2_offset = vpn2  <<  3;
        mem_lvl1_offset = vpn1  <<  3;
        mem_lvl0_offset = vpn0  <<  3;

    endfunction

    function void calculate_address();
       
        `ifdef MODE_SV39

          `ifdef LEVEL2
            mem_addr_level2      = (`SV39_LVL2_ADDR + mem_lvl2_offset);
          `elsif LEVEL1
            sv39_level1_pointer  = (((`SV39_LVL1_ADDR << 10 ) >> 12) | `PTE_V);
            mem_addr_level2      = (`SV39_LVL2_ADDR + mem_lvl2_offset);
            mem_addr_level1      = (`SV39_LVL1_ADDR + mem_lvl1_offset);           
          `else
            sv39_level1_pointer  = (((`SV39_LVL1_ADDR << 10 ) >> 12) | `PTE_V);
            sv39_level0_pointer  = (((`SV39_LVL0_ADDR << 10 ) >> 12) | `PTE_V);
            mem_addr_level0      = (`SV39_LVL0_ADDR + mem_lvl0_offset);
            mem_addr_level1      = (`SV39_LVL1_ADDR + mem_lvl1_offset);           
            mem_addr_level2      = (`SV39_LVL2_ADDR + mem_lvl1_offset);            
          `endif  
        
        `elsif MODE_SV39x4
       
          `ifdef LEVEL2
            mem_addr_level2        = (`SV39x4_LVL2_ADDR + mem_lvl2_offset);
          `elsif LEVEL1
            sv39x4_level1_pointer  = (((`SV39x4_LVL1_ADDR << 10 ) >> 12) | `PTE_V);
            mem_addr_level1        = (`SV39x4_LVL1_ADDR + mem_lvl1_offset);  
            mem_addr_level2        = (`SV39x4_LVL2_ADDR + mem_lvl2_offset);
          `else
            sv39x4_level1_pointer  = (((`SV39x4_LVL1_ADDR << 10 ) >> 12) | `PTE_V);
            sv39x4_level0_pointer  = (((`SV39x4_LVL0_ADDR << 10 ) >> 12) | `PTE_V);
            mem_addr_level0        = (`SV39x4_LVL0_ADDR + mem_lvl0_offset);  
            mem_addr_level1        = (`SV39x4_LVL1_ADDR + mem_lvl1_offset);  
            mem_addr_level2        = (`SV39x4_LVL2_ADDR + mem_lvl2_offset);                     
          `endif

        `elsif MODE_SV48

          `ifdef LEVEL3
            mem_addr_level3      = (`SV48_LVL3_ADDR + mem_lvl3_offset);       
          `elsif LEVEL2
            sv48_level2_pointer  = (((`SV48_LVL2_ADDR << 10 ) >> 12) | `PTE_V);
            mem_addr_level2      = (`SV48_LVL2_ADDR + mem_lvl2_offset);
            mem_addr_level3      = (`SV48_LVL3_ADDR + mem_lvl3_offset);       
          `elsif LEVEL1
            sv48_level2_pointer  = (((`SV48_LVL2_ADDR << 10 ) >> 12) | `PTE_V);
            sv48_level1_pointer  = (((`SV48_LVL1_ADDR << 10 ) >> 12) | `PTE_V);
            mem_addr_level1      = (`SV48_LVL1_ADDR + mem_lvl1_offset);  
            mem_addr_level2      = (`SV48_LVL2_ADDR + mem_lvl2_offset);
            mem_addr_level3      = (`SV48_LVL3_ADDR + mem_lvl3_offset);       
          `else
            sv48_level2_pointer  = (((`SV48_LVL2_ADDR << 10 ) >> 12 | `PTE_V));
            sv48_level1_pointer  = (((`SV48_LVL1_ADDR << 10 ) >> 12 | `PTE_V));
            sv48_level0_pointer  = (((`SV48_LVL0_ADDR << 10 ) >> 12 | `PTE_V));
            mem_addr_level0      = (`SV48_LVL0_ADDR + mem_lvl0_offset);  
            mem_addr_level1      = (`SV48_LVL1_ADDR + mem_lvl1_offset);  
            mem_addr_level2      = (`SV48_LVL2_ADDR + mem_lvl2_offset);
            mem_addr_level3      = (`SV48_LVL3_ADDR + mem_lvl3_offset);
          `endif

        `elsif MODE_SV48x4

          `ifdef LEVEL3
            mem_addr_level3        = (`SV48x4_LVL3_ADDR + mem_lvl3_offset);       
          `elsif LEVEL2
            sv48x4_level2_pointer  = (((`SV48x4_LVL2_ADDR << 10 ) >> 12) | `PTE_V);
            mem_addr_level2        = (`SV48x4_LVL2_ADDR + mem_lvl2_offset);
            mem_addr_level3        = (`SV48x4_LVL3_ADDR + mem_lvl3_offset);       
          `elsif LEVEL1
            sv48x4_level2_pointer  = (((`SV48x4_LVL2_ADDR << 10 ) >> 12) | `PTE_V);
            sv48x4_level1_pointer  = (((`SV48x4_LVL1_ADDR << 10 ) >> 12) | `PTE_V);
            mem_addr_level1        = (`SV48x4_LVL1_ADDR + mem_lvl1_offset);  
            mem_addr_level2        = (`SV48x4_LVL2_ADDR + mem_lvl2_offset);
            mem_addr_level3        = (`SV48x4_LVL3_ADDR + mem_lvl3_offset);       
          `else
            sv48x4_level2_pointer  = (((`SV48x4_LVL2_ADDR << 10 ) >> 12) | `PTE_V);
            sv48x4_level1_pointer  = (((`SV48x4_LVL1_ADDR << 10 ) >> 12) | `PTE_V);
            sv48x4_level0_pointer  = (((`SV48x4_LVL0_ADDR << 10 ) >> 12) | `PTE_V);
            mem_addr_level0        = (`SV48x4_LVL0_ADDR + mem_lvl0_offset);  
            mem_addr_level1        = (`SV48x4_LVL1_ADDR + mem_lvl1_offset);  
            mem_addr_level2        = (`SV48x4_LVL2_ADDR + mem_lvl2_offset);
            mem_addr_level3        = (`SV48x4_LVL3_ADDR + mem_lvl3_offset);
          `endif

        `elsif MODE_SV57

          `ifdef LEVEL4
            mem_addr_level4      = (`SV57_LVL4_ADDR + mem_lvl4_offset); 
          `elsif LEVEL3
            sv57_level3_pointer  = (((`SV57_LVL3_ADDR << 10 ) >> 12) | `PTE_V);
            mem_addr_level3      = (`SV57_LVL3_ADDR + mem_lvl3_offset);
            mem_addr_level4      = (`SV57_LVL4_ADDR + mem_lvl4_offset);
          `elsif LEVEL2
            sv57_level3_pointer  = (((`SV57_LVL3_ADDR << 10 ) >> 12) | `PTE_V);
            sv57_level2_pointer  = (((`SV57_LVL2_ADDR << 10 ) >> 12) | `PTE_V);
            mem_addr_level2      = (`SV57_LVL2_ADDR + mem_lvl2_offset);
            mem_addr_level3      = (`SV57_LVL3_ADDR + mem_lvl3_offset);
            mem_addr_level4      = (`SV57_LVL4_ADDR + mem_lvl4_offset);       
          `elsif LEVEL1
            sv57_level3_pointer  = (((`SV57_LVL3_ADDR << 10 ) >> 12) | `PTE_V);
            sv57_level2_pointer  = (((`SV57_LVL2_ADDR << 10 ) >> 12) | `PTE_V);
            sv57_level1_pointer  = (((`SV57_LVL1_ADDR << 10 ) >> 12) | `PTE_V);
            mem_addr_level1      = (`SV57_LVL1_ADDR + mem_lvl1_offset);  
            mem_addr_level2      = (`SV57_LVL2_ADDR + mem_lvl2_offset);
            mem_addr_level3      = (`SV57_LVL3_ADDR + mem_lvl3_offset);
            mem_addr_level4      = (`SV57_LVL4_ADDR + mem_lvl4_offset);       
          `else
            sv57_level3_pointer  = (((`SV57_LVL3_ADDR << 10 ) >> 12) | `PTE_V);
            sv57_level2_pointer  = (((`SV57_LVL2_ADDR << 10 ) >> 12) | `PTE_V);
            sv57_level1_pointer  = (((`SV57_LVL1_ADDR << 10 ) >> 12) | `PTE_V);
            sv57_level0_pointer  = (((`SV57_LVL0_ADDR << 10 ) >> 12) | `PTE_V);
            mem_addr_level0      = (`SV57_LVL0_ADDR + mem_lvl0_offset);  
            mem_addr_level1      = (`SV57_LVL1_ADDR + mem_lvl1_offset);  
            mem_addr_level2      = (`SV57_LVL2_ADDR + mem_lvl2_offset);
            mem_addr_level3      = (`SV57_LVL3_ADDR + mem_lvl3_offset);
            mem_addr_level4      = (`SV57_LVL4_ADDR + mem_lvl4_offset);
          `endif
          
          `elsif MODE_SV57x4

            `ifdef LEVEL4
              mem_addr_level4        = (`SV57x4_LVL4_ADDR + mem_lvl4_offset); 
            `elsif LEVEL3
              sv57x4_level3_pointer  = (((`SV57x4_LVL3_ADDR << 10 ) >> 12) | `PTE_V);
              mem_addr_level3        = (`SV57x4_LVL3_ADDR + mem_lvl3_offset);
              mem_addr_level4        = (`SV57x4_LVL4_ADDR + mem_lvl4_offset);
            `elsif LEVEL2
              sv57x4_level3_pointer  = (((`SV57x4_LVL3_ADDR << 10 ) >> 12) | `PTE_V);
              sv57x4_level2_pointer  = (((`SV57x4_LVL2_ADDR << 10 ) >> 12) | `PTE_V);
              mem_addr_level2        = (`SV57x4_LVL2_ADDR + mem_lvl2_offset);
              mem_addr_level3        = (`SV57x4_LVL3_ADDR + mem_lvl3_offset);
              mem_addr_level4        = (`SV57x4_LVL4_ADDR + mem_lvl4_offset);       
            `elsif LEVEL1
              sv57x4_level3_pointer  = (((`SV57x4_LVL3_ADDR << 10 ) >> 12) | `PTE_V);
              sv57x4_level2_pointer  = (((`SV57x4_LVL2_ADDR << 10 ) >> 12) | `PTE_V);
              sv57x4_level1_pointer  = (((`SV57x4_LVL1_ADDR << 10 ) >> 12) | `PTE_V);
              mem_addr_level1        = (`SV57x4_LVL1_ADDR + mem_lvl1_offset);  
              mem_addr_level2        = (`SV57x4_LVL2_ADDR + mem_lvl2_offset);
              mem_addr_level3        = (`SV57x4_LVL3_ADDR + mem_lvl3_offset);
              mem_addr_level4        = (`SV57x4_LVL4_ADDR + mem_lvl4_offset);       
            `else
              sv57x4_level3_pointer  = (((`SV57x4_LVL3_ADDR << 10 ) >> 12) | `PTE_V);
              sv57x4_level2_pointer  = (((`SV57x4_LVL2_ADDR << 10 ) >> 12) | `PTE_V);
              sv57x4_level1_pointer  = (((`SV57x4_LVL1_ADDR << 10 ) >> 12) | `PTE_V);
              sv57x4_level0_pointer  = (((`SV57x4_LVL0_ADDR << 10 ) >> 12) | `PTE_V);
              mem_addr_level0        = (`SV57x4_LVL0_ADDR + mem_lvl0_offset);  
              mem_addr_level1        = (`SV57x4_LVL1_ADDR + mem_lvl1_offset);  
              mem_addr_level2        = (`SV57x4_LVL2_ADDR + mem_lvl2_offset);
              mem_addr_level3        = (`SV57x4_LVL3_ADDR + mem_lvl3_offset);
              mem_addr_level4        = (`SV57x4_LVL4_ADDR + mem_lvl4_offset);
            `endif    
        `endif 

    endfunction

endclass
