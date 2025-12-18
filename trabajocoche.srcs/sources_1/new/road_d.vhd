----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.12.2025 23:04:25
-- Design Name: 
-- Module Name: road_d - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package road_d is
    constant ROAD_LENGTH : natural := 7;
    constant SEGMENT: natural := 7;
    
    subtype patron_seg is std_logic_vector( 0 to SEGMENT-1);
    
    -- Definición del tipo de array global
    type road_dis is array ( 0 to ROAD_LENGTH-1) of patron_seg;
end road_d;

