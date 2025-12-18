library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity enemy_bullet_controller is
    Port (
        clk                : in STD_LOGIC;
        reset              : in STD_LOGIC;
        enemy_alive        : in STD_LOGIC_VECTOR(0 to 4);
        enemy_x            : in STD_LOGIC_VECTOR(0 to 49);
        enemy_y            : in integer range 0 to 479;
        shoot_trigger      : in STD_LOGIC;
        collision_detected : in STD_LOGIC; 
        eb_x               : out integer range 0 to 639;
        eb_y               : out integer range 0 to 479;
        eb_active          : out STD_LOGIC
    );
end enemy_bullet_controller;

architecture Behavioral of enemy_bullet_controller is
    constant BULLET_W : integer := 4;
    constant SPEED    : integer := 3;
    
    type ex_array is array(0 to 4) of integer range 0 to 639;
    signal ex : ex_array;
    
    signal bx : integer range 0 to 639 := 0;
    signal by : integer range 0 to 500 := 0; 
    
    signal active : STD_LOGIC := '0';
    signal cnt    : unsigned(19 downto 0) := (others => '0');
    signal trigger_stored : STD_LOGIC := '0';

begin
    -- Unpack enemy x
    gen: for i in 0 to 4 generate
        ex(i) <= to_integer(unsigned(enemy_x(i*10 to i*10+9)));
    end generate;

    process(clk, reset)
        variable shooter : integer := 0;
        variable found   : boolean := false;
    begin
        if reset = '1' then
            bx <= 0; 
            by <= 0; 
            active <= '0'; 
            cnt <= (others => '0');
            trigger_stored <= '0';
            
        elsif rising_edge(clk) then
        
            -- 0. COLLISION CHECK (Hoogste prioriteit: zet kogel uit bij raak)
            if collision_detected = '1' then
                active <= '0';
            end if;
        
            -- 1. TRIGGER OPSLAAN
            if shoot_trigger = '1' and active = '0' then
                trigger_stored <= '1';
            end if;

            -- 2. GAME LOOP (Timer ~60Hz)
            cnt <= cnt + 1;
            if cnt = 416667 then 
                cnt <= (others => '0');
                
                -- Kogel Bewegen
                if active = '1' then
                    if by < 475 then 
                        by <= by + SPEED;
                    else
                        active <= '0'; -- Reset als hij beneden is
                        by <= 0;
                    end if;
                    
                -- Kogel Schieten
                elsif trigger_stored = '1' then
                    found := false;
                    for i in 4 downto 0 loop
                        if enemy_alive(i) = '1' and not found then
                            shooter := i;
                            found := true;
                        end if;
                    end loop;
                    
                    if found then
                        bx <= ex(shooter) + 8;
                        by <= enemy_y + 12;
                        active <= '1';
                        trigger_stored <= '0';
                    else
                        trigger_stored <= '0'; 
                    end if;
                end if;
                
            end if;
        end if;
    end process;

    eb_x <= bx;
    eb_y <= by when by < 479 else 479; 
    eb_active <= active;

end Behavioral;