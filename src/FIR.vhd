
--------------------------------------------------------
----- LOW PASS FIR FILTER FOR FILTRING NOISY ECG SIGNALS 
----------------------------------------------------------
-----------------------------------------------------------------------------
---- ORDER = 10 
---- NUMBER OF SAMPLES = 11 
---- NUMBER OF COEFFICIENTS =11 
--- INPUT DATA WIDTH = 8 BITS 
----OUTPUT DATA  WIDTH = 16
---------CONTAINS--------
---- ADDER = 2*16 BITS
---- MULTIPLIER = 8*8 BITS 
---- 8-BIT SHIFT REGISTER
---- 
---------------------------------------------------------------------------------



Library IEEE;  
 USE IEEE.Std_logic_1164.all;   
 USE IEEE.Std_logic_signed.all; 
 
 
------------------------------------------------FIR LOW PASS FILTER--------------------------------------------------
   
 entity FIR_RI is  
 
	port(  
		Din          : in      std_logic_vector(7 downto 0)     ;-- input data  
		Clk          : in      std_logic                                             ;-- input clk  
		reset    	   : in      std_logic                                             ;-- input reset  
		Dout     	   : out      std_logic_vector(15 downto 0))     ;-- output data  
 end FIR_RI;  
 
 
 
 architecture behaivioral of FIR_RI is  
 
 -- 8 bit Register  
 component Eight_bit_Reg   
  
		port(  
			Q : out std_logic_vector(7 downto 0);     
			Clk :in std_logic;    
			reset :in std_logic;   
			D :in std_logic_vector(7 downto 0)    
			);  
 end component;
 
 ---------------------------------------------COefficient----------------------------
 type Coeficient_type is array (0 to 10) of std_logic_vector(7 downto 0);  ---10 >>> IS THE ORDER OF THE FILTER AND Coeficient_type IS 11 = 11 sampels 
 -----------------------------------FIR filter coefficients----------------------------------------------------------------  
 
 
 
 constant coeficient: coeficient_type :=   
								(     X"F1",  
									  X"F3",  
                                      X"07",  
                                      X"26",  
                                      X"42",  
                                      X"4E",  
                                      X"42",  
                                      X"26",  
                                      X"07",  
                                      X"F3",  
                                      X"F1"                                     
                                    );   


									
 ---------------------------------------------------   THE IMPLIMENTATION OF THE FILTER   -------------------------------------------
 
 type shift_reg_type is array (0 to 10) of std_logic_vector(7 downto 0); -- ARRAY OF REGS 
 signal shift_reg : shift_reg_type; 
 
 type mult_type is array (0 to 10) of std_logic_vector(15 downto 0);  ---- SIZE OF [mult m*n] = (n+m) 
 signal mult : mult_type;
 
 
 type ADD_type is array (0 to 10) of std_logic_vector(15 downto 0);  --- o/p= preo/p of adder + o/p of mult = 16bit +16bit   = 16    +1 and we neglict the overflow 
 signal ADD: ADD_type;  
 
 begin  
 
 
------------------1ST STAGE -------------------

			shift_reg(0)     <= Din; 
            mult(0)<= Din*coeficient(0);  
            ADD(0)<= Din*coeficient(0); 

----------------------------NEXT STAGES----------------------------

            GEN_FIR:  
			
           for i in 0 to 9 generate  
           begin  
            ---------8 BIT REGISTER INSTANTIATION -----  
                 Eight_bit_Reg_unit : Eight_bit_Reg 
								port map ( Clk => Clk,   
											reset => reset,  
											D => shift_reg(i),  
											Q => shift_reg(i+1)  
										);       
            --------  MULTIPLIER 
                mult(i+1)<= shift_reg(i+1)*coeficient(i+1);  
				
				
            --------- ADDER 
				
                ADD(i+1)<=ADD(i)+mult(i+1);  
				
           end generate GEN_FIR; 

		   
           Dout <= ADD(10); 
					-----NEGLICTING THE OVERFLOW 
		   
		   
 end Architecture;  

 
 
 
 
 -----------------------------------------------------------------REG------------------------------------------------
 -- 8 BIT  Asynchrouns reset REGISTER DESIGN 
 Library IEEE;  
 USE IEEE.Std_logic_1164.all;   
 USE IEEE.Std_logic_signed.all; 
 
 entity Eight_bit_Reg is   
 
   port(  
    Q 		: out std_logic_vector(7 downto 0);    
    Clk 	:in std_logic;    
    reset 	:in std_logic;  
    D 		:in std_logic_vector(7 downto 0)    
   );  
 end Eight_bit_Reg;  
  -- arch 
 architecture Behavioral of Eight_bit_Reg is   
 begin   
      process(Clk,reset)  
      begin   
           if (reset = '1') then  
		   
                Q <= (others => '0');  
				
        elsif ( rising_edge(Clk) ) then  
		
                Q <= D;   
       end if; 
	   
      end process;   
 end Behavioral;
 
 
 
 
 
 

 