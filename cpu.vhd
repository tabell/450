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
signal pc                    : std_ulogic_vector(6 downto 0) := (others => 'Z');
signal rom_out          : std_ulogic_vector(7 downto 0) := (others => 'Z');
signal in_port_data   : std_ulogic_vector(7 downto 0) := (others => 'Z');

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
-- decode/exec control signals
signal de_reg_data_in_sel              : std_ulogic_vector(3 downto 0) := (others => '0');

-- execute/memory registers
signal em_instr              : std_ulogic_vector(7 downto 0) := (others => 'Z');
signal em_reg_write_addr     : std_ulogic_vector(1 downto 0) := (others => 'Z');
signal em_reg_write_data     : std_ulogic_vector(7 downto 0) := (others => 'Z');
signal em_reg_write_en       : std_ulogic := '0';
-- exec/mem control signals
signal em_reg_data_in_sel              : std_ulogic_vector(3 downto 0) := (others => '0');

-- memory/writeback registers
signal mw_instr              : std_ulogic_vector(7 downto 0) := (others => 'Z');

-- control signals
signal fetch_stalled       : std_ulogic := '0';
signal decode_stalled       : std_ulogic := '0';
signal execute_stalled       : std_ulogic := '0';
signal memory_stalled       : std_ulogic := '0';
signal writeback_stalled       : std_ulogic := '0';


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
                in_port_data <= in_port;
-- fetch stage
                if fetch_stalled = '0' then
                    pc <= std_ulogic_vector(unsigned(pc) + to_unsigned(1,7));
                    fd_instr <= rom_out; -- instruction register
                    fd_in_port_data <= in_port_data;
                    regfile_addr_a <= rom_out(3 downto 2);
                    regfile_addr_b <= rom_out(1 downto 0);
                end if;
-- decode stage
                if decode_stalled = '0' then
                    de_instr <= fd_instr; -- instruction register
                    case fd_instr(7 downto 4) is -- opcode
                     ----- ADD ----- SUB --- NAND --- SHR ---- SHL ----------
                    when "0100" | "0101" | "0110" | "0111" | "1000" => -- any ALU operation
                        de_reg_write_en <= '1';
                        de_reg_write_addr <= fd_instr(3 downto 2);
                        -- alu mode
                        alu_mode(2)          <= fd_instr(7);
                        alu_mode(1 downto 0) <= fd_instr(5 downto 4);
                        alu_in_a <= regfile_data_a;
                        alu_in_b <= regfile_data_b;
                        de_reg_data_in_sel <= x"0"; -- register data will  be written from alu result
                    when "1011" => -- IN (read from input port)
                        de_reg_write_data <= fd_in_port_data;
                        de_reg_write_addr <= fd_instr(3 downto 2);
                        de_reg_write_en <= '1';
                        de_reg_data_in_sel <= x"1"; -- register data will  be written from in port

                        -- other instructions
                        de_alu_mode <= "ZZZ";
                    when others =>
                        de_reg_write_data <= "11111111";
                        alu_mode <= "ZZZ";
                        de_reg_write_en <= '0';
                    end case;
                end if;
-- execute stage
                if execute_stalled = '0' then
                    em_instr <= de_instr; -- instruction register
                    em_reg_write_data <= de_reg_write_data;
                    em_reg_write_addr <= de_reg_write_addr;
                    em_reg_write_en <= de_reg_write_en;
                    em_reg_data_in_sel <= de_reg_data_in_sel;
                end if; -- not stalled

-- memory stage
                if memory_stalled = '0' then
                    mw_instr <= em_instr; -- instruction register
                    regfile_wr_en <= em_reg_write_en;
                    case em_reg_data_in_sel is
                    when x"1" =>
                        regfile_data_w <= em_reg_write_data;
                    when x"0" =>
                        regfile_data_w <= alu_result;
                    when others =>
                        regfile_data_w <= alu_result;
                    end case;
                    regfile_addr_w <= em_reg_write_addr;
                end if; -- not stalled
-- writeback stage

            end if;
        end if;
    end process;
end Behavioral;

