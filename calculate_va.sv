class calculate_VA;

    `ifdef MODE_SV39
    rand bit [8:0]  vpn2; 
    rand bit [38:0]  va; 
         bit [13:0] mem_lvl2_offset;
  
    `elsif MODE_SV39x4
    rand bit [10:0] vpn2;
    rand bit [41:0] va;
         bit [13:0] mem_lvl2_offset;
    constraint vpn2_constraint {
       vpn2 >= 512 & vpn2 <= 2048;
      }; 
    
    `else
    rand bit [8:0]  vpn2;  //default sv39 
    rand bit [38:0]  va;
         bit [11:0] mem_lvl2_offset;        
    `endif

    rand bit [8:0]  vpn1;
    rand bit [8:0]  vpn0;
    rand bit [11:0] offset;
         bit [11:0] mem_lvl1_offset;        
         bit [11:0] mem_lvl0_offset;        
         bit [63:0] mem_addr_level0;
         bit [63:0] mem_addr_level1;
         bit [63:0] mem_addr_level2;                  
         // for level 0 and 1 pointer 
         bit [63:0] sv39_level1_pointer;   // pointer from level2 to root base address of level1
         bit [63:0] sv39_level0_pointer;   // pointer from level1 to root base address of level0
         bit [63:0] sv39x4_level1_pointer; // pointer from level2 to root base address of level1
         bit [63:0] sv39x4_level0_pointer; // pointer from level1 to root base address of level0         
    function void post_randomize();
        va = {vpn2,vpn1,vpn0,offset};
        mem_lvl2_offset = vpn2*8;
        mem_lvl1_offset = vpn1*8;
        mem_lvl0_offset = vpn0*8;
    endfunction

    function void calculate_address();
       
        `ifdef MODE_SV39

          `ifdef LEVEL2
            mem_addr_level2 = (`SV39_LVL2_ADDR + mem_lvl2_offset);
          `elsif LEVEL1
            sv39_level1_pointer  = ((`SV39_LVL1_ADDR << 10 ) >> 12);
            mem_addr_level2 = (`SV39_LVL2_ADDR + mem_lvl2_offset);
            mem_addr_level1 = (`SV39_LVL1_ADDR + mem_lvl1_offset);           
          `else
            sv39_level1_pointer  = ((`SV39_LVL1_ADDR << 10 ) >> 12);
            sv39_level0_pointer  = ((`SV39_LVL0_ADDR << 10 ) >> 12);
            mem_addr_level0 = (`SV39_LVL0_ADDR + mem_lvl0_offset);
            mem_addr_level1 = (`SV39_LVL1_ADDR + mem_lvl1_offset);           
            mem_addr_level2 = (`SV39_LVL2_ADDR + mem_lvl1_offset);            
          `endif  
        
        `elsif MODE_SV39x4
       
          `ifdef LEVEL2
            mem_addr_level2 = (`SV39x4_LVL2_ADDR + mem_lvl2_offset);
          `elsif LEVEL1
            sv39x4_level1_pointer  = ((`SV39x4_LVL1_ADDR << 10 ) >> 12);
            mem_addr_level1 = (`SV39x4_LVL1_ADDR + mem_lvl1_offset);  
            mem_addr_level2 = (`SV39x4_LVL2_ADDR + mem_lvl2_offset);
          `else
            sv39x4_level1_pointer  = ((`SV39x4_LVL1_ADDR << 10 ) >> 12);
            sv39x4_level0_pointer  = ((`SV39x4_LVL0_ADDR << 10 ) >> 12);
            mem_addr_level0 = (`SV39x4_LVL0_ADDR + mem_lvl0_offset);  
            mem_addr_level1 = (`SV39x4_LVL1_ADDR + mem_lvl1_offset);  
            mem_addr_level2 = (`SV39x4_LVL2_ADDR + mem_lvl2_offset);                     
          `endif

        `else //default sv39

          `ifdef LEVEL2
            mem_addr_level2 = (`SV39_LVL2_ADDR + mem_lvl2_offset);
          `elsif LEVEL1
            mem_addr_level2 = (`SV39_LVL2_ADDR + mem_lvl2_offset);
            mem_addr_level1 = (`SV39_LVL1_ADDR + mem_lvl1_offset);           
          `else
            mem_addr_level0 = (`SV39_LVL0_ADDR + mem_lvl0_offset);
            mem_addr_level1 = (`SV39_LVL1_ADDR + mem_lvl1_offset);           
            mem_addr_level2 = (`SV39_LVL2_ADDR + mem_lvl1_offset);            
          `endif 
            
        `endif 
            
            
    endfunction

endclass