`include "defines.sv"
`include "calculate_pte.sv"       

module tb;   
    
    calculate_VA VA;
    calculate_PTE PTE;
    bit [9:0] pte_permissions;
    int udpate_dump;
    initial begin

        VA = new();
        PTE = new();
        
        pte_permissions =  (`PTE_V | `PTE_R | `PTE_W | `PTE_X);  //sets the permissions of PTE
        PTE.permissions = pte_permissions;

        VA.randomize();
        PTE.randomize();
        PTE.offset = VA.offset;
        PTE.vpn1   = VA.vpn1;
        PTE.vpn0 = VA.vpn0;
        PTE.calculate_pa();
        VA.calculate_address();

        udpate_dump = $fopen("dump.txt", "a");

        $display("physical_address = %h \n", PTE.physical_address);

        `ifdef MODE_SV39
         $display("VA for sv39 scheme = %h \n", VA.sv39_va);
            `ifdef LEVEL2
                $display("╭────────────────╮");
                $display("│   Sv39 Level2  │");
                $display("╰────────────────╯"); 
                $display("Store PTE %h at address %h \n",PTE.pte_sv39,VA.mem_addr_level2); 

            `elsif LEVEL1
                $display("╭────────────────╮");
                $display("│   Sv39 Level1  │");
                $display("╰────────────────╯"); 
                $display("Store level1 root base pointer %h at address %h \n",VA.sv39_level1_pointer,VA.mem_addr_level2);
                $display("Store PTE %h at address %h \n",PTE.pte_sv39,VA.mem_addr_level1); 

            `else
                $display("╭────────────────╮");
                $display("│   Sv39 Level0  │");
                $display("╰────────────────╯"); 
                $display("Store level1 root base pointer %h at address %h \n",VA.sv39_level1_pointer,VA.mem_addr_level2);
                $display("Store level0 root base pointer %h at address %h \n",VA.sv39_level0_pointer,VA.mem_addr_level1);
                $display("Store PTE %h at address %h \n",PTE.pte_sv39,VA.mem_addr_level0);                
            `endif 
        `endif
        
        `ifdef MODE_SV39x4
        $display("VA for sv39x4 scheme  = %h \n", VA.sv39_va);
            `ifdef LEVEL2
                $display("╭────────────────╮");
                $display("│  Sv39*4 Level2 │");
                $display("╰────────────────╯"); 
                $display("Store PTE %h at address %h \n",PTE.pte_sv39,VA.mem_addr_level2); 
            `elsif LEVEL1
                $display("╭────────────────╮");
                $display("│  Sv39*4 Level1 │");
                $display("╰────────────────╯"); 
                $display("Store level1 root base pointer %h at address %h \n",VA.sv39x4_level1_pointer,VA.mem_addr_level2);
                $display("Store PTE %h at address %h \n",PTE.pte_sv39,VA.mem_addr_level1); 
            `else
                $display("╭────────────────╮");
                $display("│  Sv39*4 Level0 │");
                $display("╰────────────────╯"); 
                $display("Store level1 root base pointer %h at address %h \n",VA.sv39x4_level1_pointer,VA.mem_addr_level2);
                $display("Store level0 root base pointer %h at address %h \n",VA.sv39x4_level0_pointer,VA.mem_addr_level1);
                $display("Store PTE %h at address %h \n",PTE.pte_sv39,VA.mem_addr_level0);                
            `endif 
        `endif
        
        `ifdef MODE_SV48
        $display("VA for sv48 scheme = %h \n", VA.sv48_va);        
            `ifdef LEVEL3
                $display("╭────────────────╮");
                $display("│   Sv48 Level3  │");
                $display("╰────────────────╯"); 
                $display("Store PTE %h at address %h \n",PTE.pte_sv48,VA.mem_addr_level3);
                
            `elsif LEVEL2
                $display("╭────────────────╮");
                $display("│   Sv48 Level2  │");
                $display("╰────────────────╯"); 
                $display("Store level2 root base pointer %h at address %h \n",VA.sv48_level2_pointer,VA.mem_addr_level3);
                $display("Store PTE %h at address %h \n",PTE.pte_sv48,VA.mem_addr_level2); 

            `elsif LEVEL1
                $display("╭────────────────╮");
                $display("│   Sv48 Level1  │");
                $display("╰────────────────╯"); 
                $display("Store level2 root base pointer %h at address %h \n",VA.sv48_level2_pointer,VA.mem_addr_level3)
                $display("Store level1 root base pointer %h at address %h \n",VA.sv48_level1_pointer,VA.mem_addr_level2);
                $display("Store PTE %h at address %h \n",PTE.pte_sv48,VA.mem_addr_level1);   
            `else
                $display("╭────────────────╮");
                $display("│   Sv48 Level0  │");
                $display("╰────────────────╯"); 
                $display("Store level2 root base pointer %h at address %h \n",VA.sv48_level2_pointer,VA.mem_addr_level3);
                $display("Store level1 root base pointer %h at address %h \n",VA.sv48_level1_pointer,VA.mem_addr_level2);
                $display("Store level0 root base pointer %h at address %h \n",VA.sv48_level0_pointer,VA.mem_addr_level1);
                $display("Store PTE %h at address %h \n",PTE.pte_sv48,VA.mem_addr_level0);                
            `endif 
        `endif

        `ifdef MODE_SV48x4
        $display("VA for sv48x4 scheme = %h \n", VA.sv48_va);        
            `ifdef LEVEL3
                $display("╭────────────────╮");
                $display("│  Sv48x4 Level3 │");
                $display("╰────────────────╯"); 
                $display("Store PTE %h at address %h \n",PTE.pte_sv48,VA.mem_addr_level3);    
            `elsif LEVEL2
                $display("╭────────────────╮");
                $display("│  Sv48x4 Level2 │");
                $display("╰────────────────╯"); 
                $display("Store level2 root base pointer %h at address %h \n",VA.sv48x4_level2_pointer,VA.mem_addr_level3);
                $display("Store PTE %h at address %h \n",PTE.pte_sv48,VA.mem_addr_level2);        
            `elsif LEVEL1
                $display("╭────────────────╮");
                $display("│  Sv48x4 Level1 │");
                $display("╰────────────────╯"); 
                $display("Store level2 root base pointer %h at address %h \n",VA.sv48x4_level2_pointer,VA.mem_addr_level3);
                $display("Store level1 root base pointer %h at address %h \n",VA.sv48x4_level1_pointer,VA.mem_addr_level2);
                $display("Store PTE %h at address %h \n",PTE.pte_sv48,VA.mem_addr_level1);   
            `else
                $display("╭────────────────╮");
                $display("│  Sv48x4 Level0 │");
                $display("╰────────────────╯"); 
                $display("Store level2 root base pointer %h at address %h \n",VA.sv48x4_level2_pointer,VA.mem_addr_level3);
                $display("Store level1 root base pointer %h at address %h \n",VA.sv48x4_level1_pointer,VA.mem_addr_level2);
                $display("Store level0 root base pointer %h at address %h \n",VA.sv48x4_level0_pointer,VA.mem_addr_level1);
                $display("Store PTE %h at address %h \n",PTE.pte_sv48,VA.mem_addr_level0);                
            `endif 
        `endif



        `ifdef MODE_SV57
        $display("VA for sv57 scheme = %h \n", VA.sv57_va);
            `ifdef LEVEL4
                $display("╭────────────────╮");
                $display("│   Sv57 Level4  │");
                $display("╰────────────────╯"); 
                $display("Store PTE %h at address %h \n",PTE.pte_sv57,VA.mem_addr_level4);

            `elsif LEVEL3
                $display("╭────────────────╮");
                $display("│   Sv57 Level3  │");
                $display("╰────────────────╯"); 
                $display("Store level3 root base pointer %h at address %h \n",VA.sv57_level3_pointer,VA.mem_addr_level4);
                $display("Store PTE %h at address %h \n",PTE.pte_sv57,VA.mem_addr_level3);
                
            `elsif LEVEL2
                $display("╭────────────────╮");
                $display("│   Sv57 Level2  │");
                $display("╰────────────────╯"); 
                $display("Store level3 root base pointer %h at address %h \n",VA.sv57_level3_pointer,VA.mem_addr_level4);
                $display("Store level2 root base pointer %h at address %h \n",VA.sv57_level2_pointer,VA.mem_addr_level3);
                $display("Store PTE %h at address %h \n",PTE.pte_sv57,VA.mem_addr_level2); 

            `elsif LEVEL1
                $display("╭────────────────╮");
                $display("│   Sv57 Level1  │");
                $display("╰────────────────╯"); 
                $display("Store level3 root base pointer %h at address %h \n",VA.sv57_level3_pointer,VA.mem_addr_level4);
                $display("Store level2 root base pointer %h at address %h \n",VA.sv57_level2_pointer,VA.mem_addr_level3)
                $display("Store level1 root base pointer %h at address %h \n",VA.sv57_level1_pointer,VA.mem_addr_level2);
                $display("Store PTE %h at address %h \n",PTE.pte_sv57,VA.mem_addr_level1);   
            `else
                $display("╭────────────────╮");
                $display("│   Sv57 Level0  │");
                $display("╰────────────────╯");
                $display("Store level3 root base pointer %h at address %h \n",VA.sv57_level3_pointer,VA.mem_addr_level4); 
                $display("Store level2 root base pointer %h at address %h \n",VA.sv57_level2_pointer,VA.mem_addr_level3);
                $display("Store level1 root base pointer %h at address %h \n",VA.sv57_level1_pointer,VA.mem_addr_level2);
                $display("Store level0 root base pointer %h at address %h \n",VA.sv57_level0_pointer,VA.mem_addr_level1);
                $display("Store PTE %h at address %h \n",PTE.pte_sv57,VA.mem_addr_level0);                
            `endif 
        `endif
                
        `ifdef MODE_SV57x4
        $display("VA for sv57x4 scheme = %h \n", VA.sv57_va);
            `ifdef LEVEL4
                $display("╭────────────────╮");
                $display("│  Sv57x4 Level4 │");
                $display("╰────────────────╯"); 
                $display("Store PTE %h at address %h \n",PTE.pte_sv57,VA.mem_addr_level4);

            `elsif LEVEL3
                $display("╭────────────────╮");
                $display("│  Sv57x4 Level3 │");
                $display("╰────────────────╯"); 
                $display("Store level3 root base pointer %h at address %h \n",VA.sv57x4_level3_pointer,VA.mem_addr_level4);
                $display("Store PTE %h at address %h \n",PTE.pte_sv57,VA.mem_addr_level3);
                
            `elsif LEVEL2
                $display("╭────────────────╮");
                $display("│  Sv57x4 Level2 │");
                $display("╰────────────────╯"); 
                $display("Store level3 root base pointer %h at address %h \n",VA.sv57x4_level3_pointer,VA.mem_addr_level4);
                $display("Store level2 root base pointer %h at address %h \n",VA.sv57x4_level2_pointer,VA.mem_addr_level3);
                $display("Store PTE %h at address %h \n",PTE.pte_sv57,VA.mem_addr_level2); 

            `elsif LEVEL1
                $display("╭────────────────╮");
                $display("│  Sv57x4 Level1 │");
                $display("╰────────────────╯"); 
                $display("Store level3 root base pointer %h at address %h \n",VA.sv57x4_level3_pointer,VA.mem_addr_level4);
                $display("Store level2 root base pointer %h at address %h \n",VA.sv57x4_level2_pointer,VA.mem_addr_level3)
                $display("Store level1 root base pointer %h at address %h \n",VA.sv57x4_level1_pointer,VA.mem_addr_level2);
                $display("Store PTE %h at address %h \n",PTE.pte_sv57,VA.mem_addr_level1);   
            `else
                $display("╭────────────────╮");
                $display("│  Sv57x4 Level0 │");
                $display("╰────────────────╯");
                $display("Store level3 root base pointer %h at address %h \n",VA.sv57x4_level3_pointer,VA.mem_addr_level4); 
                $display("Store level2 root base pointer %h at address %h \n",VA.sv57x4_level2_pointer,VA.mem_addr_level3);
                $display("Store level1 root base pointer %h at address %h \n",VA.sv57x4_level1_pointer,VA.mem_addr_level2);
                $display("Store level0 root base pointer %h at address %h \n",VA.sv57x4_level0_pointer,VA.mem_addr_level1);
                $display("Store PTE %h at address %h \n",PTE.pte_sv57,VA.mem_addr_level0);                
            `endif 
        `endif         
    end

    initial begin     
        $dumpvars;
        $dumpfile("dump.vcd");
    end 

endmodule
    