class calculate_PTE;
        bit [9:0] permissions;
        bit [1:0] rsw;
   rand bit [8:0] ppn0;
   rand bit [8:0] ppn1;
   rand bit [21:0]ppn2;
        bit [6:0] reserved;
        bit [1:0] pbmt;
        bit [63:0]pte;
        bit       n;
        bit [55:0] physical_address; 
        bit [11:0] offset; 

   `ifdef LEVEL2
      constraint misaligned_lvl2_check {
         ppn1 == 21'h0 &&  ppn0 == 9'h0;
        }; // misaligned level2 pte
   `elsif LEVEL1
      constraint misaligned_lvl1_check {
         ppn0 == 0; 
        }; // misaligned level1 pte
   `endif 

 

   function void post_randomize();
      pte = {n,pbmt,reserved,ppn2,ppn1,ppn0,rsw,permissions};
   endfunction

   function void calculate_pa();
     physical_address = {(pte>>10),offset}; //pa needs to be updated if pte is on level 0 then vpn1 and vpn0 aty hai 
   endfunction
             
endclass