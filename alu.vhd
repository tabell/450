----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:04:17 02/01/2015 
-- Design Name: 
-- Module Name:    alu - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;


-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu is
    Port ( clk : in  std_ulogic;
           rst : in  std_ulogic;
           alu_mode : in  std_ulogic_VECTOR (2 downto 0);
           in_a : in  std_ulogic_VECTOR (7 downto 0);
           in_b : in  std_ulogic_VECTOR (7 downto 0);
           result : out  std_ulogic_VECTOR (7 downto 0);
           n : out  std_ulogic;
           z : out  std_ulogic);
end alu;

architecture Behavioral of alu is
begin
  process (clk)
  variable res : std_ulogic_vector(7 downto 0);
  variable tmp : std_ulogic_vector(23 downto 0);
  begin
  if rising_edge(clk) then
        case alu_mode is
          when "000" => res := std_ulogic_vector(signed(in_a) + signed(in_b));
          when "001" => res := std_ulogic_vector(signed(in_a) - signed(in_b));
          when "010" => res := std_ulogic_vector(shift_left(unsigned(in_a),1));
          when "011" => res := std_ulogic_vector(shift_right(unsigned(in_a),1));
          when "100" => res := in_a nand in_b;


          --  res := tmp(7 downto 0);
          when others => res := "00000000";
        end case;
        if (to_integer(signed(res)) < 0) then
          n <= '1';
        else
          n <= '0';
        end if; -- end if neg
        if (to_integer(signed(res)) = 0) then
          z <= '1';
        else
          z <= '0';
        end if; -- end if zero
      result <= res;
      end if;
  end process;
end Behavioral;

