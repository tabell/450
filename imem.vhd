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

    "10110000", -- IN r0, xx
    "10110100", -- IN r1, xx
    "10111000", -- IN r2, xx
    "10111100", -- IN r3, xx
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
    "01000001", -- add r0, r1
    "01000001", -- add r0, r1
    "01010001", -- sub r0, r1
    "01110001", -- shr r0, r1
    "01000001", -- add r0, r1
    "01000001", -- add r0, r1
    "01000001", -- add r0, r1
    "01001000", -- add r2, r0
	"11000000", -- OUT r0
	"11010001", -- MOV r0 <- r1
	"11010010", -- MOV r0 <- r2
	"11010011", -- MOV r0 <- r3
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000", -- NOOP
	"00000000"); -- NOOP


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
