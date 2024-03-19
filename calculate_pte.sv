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
/// Description: This class is used to setup the PTE according to the mode 
/// selected and also calculates the physical adress out of it 
///////////////////////////////////////////////////////////////////////////

`include "calculate_va.sv"
class calculate_pte extends calculate_va;
        bit [9:0] permissions;
   rand bit [8:0] ppn0;
   rand bit [8:0] ppn1;
   rand bit [8:0] ppn2;
   rand bit [12:0]ppn3;
   rand bit [8:0] ppn3_sv57;
   rand bit [3:0] ppn4;
   rand bit [21:0]ppn2_sv39;
        bit [6:0] reserved;
        bit [1:0] pbmt;
        bit [63:0]pte_sv39;
        bit [63:0]pte_sv48;
        bit [63:0]pte_sv57;
        bit       n;
        bit [55:0]physical_address; 
        bit [11:0]offset; 
        bit [8:0]vpn0;
        bit [8:0]vpn1;
        bit [8:0]vpn2;
        bit [8:0]vpn3;
        bit [8:0]vpn4;                         

   `ifdef LEVEL4
        constraint misaligned_lvl4_check {
         (ppn3 == 'h0) && (ppn2 == 'h0) && (ppn1 == 21'h0) &&  (ppn0 == 9'h0);
        }; // misaligned level4 pte 

   `elsif LEVEL3
        constraint misaligned_lvl3_check {
         (ppn2 == 'h0) && (ppn1 == 21'h0) &&  (ppn0 == 9'h0);
        }; // misaligned level3 pte             
   `elsif LEVEL2
      `ifdef MISALIGNED_PTE
         constraint misaligned_lvl2 {
            (ppn1 != 21'h0) &&  (ppn0 != 9'h0);
           }; // misaligned level2 pte         
      `elsif ALIGNED_PTE
         constraint aligned_pte_lvl2 {
            (ppn1 == 21'h0) &&  (ppn0 == 9'h0);
           }; // misaligned level2 pte
      `endif

   `elsif LEVEL1
      `ifdef MISALIGNED_PTE
         constraint misaligned_lvl1 {
            (ppn0 != 9'h0);
           }; // misaligned level1 pte         
      `elsif ALIGNED_PTE
         constraint aligned_pte_lvl1 {
            (ppn0 == 0);
           }; // misaligned level1 pte
      `endif

   `elsif LEVEL0
      `ifdef SVNAPOT_PTE
         constraint svnapot_pte {
          ((ppn0[3:0] == 'h8));
         };        
      `endif 
   `endif

   function void pre_randomize();
   `ifdef LEVEL0
      `ifdef SVNAPOT_PTE
         n = 1'b1;         
      `endif 
   `endif  
   endfunction

   function void post_randomize();

      pte_sv39 = {n,pbmt,reserved,4'b0,ppn2_sv39,ppn1,ppn0,permissions};
      pte_sv48 = {n,pbmt,reserved,4'b0,ppn3,ppn2,ppn1,ppn0,permissions};
      pte_sv57 = {n,pbmt,reserved,4'b0,ppn4,ppn3_sv57,ppn2,ppn1,ppn0,permissions};
   
   endfunction

   function void calculate_pa();

      `ifdef MODE_SV39
         `ifdef LEVEL2
            physical_address = {ppn2_sv39,vpn1,vpn0,offset};
         `elsif LEVEL1
            physical_address = {ppn2_sv39,ppn1,vpn0,offset};
         `else
            physical_address = {(pte_sv39>>10),offset}; 
         `endif 

      `elsif MODE_SV39x4
         `ifdef LEVEL2
            physical_address = {ppn2_sv39,vpn1,vpn0,offset};
         `elsif LEVEL1
            physical_address = {ppn2_sv39,ppn1,vpn0,offset};
         `else
            physical_address = {(pte_sv39>>10),offset}; 
         `endif 

      `elsif MODE_SV48
         `ifdef LEVEL3
            physical_address = {ppn3,vpn2,vpn1,vpn0,offset};   
         `elsif LEVEL2
            physical_address = {ppn3,ppn2,vpn1,vpn0,offset};
         `elsif LEVEL1
            physical_address = {ppn3,ppn2,ppn1,vpn0,offset};
         `else
            physical_address = {(pte_sv48>>10),offset}; 
         `endif 

      `elsif MODE_SV48x4
         `ifdef LEVEL3
            physical_address = {ppn3,vpn2,vpn1,vpn0,offset};   
         `elsif LEVEL2
            physical_address = {ppn3,ppn2,vpn1,vpn0,offset};
         `elsif LEVEL1
            physical_address = {ppn3,ppn2,ppn1,vpn0,offset};
         `else
            physical_address = {(pte_sv48>>10),offset}; 
         `endif 
      
      `elsif MODE_SV57
         `ifdef LEVEL4
            physical_address = {ppn4,vpn3,vpn2,vpn1,vpn0,offset};   
         `elsif LEVEL3
            physical_address = {ppn4,ppn3_sv57,vpn2,vpn1,vpn0,offset};   
         `elsif LEVEL2
            physical_address = {ppn4,ppn3_sv57,ppn2,vpn1,vpn0,offset};
         `elsif LEVEL1
            physical_address = {ppn4,ppn3_sv57,ppn2,ppn1,vpn0,offset};
         `else
            physical_address = {(pte_sv57>>10),offset}; 
         `endif 

      `elsif MODE_SV57x4
         `ifdef LEVEL4
            physical_address = {ppn4,vpn3,vpn2,vpn1,vpn0,offset};   
         `elsif LEVEL3
            physical_address = {ppn4,ppn3_sv57,vpn2,vpn1,vpn0,offset};   
         `elsif LEVEL2
            physical_address = {ppn4,ppn3_sv57,ppn2,vpn1,vpn0,offset};
         `elsif LEVEL1
            physical_address = {ppn4,ppn3_sv57,ppn2,ppn1,vpn0,offset};
         `else
            physical_address = {(pte_sv57>>10),offset}; 
         `endif 
      `endif 

   endfunction
             
endclass