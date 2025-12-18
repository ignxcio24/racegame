----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.12.2025 18:08:47
-- Design Name: 
-- Module Name: carretera - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity carretera is
generic (
    ROAD_LENGTH: natural := 8;  -- Ahora son 8 displays (AN7 a AN0)
    segment : natural := 7    
);
Port ( 
    clk : in STD_LOGIC;
    rst : in STD_LOGIC;
    CE : in STD_LOGIC;
    modo_f: in STD_LOGIC;
    modo_m: in STD_LOGIC;
    modo_d: in STD_LOGIC;
    
    -- SALIDA de 56 BITS (8 displays * 7 segmentos)
    road: out std_logic_vector(55 downto 0); 
    s_toggle_out : out STD_LOGIC
);
end carretera;

architecture Behavioral of carretera is
    constant C_ROAD_LENGTH : natural := ROAD_LENGTH; -- 8
    constant C_SEGMENT : natural := segment;         -- 7
    
    -- 100MHz / 25,000,000 = 4Hz (Parpadea 4 veces por segundo)
    constant C_BLINK_LIMIT : natural := 25000000; 
    signal s_blink_counter : natural range 0 to C_BLINK_LIMIT := 0;
    subtype patron_seg is std_logic_vector(C_SEGMENT-1 downto 0);
    type road_dis is array (C_ROAD_LENGTH-1 downto 0) of patron_seg;
    
    signal s_road_array : road_dis := (others => (others => '0'));
    signal s_patron: patron_seg;
    signal s_lfsr : std_logic_vector(1 downto 0) := "10";
    signal s_feedback : std_logic;  
    signal s_toggle: std_logic := '0'; 
    
begin
    
    s_toggle_out <= s_toggle;
    

    with s_lfsr select
        s_patron <= 
            "0001001" when "01", -- izqda
            "1000001" when "10", -- centro
            "1001000" when "11", -- derecha
            "0000000" when others;
    process(s_road_array)
        variable temp_road : std_logic_vector(55 downto 0);
    begin
      for i in 0 to 7 loop
            temp_road((i*7)+6 downto i*7) := s_road_array(i);
        end loop;
        road <= temp_road;
    end process;
    -- CONCATENACIÓN DE LOS 56 BITS para la salida (D7 || D6 || ... || D0)
    -- Asumimos que D0 es s_road_array(0) (los bits 6:0) y D7 es s_road_array(7) (los bits 55:49)
   -- road <= s_road_array(7) & s_road_array(6) & s_road_array(5) & s_road_array(4) & 
         --   s_road_array(3) & s_road_array(2) & s_road_array(1) & s_road_array(0);
    

    process(clk, rst)
begin
    if rst = '0' then
        s_road_array <= (others => (others => '0'));
        s_lfsr <= "10";
        s_toggle <= '0';
        s_blink_counter <= 0;
        
    elsif rising_edge(clk) then
        
        -- LÓGICA DE PARPADEO INDEPENDIENTE (Siempre activa si modo_m = '1')
        if modo_m = '1' and modo_f = '0' and modo_d = '0' then
            if s_blink_counter = C_BLINK_LIMIT - 1 then
                s_blink_counter <= 0;
                s_toggle <= not s_toggle; -- Cambia el estado del parpadeo
            else
                s_blink_counter <= s_blink_counter + 1;
            end if;
        else
            s_toggle <= '0';
            s_blink_counter <= 0;
        end if;

        -- LÓGICA DE MOVIMIENTO (Solo ocurre cuando CE = '1')
        if CE = '1' then
            s_feedback <= s_lfsr(1) xor s_lfsr(0);
            s_lfsr <= s_feedback & s_lfsr(1);
            
            -- MODO NORMAL/PARPADEO
            if modo_f = '1' or modo_m = '1' then
                for i in 1 to C_ROAD_LENGTH-2 loop
                    s_road_array(i) <= s_road_array(i + 1);
                end loop;
                s_road_array(C_ROAD_LENGTH-1) <= s_patron;
            
            -- MODO ACORTADO
            elsif modo_d = '1' then 
                s_road_array(C_ROAD_LENGTH-3) <= s_road_array(C_ROAD_LENGTH-2); 
                s_road_array(C_ROAD_LENGTH-2) <= s_road_array(C_ROAD_LENGTH-1); 
                s_road_array(C_ROAD_LENGTH-1) <= s_patron; 
                for j in C_ROAD_LENGTH-4 to 0 loop 
                    s_road_array(j) <= (others=>'0');
                end loop;
            end if;
        end if;
    end if;
end process;
    
end Behavioral;
