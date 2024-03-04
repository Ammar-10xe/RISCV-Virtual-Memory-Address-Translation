class calculate_VA;
  `ifdef MODE_SV39x4
    rand bit [10:0] vpn2;
         bit [41:0] sv39_va;
         bit [13:0] mem_lvl2_offset;
    constraint vpn2_constraint {
     vpn2 >= 512 & vpn2 <= 2048;
    }; 

  `elsif MODE_48x4
    rand bit [10:0] vpn3;      
         bit [49:0] sv48_va;
         bit [13:0] mem_lvl3_offset;
    constraint vpn3_constraint {
     vpn3 >= 512 & vpn3 <= 2048;
    };
  `elsif MODE_57x4
    rand bit [10:0] vpn4;      
         bit [57:0] sv57_va;
         bit [13:0] mem_lvl4_offset;
    constraint vpn4_constraint {
     vpn4 >= 512 & vpn4 <= 2048;
    };         
  `endif

  rand bit [8:0]  vpn4;
  rand bit [8:0]  vpn3;
  rand bit [8:0]  vpn2;
  rand bit [8:0]  vpn1;
  rand bit [8:0]  vpn0;
  rand bit [11:0] offset;
       bit [38:0] sv39_va;             
       bit [47:0] sv48_va;
       bit [55:0] sv57_va;
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
       bit [63:0] sv39_level1_pointer;   // pointer from level2 to root base address of level1
       bit [63:0] sv39_level0_pointer;   // pointer from level1 to root base address of level0
       bit [63:0] sv39x4_level1_pointer; // pointer from level2 to root base address of level1
       bit [63:0] sv39x4_level0_pointer; // pointer from level1 to root base address of level0 
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
        mem_lvl4_offset = vpn4*8;
        mem_lvl3_offset = vpn3*8;
        mem_lvl2_offset = vpn2*8;
        mem_lvl1_offset = vpn1*8;
        mem_lvl0_offset = vpn0*8;
    endfunction

    function void calculate_address();
       
        `ifdef MODE_SV39

          `ifdef LEVEL2
            mem_addr_level2      = (`SV39_LVL2_ADDR + mem_lvl2_offset);
          `elsif LEVEL1
            sv39_level1_pointer  = ((`SV39_LVL1_ADDR << 10 ) >> 12);
            mem_addr_level2      = (`SV39_LVL2_ADDR + mem_lvl2_offset);
            mem_addr_level1      = (`SV39_LVL1_ADDR + mem_lvl1_offset);           
          `else
            sv39_level1_pointer  = ((`SV39_LVL1_ADDR << 10 ) >> 12);
            sv39_level0_pointer  = ((`SV39_LVL0_ADDR << 10 ) >> 12);
            mem_addr_level0      = (`SV39_LVL0_ADDR + mem_lvl0_offset);
            mem_addr_level1      = (`SV39_LVL1_ADDR + mem_lvl1_offset);           
            mem_addr_level2      = (`SV39_LVL2_ADDR + mem_lvl1_offset);            
          `endif  
        
        `elsif MODE_SV39x4
       
          `ifdef LEVEL2
            mem_addr_level2        = (`SV39x4_LVL2_ADDR + mem_lvl2_offset);
          `elsif LEVEL1
            sv39x4_level1_pointer  = ((`SV39x4_LVL1_ADDR << 10 ) >> 12);
            mem_addr_level1        = (`SV39x4_LVL1_ADDR + mem_lvl1_offset);  
            mem_addr_level2        = (`SV39x4_LVL2_ADDR + mem_lvl2_offset);
          `else
            sv39x4_level1_pointer  = ((`SV39x4_LVL1_ADDR << 10 ) >> 12);
            sv39x4_level0_pointer  = ((`SV39x4_LVL0_ADDR << 10 ) >> 12);
            mem_addr_level0        = (`SV39x4_LVL0_ADDR + mem_lvl0_offset);  
            mem_addr_level1        = (`SV39x4_LVL1_ADDR + mem_lvl1_offset);  
            mem_addr_level2        = (`SV39x4_LVL2_ADDR + mem_lvl2_offset);                     
          `endif

        `elsif MODE_SV48

          `ifdef LEVEL3
            mem_addr_level3      = (`SV48_LVL3_ADDR + mem_lvl3_offset);       
          `elsif LEVEL2
            sv48_level2_pointer  = ((`SV48_LVL2_ADDR << 10 ) >> 12);
            mem_addr_level2      = (`SV48_LVL2_ADDR + mem_lvl2_offset);
            mem_addr_level3      = (`SV48_LVL3_ADDR + mem_lvl3_offset);       
          `elsif LEVEL1
            sv48_level2_pointer  = ((`SV48_LVL2_ADDR << 10 ) >> 12);
            sv48_level1_pointer  = ((`SV48_LVL1_ADDR << 10 ) >> 12);
            mem_addr_level1      = (`SV48_LVL1_ADDR + mem_lvl1_offset);  
            mem_addr_level2      = (`SV48_LVL2_ADDR + mem_lvl2_offset);
            mem_addr_level3      = (`SV48_LVL3_ADDR + mem_lvl3_offset);       
          `else
            sv48_level2_pointer  = ((`SV48_LVL2_ADDR << 10 ) >> 12);
            sv48_level1_pointer  = ((`SV48_LVL1_ADDR << 10 ) >> 12);
            sv48_level0_pointer  = ((`SV48_LVL0_ADDR << 10 ) >> 12);
            mem_addr_level0      = (`SV48_LVL0_ADDR + mem_lvl0_offset);  
            mem_addr_level1      = (`SV48_LVL1_ADDR + mem_lvl1_offset);  
            mem_addr_level2      = (`SV48_LVL2_ADDR + mem_lvl2_offset);
            mem_addr_level3      = (`SV48_LVL3_ADDR + mem_lvl3_offset);
          `endif

        `elsif MODE_SV48x4

          `ifdef LEVEL3
            mem_addr_level3      = (`SV48x4_LVL3_ADDR + mem_lvl3_offset);       
          `elsif LEVEL2
            sv48x4_level2_pointer  = ((`SV48x4_LVL2_ADDR << 10 ) >> 12);
            mem_addr_level2      = (`SV48x4_LVL2_ADDR + mem_lvl2_offset);
            mem_addr_level3      = (`SV48x4_LVL3_ADDR + mem_lvl3_offset);       
          `elsif LEVEL1
            sv48x4_level2_pointer  = ((`SV48x4_LVL2_ADDR << 10 ) >> 12);
            sv48x4_level1_pointer  = ((`SV48x4_LVL1_ADDR << 10 ) >> 12);
            mem_addr_level1      = (`SV48x4_LVL1_ADDR + mem_lvl1_offset);  
            mem_addr_level2      = (`SV48x4_LVL2_ADDR + mem_lvl2_offset);
            mem_addr_level3      = (`SV48x4_LVL3_ADDR + mem_lvl3_offset);       
          `else
            sv48x4_level2_pointer  = ((`SV48x4_LVL2_ADDR << 10 ) >> 12);
            sv48x4_level1_pointer  = ((`SV48x4_LVL1_ADDR << 10 ) >> 12);
            sv48x4_level0_pointer  = ((`SV48x4_LVL0_ADDR << 10 ) >> 12);
            mem_addr_level0      = (`SV48x4_LVL0_ADDR + mem_lvl0_offset);  
            mem_addr_level1      = (`SV48x4_LVL1_ADDR + mem_lvl1_offset);  
            mem_addr_level2      = (`SV48x4_LVL2_ADDR + mem_lvl2_offset);
            mem_addr_level3      = (`SV48x4_LVL3_ADDR + mem_lvl3_offset);
          `endif

        `elsif MODE_SV57

          `ifdef LEVEL4
            mem_addr_level4      = (`SV57_LVL4_ADDR + mem_lvl4_offset); 
          `elsif LEVEL3
            sv57_level3_pointer  = ((`SV57_LVL3_ADDR << 10 ) >> 12);
            mem_addr_level3      = (`SV57_LVL3_ADDR + mem_lvl3_offset);
            mem_addr_level4      = (`SV57_LVL4_ADDR + mem_lvl4_offset);
          `elsif LEVEL2
            sv57_level3_pointer  = ((`SV57_LVL3_ADDR << 10 ) >> 12);
            sv57_level2_pointer  = ((`SV57_LVL2_ADDR << 10 ) >> 12);
            mem_addr_level2      = (`SV57_LVL2_ADDR + mem_lvl2_offset);
            mem_addr_level3      = (`SV57_LVL3_ADDR + mem_lvl3_offset);
            mem_addr_level4      = (`SV57_LVL4_ADDR + mem_lvl4_offset);       
          `elsif LEVEL1
            sv57_level3_pointer  = ((`SV57_LVL3_ADDR << 10 ) >> 12);
            sv57_level2_pointer  = ((`SV57_LVL2_ADDR << 10 ) >> 12);
            sv57_level1_pointer  = ((`SV57_LVL1_ADDR << 10 ) >> 12);
            mem_addr_level1      = (`SV57_LVL1_ADDR + mem_lvl1_offset);  
            mem_addr_level2      = (`SV57_LVL2_ADDR + mem_lvl2_offset);
            mem_addr_level3      = (`SV57_LVL3_ADDR + mem_lvl3_offset);
            mem_addr_level4      = (`SV57_LVL4_ADDR + mem_lvl4_offset);       
          `else
            sv57_level3_pointer  = ((`SV57_LVL3_ADDR << 10 ) >> 12);
            sv57_level2_pointer  = ((`SV57_LVL2_ADDR << 10 ) >> 12);
            sv57_level1_pointer  = ((`SV57_LVL1_ADDR << 10 ) >> 12);
            sv57_level0_pointer  = ((`SV57_LVL0_ADDR << 10 ) >> 12);
            mem_addr_level0      = (`SV57_LVL0_ADDR + mem_lvl0_offset);  
            mem_addr_level1      = (`SV57_LVL1_ADDR + mem_lvl1_offset);  
            mem_addr_level2      = (`SV57_LVL2_ADDR + mem_lvl2_offset);
            mem_addr_level3      = (`SV57_LVL3_ADDR + mem_lvl3_offset);
            mem_addr_level4      = (`SV57_LVL4_ADDR + mem_lvl4_offset);
          `endif

        `else //default sv39

          `ifdef LEVEL2
            mem_addr_level2      = (`SV39_LVL2_ADDR + mem_lvl2_offset);
          `elsif LEVEL1
            sv39_level1_pointer  = ((`SV39_LVL1_ADDR << 10 ) >> 12);
            mem_addr_level2      = (`SV39_LVL2_ADDR + mem_lvl2_offset);
            mem_addr_level1      = (`SV39_LVL1_ADDR + mem_lvl1_offset);           
          `else
            sv39_level1_pointer  = ((`SV39_LVL1_ADDR << 10 ) >> 12);
            sv39_level0_pointer  = ((`SV39_LVL0_ADDR << 10 ) >> 12);
            mem_addr_level0      = (`SV39_LVL0_ADDR + mem_lvl0_offset);
            mem_addr_level1      = (`SV39_LVL1_ADDR + mem_lvl1_offset);           
            mem_addr_level2      = (`SV39_LVL2_ADDR + mem_lvl1_offset);            
          `endif 

        `endif 

    endfunction

endclass