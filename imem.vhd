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

00 =>   x"b0", -- IN R0
01 =>   x"b4", -- IN R1
02 =>	x"bb", -- IN R2
03 =>	x"00", -- 0xFF, the immediate value
04 =>	x"00", -- LOADIMM r1, 0X0c
05 =>	x"00", -- 0x0C, the immediate value
06 =>	x"00", -- NOP 
07 =>	x"00", -- NOP
08 =>	x"00", -- NOP
09 =>	x"00", -- NOP
10 =>	x"64", -- SHL r1 0100
11 =>	x"00", -- NOP
12 =>	x"00", -- NOP
13 =>	x"00", -- NOP
14 =>	x"00", -- NOP
15 =>	x"51", -- SUB r0, r1
16 =>	x"00", -- LOADIMM r2, 0x03
17 =>	x"00", -- 0x03, the immediate value
18 =>	x"00", -- NOP
19 =>	x"00", -- NOP
20 =>	x"00", -- NOP
21 =>	x"00", -- NOP
22 =>	x"D6", -- MOV r1, r2
23 =>	x"00", -- NOP
24 =>	x"00", -- NOP
25 =>	x"00", -- NOP
26 =>	x"00", -- NOP
27 =>	x"00", -- IN r2			-- Set the Input port switches on "0xC0" ("11000000")
28 =>	x"00", -- NOP
29 =>	x"00", -- NOP
30 =>	x"00", -- NOP
31 =>	x"00", -- NOP
32 =>	x"00", -- STORE r2, 0x70
33 =>	x"00", -- Effective Address
34 =>	x"49", -- ADD r2, r1
35 =>	x"00", -- NOP
36 =>	x"00", -- NOP
37 =>	x"00", -- NOP
38 =>	x"00", -- NOP
39 =>	x"88", -- NAND r2, r0
40 =>	x"00", -- NOP
41 =>	x"00", -- NOP
42 =>	x"00", -- NOP
43 =>	x"00", -- NOP
44 =>	x"C8", -- OUT r2			--At this point R[2] must be "00111100"
45 =>	x"00", -- LOAD r0, 0x70
46 =>	x"00", -- Effective Address
47 =>	x"00", -- NOP
48 =>	x"00", -- NOP
49 =>	x"00", -- NOP
50 =>	x"00", -- NOP
51 =>	x"70", -- SHR r0
52 =>	x"00", -- NOP
53 =>	x"00", -- NOP
54 =>	x"00", -- NOP
55 =>	x"00", -- NOP
56 =>	x"48", -- ADD r2, r0		--At this point negative flag must be set
57 =>	x"00", -- NOP
58 =>	x"00", -- NOP
59 =>	x"00", -- NOP
60 =>	x"00", -- NOP
61 =>	x"C8", -- OUT r2		--At this point R[2] have to be "10011100"

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
