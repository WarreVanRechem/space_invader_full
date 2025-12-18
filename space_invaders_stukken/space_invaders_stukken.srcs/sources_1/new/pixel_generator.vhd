library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pixel_generator is
    Port (
        clk           : in STD_LOGIC;
        vidon         : in STD_LOGIC;
        hc            : in STD_LOGIC_VECTOR(9 downto 0);
        vc            : in STD_LOGIC_VECTOR(9 downto 0);
        -- ... (andere inputs blijven hetzelfde) ...
        player_x      : in integer range 0 to 639;
        enemy_x       : in STD_LOGIC_VECTOR(0 to 49);
        enemy_y       : in integer range 0 to 479;
        enemy_alive   : in STD_LOGIC_VECTOR(0 to 4);
        bullet_x      : in integer range 0 to 639;
        bullet_y      : in integer range 0 to 479;
        bullet_active : in STD_LOGIC;
        eb_x          : in integer range 0 to 639;
        eb_y          : in integer range 0 to 479;
        eb_active     : in STD_LOGIC;
        player_lives  : in integer range 0 to 4;
        game_over     : in STD_LOGIC;
        game_won      : in STD_LOGIC; -- NIEUWE INPUT
        vga_r         : out STD_LOGIC_VECTOR(3 downto 0);
        vga_g         : out STD_LOGIC_VECTOR(3 downto 0);
        vga_b         : out STD_LOGIC_VECTOR(3 downto 0)
    );
end pixel_generator;

architecture Behavioral of pixel_generator is
    -- ... (Constanten en sprites blijven hetzelfde) ...
    constant PLAYER_Y      : integer := 440;
    constant PLAYER_WIDTH  : integer := 32;
    constant PLAYER_HEIGHT : integer := 16;
    constant ENEMY_WIDTH   : integer := 16; 
    constant ENEMY_HEIGHT  : integer := 12;

    type enemy_x_array is array(0 to 4) of integer range 0 to 639;
    signal ex : enemy_x_array;

    -- (Sprites hier laten staan zoals ze waren)
    type alien_sprite_type is array(0 to 11) of STD_LOGIC_VECTOR(15 downto 0);
    constant alien_sprite : alien_sprite_type := (
        "0000111111110000","0001111111111000","0011111111111100",
        "0111100110011110","1111111111111111","1101111111111011",
        "1101111111111011","1111111111111111","0111100000111110",
        "0011110001111100","0001111111111000","0000011111100000");

    type ship_sprite_type is array(0 to 7) of STD_LOGIC_VECTOR(15 downto 0);
    constant ship_sprite : ship_sprite_type := (
        "0000000010000000","0000000111000000","0000001111100000",
        "0000011111110000","0000111111111000","0001111111111100",
        "0011111111111110","1111000000001111");

begin
    gen_unpack: for i in 0 to 4 generate
        ex(i) <= to_integer(unsigned(enemy_x(i*10 to i*10+9)));
    end generate;

    process(clk)
        variable h, v, sx, sy : integer;
        variable r,g,b : STD_LOGIC_VECTOR(3 downto 0);
    begin
        if rising_edge(clk) then
            h := to_integer(unsigned(hc));
            v := to_integer(unsigned(vc));
            
            -- Default Zwart
            r := "0000"; g := "0000"; b := "0000";

            if vidon = '1' then
                
                -- 1. WIN SCHERM (Hoogste prioriteit)
                if game_won = '1' then
                    -- GROEN VAK
                    if h >= 200 and h < 440 and v >= 220 and v < 260 then
                        r := "0000"; g := "1111"; b := "0000"; -- GROEN
                    end if;
                    
                -- 2. GAME OVER SCHERM
                elsif game_over = '1' then
                    -- ROOD VAK
                    if h >= 200 and h < 440 and v >= 220 and v < 260 then
                        r := "1111"; g := "0000"; b := "0000"; -- ROOD
                    end if;
                    
                else
                    -- 3. NORMALE GAMEPLAY (De rest van je code)
                    -- TEKEN SPELER
                    if h >= player_x and h < player_x + PLAYER_WIDTH and
                       v >= PLAYER_Y and v < PLAYER_Y + PLAYER_HEIGHT then
                        sx := (h - player_x) / 2;
                        sy := (v - PLAYER_Y) / 2;
                        if sy >= 0 and sy <= 7 and sx >= 0 and sx <= 15 then
                            if ship_sprite(sy)(15-sx) = '1' then
                                r := "0000"; g := "1111"; b := "0000";
                            end if;
                        end if;
                    end if;

                    -- TEKEN VIJANDEN
                    for i in 0 to 4 loop
                        if enemy_alive(i) = '1' and
                           h >= ex(i) and h < ex(i) + ENEMY_WIDTH and
                           v >= enemy_y and v < enemy_y + ENEMY_HEIGHT then
                            sx := h - ex(i);
                            sy := v - enemy_y;
                            if sy >= 0 and sy <= 11 and sx >= 0 and sx <= 15 then
                                if alien_sprite(sy)(15-sx) = '1' then
                                    r := "1111"; g := "0000"; b := "0000";
                                end if;
                            end if;
                        end if;
                    end loop;

                    -- KOGELS
                    if bullet_active = '1' and 
                       h >= bullet_x and h < bullet_x+4 and
                       v >= bullet_y and v < bullet_y+8 then
                        r := "1111"; g := "1111"; b := "0000";
                    end if;

                    -- VIJAND KOGELS
                    if eb_active = '1' and 
                       h >= eb_x and h < eb_x+4 and
                       v >= eb_y and v < eb_y+8 then
                        r := "1111"; g := "1111"; b := "1111";
                    end if;
                end if; -- End Game Won / Game Over check

                -- 4. LEVENS (Altijd zichtbaar)
                for i in 0 to 3 loop
                    if player_lives > i then
                        if h >= 590 and h < 590 + 16 and 
                           v >= (20 + i*20) and v < (20 + i*20) + 8 then
                            sy := v - (20 + i*20);
                            sx := h - 590;
                            if ship_sprite(sy)(15-sx) = '1' then
                                r := "0000"; g := "0000"; b := "1111";
                            end if;
                        end if;
                    end if;
                end loop;
            end if; -- vidon

            vga_r <= r; vga_g <= g; vga_b <= b;
        end if;
    end process;
end Behavioral;