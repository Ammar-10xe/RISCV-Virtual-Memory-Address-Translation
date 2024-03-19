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
/// Description: This file setup the memory according to the 
/// mode(sv39.sv48,sv57) repeat_count selected.   
///////////////////////////////////////////////////////////////////////////

`include "../defines.sv"
`include "calculate_pte.sv"       
`include "device_contex.sv"

module reference_model;   
    
    calculate_va va;
    calculate_pte pte;
    device_contex dc;
    bit [9:0]   pte_permissions;
    bit [23:0]  device_id;
    bit [159:0] dti_tbu_condis_req;
    bit [63:0]  dc_tc;
    bit [63:0]  dc_iohgatp;
    bit [63:0]  dc_ta;
    bit [63:0]  dc_fsc;
    bit [63:0]  dc_msiptp;
    bit [63:0]  dc_msi_addr_mask;
    bit [63:0]  dc_msi_addr_pattern; 
    bit [63:0]  dc_reserved;
    bit ddtp_mode_bare;
    bit ddtp_mode_off;
    bit svnapot_pte;
    bit misaligned_lvl4;
    bit misaligned_lvl3;
    bit misaligned_lvl2;
    bit misaligned_lvl1;
    bit lvl0_pointer;
    int update_mem;
    int update_va;
    int update_pa;
    int update_id;
    int update_dc;
    int update_did;
    int repeat_count;
    int fault_resp;

    initial begin

        va              = new();
        pte             = new();
        dc              = new();
        repeat_count    = `count;  
        fault_resp      = `FAULT_RESP;
        pte_permissions = 'h`pte_permissions;                                                   //sets the number of Iterations  
        // pte_permissions = (`PTE_A | `PTE_D | `PTE_U | `PTE_V | `PTE_R | `PTE_W | `PTE_X );   //sets the permissions of pte
        pte.permissions = pte_permissions;
        update_mem = $fopen("./tb/tests/mem_setup.sv","w");
        update_va  = $fopen("./tb/seqs/va.txt", "w");
        update_pa  = $fopen("./tb/reference_pa.txt", "w");
        update_dc  = $fopen("./tb/tests/dc_setup.sv", "w");
        update_did = $fopen("./tb/seqs/device_id.txt", "w");

        for (int i = 0; i < repeat_count; i++) begin
            if (!(va.randomize() && pte.randomize() && dc.randomize())) begin
            $fatal("[Address Translation]: Address Translation randomization failed");
            end 

            else begin

                pte.offset = va.offset;
                pte.vpn4   = va.vpn4;
                pte.vpn3   = va.vpn3;
                pte.vpn2   = va.vpn2;
                pte.vpn1   = va.vpn1;
                pte.vpn0   = va.vpn0;   
                device_id  = {dc.ddi2,dc.ddi1,dc.ddi0};

                pte.calculate_pa();
                va.calculate_address();  
        
                update_did  = $fopen("./tb/seqs/device_id.txt", "a");
                update_dc  = $fopen("./tb/tests/dc_setup.sv", "a");
                update_mem = $fopen("./tb/tests/mem_setup.sv","a");
                update_va  = $fopen("./tb/seqs/va.txt", "a");
                update_pa  = $fopen("./tb/reference_pa.txt", "a");
 
                `ifdef SVNAPOT_PTE
                    svnapot_pte = 1;
                `elsif DDTP_MODE_BARE
                    ddtp_mode_bare = 1; 
                `elsif DDTP_MODE_OFF 
                    ddtp_mode_off =1;
                `elsif LEVEL4
                    if ((pte.ppn3 != 'h0) || (pte.ppn2 != 'h0) ||  (pte.ppn1 != 'h0) ||   (pte.ppn0 != 'h0))
                        misaligned_lvl4 = 1;                    
                `elsif LEVEL3
                    if ( (pte.ppn2 != 'h0) || (pte.ppn1 != 'h0) ||   (pte.ppn0 != 'h0))
                        misaligned_lvl3 = 1;                    
                `elsif LEVEL2
                    if ( (pte.ppn1 != 'h0) ||   (pte.ppn0 != 'h0))
                        misaligned_lvl2 = 1;
                `elsif LEVEL1
                    if (pte.ppn0 != 'h0) 
                        misaligned_lvl1 = 1; 
                `elsif LEVEL0
                    if ((pte_permissions[3:1] && (`PTE_R | `PTE_W | `PTE_X)) == 'h0 )
                        lvl0_pointer = 1;                           
                `endif
                
                if ( i == 0) begin 
                    
                    $fdisplay(update_mem, "`include \"dc_setup.sv\"\n");
                end

                $fdisplay( update_did, "%h",device_id);
    
                `ifdef MODE_SV39
               
                if((pte_permissions & `PTE_V) == 1'b0 )         $fdisplay( update_pa, "%h", fault_resp);   // Fault if ~`PTE_V
                else if ((pte_permissions & `PTE_A) == 1'b0 )   $fdisplay( update_pa, "%h", fault_resp);   // Fault if ~`PTE_A  
                else if ((pte_permissions[3:1] == 3'b010))      $fdisplay( update_pa, "%h", fault_resp);   // Fault if Reserved for future use of XWR bits are used 
                else if ((pte_permissions[3:1] == 3'b110))      $fdisplay( update_pa, "%h", fault_resp);   // Fault if Reserved for future use of XWR bits are used
                else if (ddtp_mode_bare)                        $fdisplay( update_pa, "%h", va.sv39_va);   // PA=VA if DDTP mode is set to bare
                else if (ddtp_mode_off)                         $fdisplay( update_pa, "%h", fault_resp);   // Fault if DDDTP mode is set to off
                else if (misaligned_lvl2)                       $fdisplay( update_pa, "%h", fault_resp);   // Fault mislaigned pte for level2 
                else if (misaligned_lvl1)                       $fdisplay( update_pa, "%h", fault_resp);   // Fault mislaigned pte for level1
                else if (lvl0_pointer)                          $fdisplay( update_pa, "%h", fault_resp);   // Fault for lvl0 pointer                
                else if (svnapot_pte) begin    
                    `ifdef LEVEL2
                        $fdisplay( update_pa, "%h", fault_resp);
                    `elsif LEVEL1
                        $fdisplay( update_pa, "%h", fault_resp);      
                    `elsif LEVEL0
                        if ((pte.ppn0[2:0] != 'b000) || (pte.n ==1'b0)) $fdisplay( update_pa, "%h", fault_resp);   // Fault if PTE has N=1 and ppn0[3:0]!='h0
                        else $fdisplay( update_pa, "%h", pte.physical_address);
                    `endif
                end                
                else $fdisplay( update_pa, "%h", pte.physical_address); 

                $fdisplay( update_va, "%h", va.sv39_va);
                    `ifdef LEVEL2
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // pte stored at level2 \n",va.mem_addr_level2,pte.pte_sv39);
                    `elsif LEVEL1
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // level1 root base pointer ",va.mem_addr_level2,va.sv39_level1_pointer);
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // pte stored at level1 \n",va.mem_addr_level1,pte.pte_sv39);
                    `elsif LEVEL0
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // level1 root base pointer ",va.mem_addr_level2,va.sv39_level1_pointer);
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // level0 root base pointer ",va.mem_addr_level1,va.sv39_level0_pointer);
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // pte stored at level0 \n ",va.mem_addr_level0,pte.pte_sv39);                
                    `endif 
                `endif

                `ifdef MODE_SV39x4 // When the Mode is Sv39x4 ( Second stage Translation )

                    if (`first_stage == `FIRST_STAGE_BARE) begin // If First stage is Bare
                            dc_ta                = 'h0;
                            dc_fsc               = 'h0;
                            dc_msiptp            = 'h0;
                            dc_msi_addr_mask     = 'h0;
                            dc_msi_addr_pattern  = 'h0;
                            dc_reserved          = 'h0;

                        `ifdef DDTP_MODE_LVL1    
                            dc_tc                = 'h1;
                            dc_iohgatp           = ((`SV39x4_LVL2_ADDR >> 12) | (`Sv39x4_MODE));
                        `elsif DDTP_MODE_LVL2
                            $fdisplay(update_dc,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h, 64'h%h); // Pointer to DDTP LVL1",dc.mem_addr_lvl2,dc.nonleaf1_entry);
                            dc_tc                = 'h1;
                            dc_iohgatp           = ((`SV39x4_LVL2_ADDR >> 12) | (`Sv39x4_MODE));
                        `elsif DDTP_MODE_LVL3
                            $fdisplay(update_dc,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h, 64'h%h); // Pointer to DDTP LVL2",dc.mem_addr_lvl3,dc.nonleaf2_entry);
                            $fdisplay(update_dc,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h, 64'h%h); // Pointer to DDTP LVL1",dc.mem_addr_lvl2,dc.nonleaf1_entry);
                            dc_tc                = 'h1;
                            dc_iohgatp           = ((`SV39x4_LVL2_ADDR >> 12) | (`Sv39x4_MODE));                            
                        `endif
                    end

                // DC Contex Setup in Memory
                $fdisplay(update_dc,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h, 64'h%h);"   ,dc.mem_addr_lvl1,dc_tc );
                $fdisplay(update_dc,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h, 64'h%h);"   ,dc.mem_addr_lvl1 + 'h8,dc_iohgatp); 
                $fdisplay(update_dc,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h, 64'h%h);"   ,dc.mem_addr_lvl1 + 'h10,dc_ta); 
                $fdisplay(update_dc,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h, 64'h%h);"   ,dc.mem_addr_lvl1 + 'h18,dc_fsc); 
                $fdisplay(update_dc,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h, 64'h%h);"   ,dc.mem_addr_lvl1 + 'h20,dc_msiptp); 
                $fdisplay(update_dc,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h, 64'h%h);"   ,dc.mem_addr_lvl1 + 'h28,dc_msi_addr_mask); 
                $fdisplay(update_dc,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h, 64'h%h);"   ,dc.mem_addr_lvl1 + 'h30,dc_msi_addr_pattern); 
                $fdisplay(update_dc,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h, 64'h%h);\n" ,dc.mem_addr_lvl1 + 'h38,dc_reserved);   

                    if(dc_tc[0] == 1) begin

                        if ((dc_tc[63:32] !=0) && ({dc_ta[63:32],dc_ta[11:0]} != 0) && (dc_fsc[59:44] != 0) && (dc_msiptp[59:44] != 0) && (dc_msi_addr_mask[63:52] != 0) && (dc_msi_addr_pattern[63:52] !=0) && (dc_reserved !=0)) begin
                            $fdisplay( update_pa, "%h", fault_resp);        //Fault if reserved bits are set
                        end
                        else if ((dc_tc[1] == 0) && (dc_tc[3] == 1)) begin
                            $fdisplay( update_pa, "%h", fault_resp);       //Fault if DC.tc.EN_ATS is 0 and DC.tc.T2GPA is 1
                        end
                        else if ((dc_tc[1] == 0) && (dc_tc[2] == 1)) begin
                            $fdisplay( update_pa, "%h", fault_resp);       //Fault if DC.tc.EN_ATS is 0 and DC.tc.PRI is 1
                        end
                        else if ((dc_tc[2] == 0) && (dc_tc[6] == 1)) begin
                            $fdisplay( update_pa, "%h", fault_resp);       //Fault if DC.tc.EN_PRI is 0 and DC.tc.T2GPA is PRPR
                        end
                        else if ((dc_tc[3] == 1) && (dc_iohgatp[63:60] == 1)) begin
                            $fdisplay( update_pa, "%h", fault_resp);       //Fault if DC.tc.T2GPA is 1 and DC.iohgatp.MODE is Bare
                        end
                        else if ((dc_tc[5] == 0) && (((dc_fsc[63:60] >= 1) && (dc_fsc[63:60] <= 7)) || ((dc_fsc[63:60] >= 11) && (dc_fsc[63:60] <= 15)))) begin
                            $fdisplay( update_pa, "%h", fault_resp);       //Fault if DC.tc.PDTV is 0 and DC.fsc.iosatp.MODE encoding is not a valid encoding
                        end
                        else if ((dc_tc[5] == 0) && (dc_tc[9] == 1)) begin
                            $fdisplay( update_pa, "%h", fault_resp);       //Fault if DC.tc.PDTV is 0 and DC.tc.DPE is 1
                        end
                        else if ((dc_iohgatp[63:60] != 0) && (dc_iohgatp[13:0] != 0)) begin
                            $fdisplay( update_pa, "%h", fault_resp);       //Fault if DC.tc.T2GPA is 1 and DC.iohgatp.MODE is Bare
                        end
                        // PTEs Configration Checks 
                        else if((pte_permissions & `PTE_V) == 1'b0 )    $fdisplay( update_pa, "%h", fault_resp);   // Fault if ~`PTE_V
                        else if ((pte_permissions & `PTE_A) == 1'b0 )   $fdisplay( update_pa, "%h", fault_resp);   // Fault if ~`PTE_A 
                        else if ((pte_permissions[3:1] == 3'b010))      $fdisplay( update_pa, "%h", fault_resp);   // Fault if Reserved for future use of XWR bits are used 
                        else if ((pte_permissions[3:1] == 3'b110))      $fdisplay( update_pa, "%h", fault_resp);   // Fault if Reserved for future use of XWR bits are used
                        else if (ddtp_mode_bare)                        $fdisplay( update_pa, "%h", va.sv39_va);   // PA=VA if DDTP mode is set to bare
                        else if (ddtp_mode_off)                         $fdisplay( update_pa, "%h", fault_resp);   // Fault if DDDTP mode is set to off
                        else if (misaligned_lvl2)                       $fdisplay( update_pa, "%h", fault_resp);   // Fault mislaigned pte for level2 
                        else if (misaligned_lvl1)                       $fdisplay( update_pa, "%h", fault_resp);   // Fault mislaigned pte for level1
                        else if (lvl0_pointer)                          $fdisplay( update_pa, "%h", fault_resp);   // Fault for lvl0 pointer
                        else if (svnapot_pte) begin                 
                            `ifdef LEVEL2
                                $fdisplay( update_pa, "%h", fault_resp);
                            `elsif LEVEL1
                                $fdisplay( update_pa, "%h", fault_resp);      
                            `elsif LEVEL0
                                if ((pte.ppn0[2:0] != 'b000) || (pte.n ==1'b0)) $fdisplay( update_pa, "%h", fault_resp);   // Fault if PTE has N=1 and ppn0[3:0]!='h0
                                else $fdisplay( update_pa, "%h", pte.physical_address); 
                            `endif
                        end
                        else $fdisplay( update_pa, "%h", pte.physical_address);
                    end else begin 
                        $fdisplay( update_pa, "%h", fault_resp); //Fault if DC is not valid
                    end
                               
                
                // Memory Update for PTEs
                $fdisplay( update_va, "%h", va.sv39_va);
                    `ifdef LEVEL2
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // pte stored at level2 \n ",va.mem_addr_level2,pte.pte_sv39); 
                    `elsif LEVEL1
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // level1 root base pointer ",va.mem_addr_level2,va.sv39x4_level1_pointer);
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // pte stored at level1 \n",va.mem_addr_level1,pte.pte_sv39);
                    `elsif LEVEL0 
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // level1 root base pointer ",va.mem_addr_level2,va.sv39x4_level1_pointer);
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // level0 root base pointer ",va.mem_addr_level1,va.sv39x4_level0_pointer);
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // pte stored at level0 \n",va.mem_addr_level0,pte.pte_sv39);                
                    `endif 
                `endif

                `ifdef MODE_SV48

                if((pte_permissions & `PTE_V) == 1'b0 )         $fdisplay( update_pa, "%h", fault_resp);   // Fault if ~`PTE_V
                else if ((pte_permissions & `PTE_A) == 1'b0 )   $fdisplay( update_pa, "%h", fault_resp);   // Fault if ~`PTE_A 
                else if ((pte_permissions[3:1] == 3'b010))      $fdisplay( update_pa, "%h", fault_resp);   // Fault if Reserved for future use of XWR bits are used 
                else if ((pte_permissions[3:1] == 3'b110))      $fdisplay( update_pa, "%h", fault_resp);   // Fault if Reserved for future use of XWR bits are used 
                else if (ddtp_mode_bare)                        $fdisplay( update_pa, "%h", va.sv39_va);   // PA=VA if DDTP mode is set to bare
                else if (ddtp_mode_off)                         $fdisplay( update_pa, "%h", fault_resp);   // Fault if DDDTP mode is set to off
                else if (misaligned_lvl3)                       $fdisplay( update_pa, "%h", fault_resp);   // Fault mislaigned pte for level3                  
                else if (misaligned_lvl2)                       $fdisplay( update_pa, "%h", fault_resp);   // Fault mislaigned pte for level2 
                else if (misaligned_lvl1)                       $fdisplay( update_pa, "%h", fault_resp);   // Fault mislaigned pte for level1                               
                else if (lvl0_pointer)                          $fdisplay( update_pa, "%h", fault_resp);   // Fault for lvl0 pointer
                else if (svnapot_pte) begin
                    `ifdef LEVEL3
                        $fdisplay( update_pa, "%h", fault_resp);                        
                    `elsif LEVEL2
                        $fdisplay( update_pa, "%h", fault_resp);
                    `elsif LEVEL1
                        $fdisplay( update_pa, "%h", fault_resp);      
                    `elsif LEVEL0
                        if ((pte.ppn0[2:0] != 'b000) || (pte.n ==1'b0)) $fdisplay( update_pa, "%h", fault_resp);   // Fault if PTE has N=1 and ppn0[3:0]!='h0
                        else $fdisplay( update_pa, "%h", pte.physical_address);
                    `endif
                end                
                else $fdisplay( update_pa, "%h", pte.physical_address);  

                $fdisplay( update_va, "%h", va.sv48_va);
                    `ifdef LEVEL3
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // pte stored at level3 \n",va.mem_addr_level3,pte.pte_sv48);
                    `elsif LEVEL2
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // level2 root base pointer ",va.mem_addr_level3,va.sv48_level2_pointer);
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // pte stored at level2 \n",va.mem_addr_level2,pte.pte_sv48);                
                    `elsif LEVEL1
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // level2 root base pointer ",va.mem_addr_level3,va.sv48_level2_pointer);
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // level1 root base pointer ",va.mem_addr_level2,va.sv48_level1_pointer);
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // pte stored at level1 \n",va.mem_addr_level1,pte.pte_sv48);                
                    `elsif LEVEL0
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // level2 root base pointer ",va.mem_addr_level3,va.sv48_level2_pointer);
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // level1 root base pointer ",va.mem_addr_level2,va.sv48_level1_pointer);
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // level0 root base pointer ",va.mem_addr_level1,va.sv48_level0_pointer);
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // pte stored at level0 \n",va.mem_addr_level0,pte.pte_sv48);                
                    `endif 
                `endif

                `ifdef MODE_SV48x4

                    if ( ~ `first_stage) begin // If First stage is Bare
                            dc_ta                = 'h0;
                            dc_fsc               = 'h0;
                            dc_msiptp            = 'h0;
                            dc_msi_addr_mask     = 'h0;
                            dc_msi_addr_pattern  = 'h0;
                            dc_reserved          = 'h0;

                        `ifdef DDTP_MODE_LVL1    
                            dc_tc                = 'h1;
                            dc_iohgatp           = ((`SV48x4_LVL3_ADDR >> 12) | (`Sv48x4_MODE));
                        `elsif DDTP_MODE_LVL2
                            $fdisplay(update_dc,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h, 64'h%h); // Pointer to DDTP LVL1",dc.mem_addr_lvl2,dc.nonleaf1_entry);
                            dc_tc                = 'h1;
                            dc_iohgatp           = ((`SV48x4_LVL3_ADDR >> 12) | (`Sv48x4_MODE));
                        `elsif DDTP_MODE_LVL3
                            $fdisplay(update_dc,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h, 64'h%h); // Pointer to DDTP LVL1",dc.mem_addr_lvl2,dc.nonleaf1_entry);
                            $fdisplay(update_dc,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h, 64'h%h); // Pointer to DDTP LVL2",dc.mem_addr_lvl3,dc.nonleaf2_entry);
                            dc_tc                = 'h1;
                            dc_iohgatp           = ((`SV48x4_LVL3_ADDR >> 12) | (`Sv48x4_MODE));                            
                        `endif
                    end

                // DC Contex Setup in Memory
                $fdisplay(update_dc,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h, 64'h%h);"   ,dc.mem_addr_lvl1,dc_tc );
                $fdisplay(update_dc,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h, 64'h%h);"   ,dc.mem_addr_lvl1 + 'h8,dc_iohgatp); 
                $fdisplay(update_dc,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h, 64'h%h);"   ,dc.mem_addr_lvl1 + 'h10,dc_ta); 
                $fdisplay(update_dc,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h, 64'h%h);"   ,dc.mem_addr_lvl1 + 'h18,dc_fsc); 
                $fdisplay(update_dc,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h, 64'h%h);"   ,dc.mem_addr_lvl1 + 'h20,dc_msiptp); 
                $fdisplay(update_dc,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h, 64'h%h);"   ,dc.mem_addr_lvl1 + 'h28,dc_msi_addr_mask); 
                $fdisplay(update_dc,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h, 64'h%h);"   ,dc.mem_addr_lvl1 + 'h30,dc_msi_addr_pattern); 
                $fdisplay(update_dc,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h, 64'h%h);\n" ,dc.mem_addr_lvl1 + 'h38,dc_reserved);  

                if((pte_permissions & `PTE_V) == 1'b0 )         $fdisplay( update_pa, "%h", fault_resp);   // Fault if ~`PTE_V
                else if ((pte_permissions & `PTE_A) == 1'b0 )   $fdisplay( update_pa, "%h", fault_resp);   // Fault if ~`PTE_A 
                else if ((pte_permissions[3:1] == 3'b010))      $fdisplay( update_pa, "%h", fault_resp);   // Fault if Reserved for future use of XWR bits are used 
                else if ((pte_permissions[3:1] == 3'b110))      $fdisplay( update_pa, "%h", fault_resp);   // Fault if Reserved for future use of XWR bits are used
                else if (ddtp_mode_bare)                        $fdisplay( update_pa, "%h", va.sv39_va);   // PA=VA if DDTP mode is set to bare
                else if (ddtp_mode_off)                         $fdisplay( update_pa, "%h", fault_resp);   // Fault if DDDTP mode is set to off
                else if (misaligned_lvl3)                       $fdisplay( update_pa, "%h", fault_resp);   // Fault mislaigned pte for level3 
                else if (misaligned_lvl2)                       $fdisplay( update_pa, "%h", fault_resp);   // Fault mislaigned pte for level2 
                else if (misaligned_lvl1)                       $fdisplay( update_pa, "%h", fault_resp);   // Fault mislaigned pte for level1                              
                else if (lvl0_pointer)                          $fdisplay( update_pa, "%h", fault_resp);   // Fault for lvl0 pointer
                else if (svnapot_pte) begin
                    `ifdef LEVEL3
                        $fdisplay( update_pa, "%h", fault_resp);                        
                    `elsif LEVEL2
                        $fdisplay( update_pa, "%h", fault_resp);
                    `elsif LEVEL1
                        $fdisplay( update_pa, "%h", fault_resp);      
                    `elsif LEVEL0
                        if ((pte.ppn0[2:0] != 'b000) || (pte.n ==1'b0)) $fdisplay( update_pa, "%h", fault_resp);   // Fault if PTE has N=1 and ppn0[3:0]!='h0
                        else $fdisplay( update_pa, "%h", pte.physical_address);
                    `endif
                end                
                else $fdisplay( update_pa, "%h", pte.physical_address);

                $fdisplay( update_va, "%h", va.sv48_va);
                    `ifdef LEVEL3
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // pte stored at level3 \n ",va.mem_addr_level3,pte.pte_sv48);                
                    `elsif LEVEL2
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // level2 root base pointer ",va.mem_addr_level3,va.sv48x4_level2_pointer);
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // pte stored at level2 \n",va.mem_addr_level2,pte.pte_sv48);                
                    `elsif LEVEL1
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // level2 root base pointer ",va.mem_addr_level3,va.sv48x4_level2_pointer);
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // level1 root base pointer ",va.mem_addr_level2,va.sv48x4_level1_pointer);
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // pte stored at level1 \n",va.mem_addr_level1,pte.pte_sv48);                
                    `elsif LEVEL0
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // level2 root base pointer ",va.mem_addr_level3,va.sv48x4_level2_pointer);
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // level1 root base pointer ",va.mem_addr_level2,va.sv48x4_level1_pointer);
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // level0 root base pointer ",va.mem_addr_level1,va.sv48x4_level0_pointer);
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // pte stored at level0 \n",va.mem_addr_level0,pte.pte_sv48);                
                    `endif 
                `endif

                `ifdef MODE_SV57

                if((pte_permissions & `PTE_V) == 1'b0 )         $fdisplay( update_pa, "%h", fault_resp);   // Fault if ~`PTE_V
                else if ((pte_permissions & `PTE_A) == 1'b0 )   $fdisplay( update_pa, "%h", fault_resp);   // Fault if ~`PTE_A 
                else if ((pte_permissions[3:1] == 3'b010))      $fdisplay( update_pa, "%h", fault_resp);   // Fault if Reserved for future use of XWR bits are used 
                else if ((pte_permissions[3:1] == 3'b110))      $fdisplay( update_pa, "%h", fault_resp);   // Fault if Reserved for future use of XWR bits are used 
                else if (ddtp_mode_bare)                        $fdisplay( update_pa, "%h", va.sv39_va);   // PA=VA if DDTP mode is set to bare
                else if (ddtp_mode_off)                         $fdisplay( update_pa, "%h", fault_resp);   // Fault if DDDTP mode is set to off
                else if (misaligned_lvl4)                       $fdisplay( update_pa, "%h", fault_resp);   // Fault mislaigned pte for level4
                else if (misaligned_lvl3)                       $fdisplay( update_pa, "%h", fault_resp);   // Fault mislaigned pte for level3
                else if (misaligned_lvl2)                       $fdisplay( update_pa, "%h", fault_resp);   // Fault mislaigned pte for level2 
                else if (misaligned_lvl1)                       $fdisplay( update_pa, "%h", fault_resp);   // Fault mislaigned pte for level1                                
                else if (lvl0_pointer)                          $fdisplay( update_pa, "%h", fault_resp);   // Fault for lvl0 pointer
                else if (svnapot_pte) begin
                    `ifdef LEVEL4
                        $fdisplay( update_pa, "%h", fault_resp);                    
                    `elsif LEVEL3
                        $fdisplay( update_pa, "%h", fault_resp);                        
                    `elsif LEVEL2
                        $fdisplay( update_pa, "%h", fault_resp);
                    `elsif LEVEL1
                        $fdisplay( update_pa, "%h", fault_resp);      
                    `elsif LEVEL0
                        if ((pte.ppn0[2:0] != 'b000) || (pte.n ==1'b0)) $fdisplay( update_pa, "%h", fault_resp);   // Fault if PTE has N=1 and ppn0[3:0]!='h0
                        else $fdisplay( update_pa, "%h", pte.physical_address);
                    `endif
                end                
                else $fdisplay( update_pa, "%h", pte.physical_address);

                $fdisplay( update_va, "%h", va.sv57_va);
                    `ifdef LEVEL4
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // pte stored at level4 \n",va.mem_addr_level4,pte.pte_sv57);
                    `elsif LEVEL3
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // level3 root base pointer ",va.mem_addr_level4,va.sv57_level3_pointer);
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // pte stored at level3 \n",va.mem_addr_level3,pte.pte_sv57);    
                    `elsif LEVEL2
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // level3 root base pointer ",va.mem_addr_level4,va.sv57_level3_pointer);
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // level2 root base pointer ",va.mem_addr_level3,va.sv57_level2_pointer);
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // pte stored at level2 \n",va.mem_addr_level2,pte.pte_sv57);  
                    `elsif LEVEL1
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // level3 root base pointer ",va.mem_addr_level4,va.sv57_level3_pointer);
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // level2 root base pointer ",va.mem_addr_level3,va.sv57_level2_pointer);
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // level1 root base pointer ",va.mem_addr_level2,va.sv57_level1_pointer);
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // pte stored at level1 \n",va.mem_addr_level1,pte.pte_sv57);   
                    `elsif LEVEL0
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // level3 root base pointer ",va.mem_addr_level4,va.sv57_level3_pointer);
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // level2 root base pointer ",va.mem_addr_level3,va.sv57_level2_pointer);
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // level1 root base pointer ",va.mem_addr_level2,va.sv57_level1_pointer);
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // level0 root base pointer ",va.mem_addr_level1,va.sv57_level0_pointer);
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // pte stored at level0\n ",va.mem_addr_level0,pte.pte_sv57);                
                    `endif 
                `endif

                `ifdef MODE_SV57x4

                    if ( ~ `first_stage) begin // If First stage is Bare
                            dc_ta                = 'h0;
                            dc_fsc               = 'h0;
                            dc_msiptp            = 'h0;
                            dc_msi_addr_mask     = 'h0;
                            dc_msi_addr_pattern  = 'h0;
                            dc_reserved          = 'h0;

                        `ifdef DDTP_MODE_LVL1    
                            dc_tc                = 'h1;
                            dc_iohgatp           = ((`SV57x4_LVL4_ADDR >> 12) | (`Sv57x4_MODE));
                        `elsif DDTP_MODE_LVL2
                            $fdisplay(update_dc,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h, 64'h%h); // Pointer to DDTP LVL1",dc.mem_addr_lvl2,dc.nonleaf1_entry);
                            dc_tc                = 'h1;
                            dc_iohgatp           = ((`SV57x4_LVL4_ADDR >> 12) | (`Sv57x4_MODE));
                        `elsif DDTP_MODE_LVL3
                            $fdisplay(update_dc,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h, 64'h%h); // Pointer to DDTP LVL1",dc.mem_addr_lvl2,dc.nonleaf1_entry);
                            $fdisplay(update_dc,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h, 64'h%h); // Pointer to DDTP LVL2",dc.mem_addr_lvl3,dc.nonleaf2_entry);
                            dc_tc                = 'h1;
                            dc_iohgatp           = ((`SV57x4_LVL4_ADDR >> 12) | (`Sv57x4_MODE));                            
                        `endif
                    end

                // DC Contex Setup in Memory
                $fdisplay(update_dc,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h, 64'h%h);"   ,dc.mem_addr_lvl1,dc_tc );
                $fdisplay(update_dc,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h, 64'h%h);"   ,dc.mem_addr_lvl1 + 'h8,dc_iohgatp); 
                $fdisplay(update_dc,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h, 64'h%h);"   ,dc.mem_addr_lvl1 + 'h10,dc_ta); 
                $fdisplay(update_dc,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h, 64'h%h);"   ,dc.mem_addr_lvl1 + 'h18,dc_fsc); 
                $fdisplay(update_dc,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h, 64'h%h);"   ,dc.mem_addr_lvl1 + 'h20,dc_msiptp); 
                $fdisplay(update_dc,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h, 64'h%h);"   ,dc.mem_addr_lvl1 + 'h28,dc_msi_addr_mask); 
                $fdisplay(update_dc,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h, 64'h%h);"   ,dc.mem_addr_lvl1 + 'h30,dc_msi_addr_pattern); 
                $fdisplay(update_dc,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h, 64'h%h);\n" ,dc.mem_addr_lvl1 + 'h38,dc_reserved); 

                if((pte_permissions & `PTE_V) == 1'b0 )         $fdisplay( update_pa, "%h", fault_resp);   // Fault if ~`PTE_V
                else if ((pte_permissions & `PTE_A) == 1'b0 )   $fdisplay( update_pa, "%h", fault_resp);   // Fault if ~`PTE_A 
                else if ((pte_permissions[3:1] == 3'b010))      $fdisplay( update_pa, "%h", fault_resp);   // Fault if Reserved for future use of XWR bits are used 
                else if ((pte_permissions[3:1] == 3'b110))      $fdisplay( update_pa, "%h", fault_resp);   // Fault if Reserved for future use of XWR bits are used
                else if (ddtp_mode_bare)                        $fdisplay( update_pa, "%h", va.sv39_va);   // PA=VA if DDTP mode is set to bare
                else if (ddtp_mode_off)                         $fdisplay( update_pa, "%h", fault_resp);   // Fault if DDDTP mode is set to off
                else if (misaligned_lvl4)                       $fdisplay( update_pa, "%h", fault_resp);   // Fault mislaigned pte for level4
                else if (misaligned_lvl3)                       $fdisplay( update_pa, "%h", fault_resp);   // Fault mislaigned pte for level3                
                else if (misaligned_lvl2)                       $fdisplay( update_pa, "%h", fault_resp);   // Fault mislaigned pte for level2 
                else if (misaligned_lvl1)                       $fdisplay( update_pa, "%h", fault_resp);   // Fault mislaigned pte for level1                                 
                else if (lvl0_pointer)                          $fdisplay( update_pa, "%h", fault_resp);   // Fault for lvl0 pointer
                else if (svnapot_pte) begin
                    `ifdef LEVEL4
                        $fdisplay( update_pa, "%h", fault_resp);                    
                    `elsif LEVEL3
                        $fdisplay( update_pa, "%h", fault_resp);                        
                    `elsif LEVEL2
                        $fdisplay( update_pa, "%h", fault_resp);
                    `elsif LEVEL1
                        $fdisplay( update_pa, "%h", fault_resp);      
                    `elsif LEVEL0
                        if ((pte.ppn0[2:0] != 'b000) || (pte.n ==1'b0)) $fdisplay( update_pa, "%h", fault_resp);   // Fault if PTE has N=1 and ppn0[3:0]!='h0
                        else $fdisplay( update_pa, "%h", pte.physical_address);
                    `endif
                end                
                else $fdisplay( update_pa, "%h", pte.physical_address); 

                $fdisplay( update_va, "%h", va.sv57_va);
                    `ifdef LEVEL4
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // pte stored at level4 \n",va.mem_addr_level4,pte.pte_sv57);
                    `elsif LEVEL3
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // level3 root base pointer ",va.mem_addr_level4,va.sv57x4_level3_pointer);
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // pte stored at level3 \n",va.mem_addr_level3,pte.pte_sv57);    
                    `elsif LEVEL2
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // level3 root base pointer ",va.mem_addr_level4,va.sv57x4_level3_pointer);
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // level2 root base pointer ",va.mem_addr_level3,va.sv57x4_level2_pointer);
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // pte stored at level2 \n",va.mem_addr_level2,pte.pte_sv57);  
                    `elsif LEVEL1
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // level3 root base pointer ",va.mem_addr_level4,va.sv57x4_level3_pointer);
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // level2 root base pointer ",va.mem_addr_level3,va.sv57x4_level2_pointer);
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // level1 root base pointer ",va.mem_addr_level2,va.sv57x4_level1_pointer);
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // pte stored at level1 \n",va.mem_addr_level1,pte.pte_sv57);   
                    `elsif LEVEL0
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // level3 root base pointer ",va.mem_addr_level4,va.sv57x4_level3_pointer);
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // level2 root base pointer ",va.mem_addr_level3,va.sv57x4_level2_pointer);
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // level1 root base pointer ",va.mem_addr_level2,va.sv57x4_level1_pointer);
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // level0 root base pointer ",va.mem_addr_level1,va.sv57x4_level0_pointer);
                        $fdisplay(update_mem,"env_wrapper.aaxi_aace_base_env.env0.slave[0].driver.memory_dw_fill_direct(40'h%h , 64'h%h); // pte stored at level0 \n",va.mem_addr_level0,pte.pte_sv57);                
                    `endif 
                `endif
                $fclose(update_mem);
                $fclose(update_pa);
                $fclose(update_va);  
                $fclose(update_dc);
                $fclose(update_did);                              
            end
        end
    end
endmodule
