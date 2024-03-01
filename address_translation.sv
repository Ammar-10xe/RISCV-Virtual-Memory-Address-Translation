`include "defines.sv"
`include "calculate_va.sv"
`include "calculate_pte.sv"       

module tb;   
    
    calculate_VA VA;
    calculate_PTE PTE;
    bit [9:0] pte_permissions;
    
    initial begin

        VA = new();
        PTE = new();
        
        pte_permissions =  (`PTE_V | `PTE_R | `PTE_W | `PTE_X);  //sets the permissions of PTE
        PTE.permissions = pte_permissions;

        VA.randomize();
        PTE.randomize();
        PTE.offset = VA.offset;
        PTE.calculate_pa();
        VA.calculate_address();


        $display("VA  = %h \n", VA.va);
        $display("PTE = %h \n", PTE.pte);
        $display("physical_address = %h \n", PTE.physical_address);

        `ifdef MODE_SV39
            `ifdef LEVEL2
                $display("╭────────────────╮");
                $display("│   Sv39 Level2  │");
                $display("╰────────────────╯"); 
                $display("Store PTE %h at address %h \n",PTE.pte,VA.mem_addr_level2); 

            `elsif LEVEL1
                $display("╭────────────────╮");
                $display("│   Sv39 Level1  │");
                $display("╰────────────────╯"); 
                $display("Store level1 root base pointer %h at address %h \n",VA.sv39_level1_pointer,VA.mem_addr_level2);
                $display("Store PTE %h at address %h \n",PTE.pte,VA.mem_addr_level1); 

            `else
                $display("╭────────────────╮");
                $display("│   Sv39 Level0  │");
                $display("╰────────────────╯"); 
                $display("Store level1 root base pointer %h at address %h \n",VA.sv39_level1_pointer,VA.mem_addr_level2);
                $display("Store level0 root base pointer %h at address %h \n",VA.sv39_level0_pointer,VA.mem_addr_level1);
                $display("Store PTE %h at address %h \n",PTE.pte,VA.mem_addr_level0);                
            `endif 
        `endif
        
        `ifdef MODE_SV39x4
            `ifdef LEVEL2
                $display("╭────────────────╮");
                $display("│  Sv39*4 Level2 │");
                $display("╰────────────────╯"); 
                $display("Store PTE %h at address %h \n",PTE.pte,VA.mem_addr_level2); 
            `elsif LEVEL1
                $display("╭────────────────╮");
                $display("│  Sv39*4 Level1 │");
                $display("╰────────────────╯"); 
                $display("Store level1 root base pointer %h at address %h \n",VA.sv39x4_level1_pointer,VA.mem_addr_level2);
                $display("Store PTE %h at address %h \n",PTE.pte,VA.mem_addr_level1); 
            `else
                $display("╭────────────────╮");
                $display("│  Sv39*4 Level0 │");
                $display("╰────────────────╯"); 
                $display("Store level1 root base pointer %h at address %h \n",VA.sv39x4_level1_pointer,VA.mem_addr_level2);
                $display("Store level0 root base pointer %h at address %h \n",VA.sv39x4_level0_pointer,VA.mem_addr_level1);
                $display("Store PTE %h at address %h \n",PTE.pte,VA.mem_addr_level0);                
            `endif 
        `endif

    end

    initial begin     
        $dumpvars;
        $dumpfile("dump.vcd");
    end 

endmodule
    