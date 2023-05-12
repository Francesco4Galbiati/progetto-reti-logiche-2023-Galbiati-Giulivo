library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity project_reti_logiche is
    port(
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_start : in std_logic;
        i_w : in std_logic;
        
        o_z0 : out std_logic_vector(7 downto 0);
        o_z1 : out std_logic_vector(7 downto 0);
        o_z2 : out std_logic_vector(7 downto 0);
        o_z3 : out std_logic_vector(7 downto 0);
        o_done : out std_logic;

        o_mem_addr : out std_logic_vector(15 downto 0);
        i_mem_data : in std_logic_vector(7 downto 0);
        o_mem_we : out std_logic;
        o_mem_en : out std_logic
    );
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
    component datapath is
        port(
            i_clk: in std_logic;
            i_rst: in std_logic;
            i_w: in std_logic;
            r1_load0: in std_logic;
            r1_load1: in std_logic;
            sel1: in std_logic;
            r2_load: in std_logic;
            i_cln: in std_logic;
            data: in std_logic_vector(7 downto 0);
            rz0_load: in std_logic;
            rz1_load: in std_logic;
            rz2_load: in std_logic;
            rz3_load: in std_logic;
            
            channel: out std_logic_vector(1 downto 0);
            address: out std_logic_vector(15 downto 0);
            o_done: out std_logic;
            o_z0: out std_logic_vector(7 downto 0);
            o_z1: out std_logic_vector(7 downto 0);
            o_z2: out std_logic_vector(7 downto 0);
            o_z3: out std_logic_vector(7 downto 0)
        );
    end component;
    
    signal r1_load0 : std_logic;
    signal r1_load1 : std_logic;
    signal sel1 : std_logic;
    signal r2_load : std_logic;
    signal clean : std_logic;
    signal channel : std_logic_vector(1 downto 0);
    signal rz0_load: std_logic;
    signal rz1_load: std_logic;
    signal rz2_load: std_logic;
    signal rz3_load: std_logic;
    
    type state is (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9);
    signal curr_state, next_state: state;
    
    begin
        DATAPATH0: datapath port map(
            i_clk,
            i_rst,
            i_w,
            r1_load0,
            r1_load1,
            sel1,
            r2_load,
            clean,
            i_mem_data,
            rz0_load,
            rz1_load,
            rz2_load,
            rz3_load,
            channel,
            o_mem_addr,
            o_done,
            o_z0,
            o_z1,
            o_z2,
            o_z3
        );
        
    --reset  
    process(i_clk, i_rst)
        begin
            if(i_rst = '1') then
                curr_state <= S0;
            elsif(i_clk'event and i_clk = '1') then
                curr_state <= next_state;
            end if;
        end process;
    
    --delta
    process(curr_state, i_start)
        begin
            next_state <= curr_state;
            case curr_state is
                when S0 =>
                    if(i_start = '0') then
                        next_state <= S0;
                    else
                        next_state <= S1;
                    end if;
                when S1 =>
                    next_state <= S2;
                when S2 =>
                    if(i_start = '1') then
                        next_state <= S3;
                    else
                        next_state <= S4;
                    end if;
                when S3 =>
                    if(i_start = '1') then
                        next_state <= S3;
                    else
                        next_state <= S4;
                    end if;
                when S4 =>
                    next_state <= S5;
                when S5 =>
                    if(channel = "00") then
                        next_state <= S6;
                    elsif(channel = "01") then
                        next_state <= S7;
                    elsif(channel = "10") then
                        next_state <= S8;
                    elsif(channel = "11") then
                        next_state <= S9;
                    end if;
                when S6 =>
                    next_state <= S0;
                when S7 =>
                    next_state <= S0;
                when S8 =>
                    next_state <= S0;
                when S9 =>
                    next_state <= S0;
            end case;
        end process;
        
    --lambda
    process(curr_state)
        begin
            r1_load0 <= '0';
            r1_load1 <= '0';
            r2_load <= '0';
            clean <= '0';
            o_mem_en <= '0';
            o_mem_we <= '0';
            rz0_load <= '0';
            rz1_load <= '0';
            rz2_load <= '0';
            rz3_load <= '0';
            sel1 <= '0';
            
            case curr_state is
                when S0 =>
                    r1_load1 <= '1';
                when S1 =>
                    r1_load0 <= '1';
                when S2 =>
                    sel1 <= '1';
                when S3 =>
                    sel1 <= '1';
                    r2_load <= '1';
                when S4 =>
                when S5 =>    
                    o_mem_en <= '1';
                    clean <= '1';
                when S6 =>
                    rz0_load <= '1';
                when S7 =>
                    rz1_load <= '1';
                when S8 =>
                    rz2_load <= '1';
                when S9 =>
                    rz3_load <= '1';
            end case;
        end process;
end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Datapath

entity Datapath is
    port(
        i_clk: in std_logic;
        i_rst: in std_logic;
        i_w: in std_logic;
        r1_load0: in std_logic;
        r1_load1: in std_logic;
        sel1: in std_logic;
        r2_load: in std_logic;
        i_cln: in std_logic;
        data: in std_logic_vector(7 downto 0);
        rz0_load: in std_logic;
        rz1_load: in std_logic;
        rz2_load: in std_logic;
        rz3_load: in std_logic;
        
        channel: out std_logic_vector(1 downto 0);
        address: out std_logic_vector(15 downto 0);
        o_done: out std_logic;
        o_z0: out std_logic_vector(7 downto 0);
        o_z1: out std_logic_vector(7 downto 0);
        o_z2: out std_logic_vector(7 downto 0);
        o_z3: out std_logic_vector(7 downto 0)
    );
end Datapath;

architecture Behavioral of Datapath is
    signal o_reg1: std_logic_vector(1 downto 0);
    signal o_sel1_0: std_logic;
    signal o_sel1_1: std_logic;
    signal o_reg2: std_logic_vector(15 downto 0);
    signal o_conc: std_logic_vector(15 downto 0);
    signal i_regz0: std_logic_vector(7 downto 0);
    signal i_regz1: std_logic_vector(7 downto 0);
    signal i_regz2: std_logic_vector(7 downto 0);
    signal i_regz3: std_logic_vector(7 downto 0);
    signal o_regz0: std_logic_vector(7 downto 0);
    signal o_regz1: std_logic_vector(7 downto 0);
    signal o_regz2: std_logic_vector(7 downto 0);
    signal o_regz3: std_logic_vector(7 downto 0);
    signal sel_mux: std_logic;
    
    begin
    
        --demultiplexer 1
        o_sel1_0 <= i_w when sel1 = '0' else '0';
        o_sel1_1 <= i_w when sel1 = '1' else '0';
                    
        
        --registro 1
        process(i_clk, i_rst)
            begin
                if(i_rst = '1') then
                    o_reg1 <= "00";
                elsif(i_clk'event and i_clk = '1') then
                    if(r1_load1 = '1' and r1_load0 = '0') then
                        o_reg1(1) <= o_sel1_0;
                    elsif(r1_load1 = '0' and r1_load0 = '1') then
                        o_reg1(0) <= o_sel1_0;
                    elsif(r1_load1 = '1' and r1_load0 = '1') then
                        o_reg1 <= "XX";
                    end if;
                end if;
            end process;
        
        --channel
        channel <= o_reg1;
        
        --concatenatore
        process(i_clk, i_rst)
        begin
            if(i_rst = '1' or i_cln = '1') then
                o_conc <= "0000000000000000";
            elsif(i_clk'event and i_clk = '1') then
                o_conc <= o_conc(14 downto 0)&o_sel1_1;
            end if;
        end process;
        
        --registro 2
        process(i_clk, i_rst)
            begin
                if(i_rst = '1') then
                    o_reg2 <= "0000000000000000";
                elsif(i_clk'event and i_clk = '1') then
                    if(i_cln = '1') then
                        o_reg2 <= "0000000000000000";
                    end if;
                    if(r2_load = '1') then
                        o_reg2 <= o_conc;
                    end if;
                end if;
            end process;
        
        --address
        address <= o_reg2;
        
        --demultiplexer 2
        i_regz0 <= data when o_reg1 = "00" else "00000000";
        i_regz1 <= data when o_reg1 = "01" else "00000000";
        i_regz2 <= data when o_reg1 = "10" else "00000000";
        i_regz3 <= data when o_reg1 = "11" else "00000000";
        
        --registro z0
        process(i_clk, i_rst)
            begin 
                if(i_rst = '1') then
                    o_regz0 <= "00000000";
                elsif(i_clk'event and i_clk = '1') then
                    if(rz0_load = '1') then
                        o_regz0 <= i_regz0;
                    end if;
                end if;
            end process;
            
        --registro z1
        process(i_clk, i_rst)
            begin 
                if(i_rst = '1') then
                    o_regz1 <= "00000000";
                elsif(i_clk'event and i_clk = '1') then
                    if(rz1_load = '1') then
                        o_regz1 <= i_regz1;
                    end if;
                end if;
            end process;
        
        --registro z2
        process(i_clk, i_rst)
            begin 
                if(i_rst = '1') then
                    o_regz2 <= "00000000";
                elsif(i_clk'event and i_clk = '1') then
                    if(rz2_load = '1') then
                        o_regz2 <= i_regz2;
                    end if;
                end if;
            end process;
        
        --registro z3
        process(i_clk, i_rst)
            begin 
                if(i_rst = '1') then
                    o_regz3 <= "00000000";
                elsif(i_clk'event and i_clk = '1') then
                    if(rz3_load = '1') then
                        o_regz3 <= i_regz3;
                    end if;
                end if;
            end process;
            
        --sel_mex
        process(i_clk, i_rst)
            begin 
                if(i_clk'event and i_clk = '1') then
                    sel_mux <= '0';
                    if(rz0_load = '1' or rz1_load = '1' or rz2_load = '1' or rz3_load = '1') then
                        sel_mux <= '1';
                    end if;
                end if;
            end process;
        
        --done
        o_done <= sel_mux;
        
        --mux0
        o_z0 <= o_regz0 when sel_mux = '1' else
                "00000000";
                
        --mux1
        o_z1 <= o_regz1 when sel_mux = '1' else
                "00000000";
        
        --mux2
        o_z2 <= o_regz2 when sel_mux = '1' else
                "00000000";
        
        --mux3
        o_z3 <= o_regz3 when sel_mux = '1' else
                "00000000";

end Behavioral;