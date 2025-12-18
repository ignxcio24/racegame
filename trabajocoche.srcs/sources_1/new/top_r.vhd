----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.12.2025 23:30:38
-- Design Name: 
-- Module Name: top_r - structural
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

entity top_r is
    Port (
        clk         : in  STD_LOGIC;  
        rst         : in  STD_LOGIC;  
        
        modo_f      : in  STD_LOGIC;  
        modo_m      : in  STD_LOGIC;  
        modo_d      : in  STD_LOGIC;  
        CE          : in  STD_LOGIC;  -- Switch de Habilitación del Juego
        
        segments    : out STD_LOGIC_VECTOR(6 downto 0); 
        anodes      : out STD_LOGIC_VECTOR(7 downto 0)  
    );
end top_r;

architecture Structural of top_r is

    -- CONSTANTES
    constant CLK_DIV_COUNT : natural := 100000000; -- Para generar 1 Hz
    
    -- DECLARACIÓN DE COMPONENTES
    component carretera is
        generic (
            ROAD_LENGTH: natural := 8;
            segment : natural := 7    
        );
        Port (  
            clk : in STD_LOGIC; rst : in STD_LOGIC; CE : in STD_LOGIC;
            modo_f: in STD_LOGIC; modo_m: in STD_LOGIC; modo_d: in STD_LOGIC;
            road: out std_logic_vector(55 downto 0);
            s_toggle_out : out STD_LOGIC
        );
    end component;
    
    component mult_road is
        Port (
            CLK : in STD_LOGIC; RST : in STD_LOGIC;
            ROAD_ARRAY_IN : in STD_LOGIC_VECTOR(55 downto 0);
            SEGMENTS_OUT : out STD_LOGIC_VECTOR(6 downto 0);
            ANODES_OUT : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    -- =================================================================
    -- SEÑALES INTERNAS (Faltantes y Declaradas)
    -- =================================================================
    signal s_road_data_vector : STD_LOGIC_VECTOR(55 downto 0);
    signal s_blink_toggle     : STD_LOGIC;
    signal s_mux_segments     : STD_LOGIC_VECTOR(6 downto 0);
    signal s_mux_anodes       : STD_LOGIC_VECTOR(7 downto 0);
    
    -- SEÑALES DEL DIVISOR DE FRECUENCIA
    signal s_ce_counter       : natural range 0 to CLK_DIV_COUNT - 1 := 0; 
    signal s_game_ce_lento    : STD_LOGIC := '0'; -- El pulso lento para CE
    
begin
    
    -- =================================================================
    -- 1. LÓGICA: DIVISOR DE FRECUENCIA (Genera el pulso de 1Hz)
    -- =================================================================
    process(clk, rst)
    begin
        if rst = '0' then
            s_ce_counter <= 0;
            s_game_ce_lento <= '0';
        elsif rising_edge(clk) then
            if CE = '1' then -- El switch CE (J15) debe estar en '1' para iniciar el movimiento
                if s_ce_counter = CLK_DIV_COUNT - 1 then
                    s_ce_counter <= 0;
                    s_game_ce_lento <= '1'; -- Pulso de un ciclo
                else
                    s_ce_counter <= s_ce_counter + 1;
                    s_game_ce_lento <= '0'; 
                end if;
            else
                s_ce_counter <= 0;
                s_game_ce_lento <= '0';
            end if;
        end if;
    end process;

    -- =================================================================
    -- 2. INSTANCIACIÓN DE LA CARRETERA
    -- =================================================================
    Carretera_UUT : carretera
        Port map (
            clk          => clk,
            rst          => rst,
            CE           => s_game_ce_lento, -- ¡USA EL PULSO LENTO!
            modo_f       => modo_f,
            modo_m       => modo_m,
            modo_d       => modo_d,
            road         => s_road_data_vector,
            s_toggle_out => s_blink_toggle
        );

    -- =================================================================
    -- 3. INSTANCIACIÓN DEL MULTIPLEXOR
    -- =================================================================
    Mux_Controller_UUT : mult_road
        Port map (
            CLK             => clk,       
            RST             => rst,
            ROAD_ARRAY_IN   => s_road_data_vector, -- Entrada del vector de 56 bits
            SEGMENTS_OUT    => s_mux_segments,    
            ANODES_OUT      => s_mux_anodes       
        );

    -- =================================================================
    -- 4. LÓGICA DE SALIDA FINAL (Aplicación del Parpadeo)
    -- =================================================================
    -- Si MODO_M está activo y el toggle rápido está en '1', apaga todos los ánodos (pantalla negra).
    anodes <= (others => '1') when (s_blink_toggle = '1') else s_mux_anodes;
    -- Los segmentos siempre toman el patrón del multiplexor.
    segments <= s_mux_segments; 
    
end Structural;