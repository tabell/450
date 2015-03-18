library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cpu is
Port (
	clk : in std_ulogic;
	rst : in std_ulogic;
	int : in std_ulogic; -- interrupt
	in_port : in std_ulogic_vector(7 downto 0);
	out_port : out std_ulogic_vector(7 downto 0)
	);
end cpu;

architecture Behavioral of cpu is
-- signals for components

-- regfile signals
signal regfile_addr_a : std_ulogic_vector(1 downto 0) := (others => 'Z');
signal regfile_addr_b : std_ulogic_vector(1 downto 0) := (others => 'Z');
signal regfile_data_a : std_ulogic_vector(7 downto 0) := (others => 'Z');
signal regfile_data_b : std_ulogic_vector(7 downto 0) := (others => 'Z');
signal regfile_addr_w : std_ulogic_vector(1 downto 0) := (others => 'Z');
signal regfile_data_w : std_ulogic_vector(7 downto 0) := (others => 'Z');
signal regfile_wr_en  : std_ulogic := '0';

-- alu signals
signal alu_mode     : std_ulogic_vector(2 downto 0) := (others => 'Z');
signal alu_in_a     : std_ulogic_vector(7 downto 0) := (others => 'Z');
signal alu_in_b     : std_ulogic_vector(7 downto 0) := (others => 'Z');
signal alu_result   : std_ulogic_vector(7 downto 0) := (others => 'Z');
signal alu_n        : std_ulogic := '0';
signal alu_z        : std_ulogic := '0';

-- rom signals
signal pc     : std_ulogic_vector(6 downto 0) := (others => 'Z');
signal rom_out     : std_ulogic_vector(7 downto 0) := (others => 'Z');

-- architectural signals
-- fetch/decode registers
signal fd_instr             : std_ulogic_vector(7 downto 0) := (others => 'Z');
signal fd_in_port_data      : std_ulogic_vector(7 downto 0) := (others => 'Z');

-- decode/execute registers
signal de_instr              : std_ulogic_vector(7 downto 0) := (others => 'Z');
signal de_reg_write_data     : std_ulogic_vector(7 downto 0) := (others => 'Z');
signal de_reg_write_addr     : std_ulogic_vector(1 downto 0) := (others => 'Z');
signal de_reg_write_en       : std_ulogic := '0';
signal de_alu_mode           : std_ulogic_vector(2 downto 0) := (others => 'Z');

-- execute/memory registers
signal em_instr              : std_ulogic_vector(7 downto 0) := (others => 'Z');
signal em_reg_write_addr     : std_ulogic_vector(1 downto 0) := (others => 'Z');
signal em_reg_write_data     : std_ulogic_vector(7 downto 0) := (others => 'Z');
signal em_reg_write_en       : std_ulogic := '0';

-- memory/writeback registers
signal mw_instr              : std_ulogic_vector(7 downto 0) := (others => 'Z');
signal mw_reg_write_addr     : std_ulogic_vector(1 downto 0) := (others => 'Z');
signal mw_reg_write_data     : std_ulogic_vector(7 downto 0) := (others => 'Z');
signal mw_reg_write_en       : std_ulogic := '0';

begin

    -- entity declarations for instantiations
    rom : entity work.imem port map(clk, rst, pc, rom_out);
    regfile : entity work.register_file port map(clk, rst, regfile_addr_a, regfile_addr_b, 
     regfile_data_a, regfile_data_b, 
     regfile_addr_w, regfile_data_w, 
     regfile_wr_en);
    alu1 : entity work.alu port map(clk, rst, alu_mode, alu_in_a, alu_in_b, alu_result, alu_n, alu_z);

    cpu: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                pc <= "0000000";
            else
-- fetch stage
                pc <= std_ulogic_vector(unsigned(pc) + to_unsigned(1,7));
                fd_instr <= rom_out; -- instruction register
                fd_in_port_data <= in_port;
-- decode stage
                de_instr <= fd_instr; -- instruction register

                case fd_instr(7 downto 4) is -- opcode
                 ----- ADD ----- SUB --- NAND --- SHR ---- SHL ----------
                when "0100" | "0101" | "0110" | "0111" | "1000" => -- any ALU operation
                    regfile_addr_a <= fd_instr(3 downto 2);
                    regfile_addr_b <= fd_instr(1 downto 0);
                    de_reg_write_en <= '1';
                    de_reg_write_addr <= fd_instr(3 downto 2);
                    -- alu mode
                    de_alu_mode(2)          <= fd_instr(7);
                    de_alu_mode(1 downto 0) <= fd_instr(5 downto 4);
                when "1011" => -- IN (read from input port)
                    de_reg_write_data <= fd_in_port_data;
                    de_reg_write_addr <= fd_instr(3 downto 2);
                    de_reg_write_en <= '1';

                    -- other instructions
                    de_alu_mode <= "ZZZ";
                when others =>
                    de_reg_write_data <= "11111111";
                    de_alu_mode <= "ZZZ";
                    de_reg_write_en <= '0';
                end case;
-- execute stage
                em_instr <= de_instr; -- instruction register
                em_reg_write_data <= de_reg_write_data;
                em_reg_write_en <= de_reg_write_en;

                alu_mode <= de_alu_mode;

-- memory stage
                mw_instr <= em_instr; -- instruction register
                mw_reg_write_en <= em_reg_write_en;
                mw_reg_write_data <= em_reg_write_data;

-- writeback stage
                regfile_data_w <= mw_reg_write_data;
                regfile_addr_w <= mw_instr(3 downto 2);
                regfile_wr_en <= em_reg_write_en;
            end if;
        end if;
    end process;
end Behavioral;

