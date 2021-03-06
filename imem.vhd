library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_ARITH.all;


entity imem is
    port(
         clk      : in  std_ulogic;
         rst      : in  std_ulogic;
         addr     : in  std_ulogic_vector (6 downto 0);
         data     : out std_ulogic_vector (7 downto 0)
         );
end imem;

architecture BHV of imem is

    type ROM_TYPE is array (0 to 127) of std_ulogic_vector (7 downto 0);

    constant rom_content : ROM_TYPE := (
    
    x"30", -- LOAD IMMEDIATE r0
    x"03", -- imm value 64
    x"34", -- LOAD IMMEDIATE r1
    x"FF", -- imm value -1
    x"38", -- LOAD IMMEDIATE r2
    x"14", -- imm value 
    x"3c", -- LOAD IMMEDIATE r3
    x"0a", -- imm value
    x"00", -- NOP
    x"00", -- NOP
    x"41", -- add r0, r1 # loop
    x"00", -- NOP
    x"00", -- NOP
    x"9a", -- branch on negative to r2 [contains address of exit]
    x"00", -- NOP
    x"00", -- NOP
    x"93", -- branch to r3 [contains address of loop]
    x"00", -- NOP
    x"00", -- NOP
    x"00", -- NOP
    --x"41", -- add r0, r1
    --x"41", -- add r0, r1
    --x"41", -- add r0, r1
    --x"41", -- add r0, r1
    --x"41", -- add r0, r1
    --x"41", -- add r0, r1
    --x"41", -- add r0, r1
    --x"48", -- add r2, r0
    --x"4b", -- add r2 <= r2 + r3
    --x"42", -- add r0 <= r0 + r2


--0 =>   x"b0", -- IN R0
--1 =>   x"b4", -- IN R1
--2 =>	x"bb", -- IN R2
--3 =>	x"64", -- SHL r1 0100
--4 =>	x"51", -- SUB r0, r1
--5 =>	x"D6", -- MOV r1, r2
--6 =>	x"49", -- ADD r2, r1
--7 =>	x"88", -- NAND r2, r0
--8 =>	x"C8", -- OUT r2			--At this point R[2] must be "00111100"
--9  =>	x"70", -- SHR r0
--10 =>	x"48", -- ADD r2, r0		--At this point negative flag must be set
--11 =>	x"C8", -- OUT r2		--At this point R[2] have to be "10011100"

--All other memory locations contain NOP
others =>	x"00");



begin

p1:    process (clk)
	 variable add_in : integer := 0;
    begin
        if rising_edge(clk) then
        	if rst = '0' then
				add_in := conv_integer(unsigned(addr));
		        data <= rom_content(add_in);
	        else
	        	data <= "00000000"; -- no-op
	        end if;
        end if;
    end process;
end BHV;
