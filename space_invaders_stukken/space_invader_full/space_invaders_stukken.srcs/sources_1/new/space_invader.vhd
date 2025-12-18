library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity space_invaders is
    Port (
        clk       : in  STD_LOGIC;
        reset     : in  STD_LOGIC;
        btn_left  : in  STD_LOGIC;
        btn_right : in  STD_LOGIC;
        btn_shoot : in  STD_LOGIC;
        hsync     : out STD_LOGIC;
        vsync     : out STD_LOGIC;
        vga_r     : out STD_LOGIC_VECTOR(3 downto 0);
        vga_g     : out STD_LOGIC_VECTOR(3 downto 0);
        vga_b     : out STD_LOGIC_VECTOR(3 downto 0)
    );
end space_invaders;

architecture Behavioral of space_invaders is

    -- Componenten
    component clk_wiz_0 port (
        clk_in1  : in  STD_LOGIC;
        reset    : in  STD_LOGIC;
        clk_out1 : out STD_LOGIC;
        locked   : out STD_LOGIC
    ); end component;

    component vga_sync port (
        clk, clr     : in  STD_LOGIC;
        hsync, vsync : out STD_LOGIC;
        hc, vc       : out STD_LOGIC_VECTOR(9 downto 0);
        vidon        : out STD_LOGIC
    ); end component;

    component debouncer port (
        clk, reset, btn_in : in  STD_LOGIC;
        btn_out            : out STD_LOGIC
    ); end component;

    component player_controller port (
        clk       : in  STD_LOGIC;
        reset     : in  STD_LOGIC;
        btn_left  : in  STD_LOGIC;
        btn_right : in  STD_LOGIC;
        player_x  : out integer range 0 to 639
    ); end component;

    component enemy_controller port (
        clk         : in  STD_LOGIC;
        reset       : in  STD_LOGIC;
        enemy_hit   : in  STD_LOGIC_VECTOR(0 to 4);
        enemy_x     : out STD_LOGIC_VECTOR(0 to 49);
        enemy_y     : out integer range 0 to 479;
        enemy_alive : out STD_LOGIC_VECTOR(0 to 4)
    ); end component;

    component bullet_controller port (
        clk           : in  STD_LOGIC;
        reset         : in  STD_LOGIC;
        btn_shoot     : in  STD_LOGIC;
        player_x      : in  integer range 0 to 639;
        enemy_x       : in  STD_LOGIC_VECTOR(0 to 49);
        enemy_y       : in  integer range 0 to 479;
        enemy_alive   : in  STD_LOGIC_VECTOR(0 to 4);
        bullet_x      : out integer range 0 to 639;
        bullet_y      : out integer range 0 to 479;
        bullet_active : out STD_LOGIC;
        enemy_hit     : out STD_LOGIC_VECTOR(0 to 4)
    ); end component;

    -- AANGEPASTE COMPONENT: Met collision input
    component enemy_bullet_controller port (
        clk                : in STD_LOGIC;
        reset              : in STD_LOGIC;
        enemy_alive        : in STD_LOGIC_VECTOR(0 to 4);
        enemy_x            : in STD_LOGIC_VECTOR(0 to 49);
        enemy_y            : in integer range 0 to 479;
        shoot_trigger      : in STD_LOGIC;
        collision_detected : in STD_LOGIC; -- NIEUW
        eb_x               : out integer range 0 to 639;
        eb_y               : out integer range 0 to 479;
        eb_active          : out STD_LOGIC
    ); end component;

    -- NIEUWE COMPONENT: Game Logic
    component game_logic_controller port (
        clk, reset         : in  STD_LOGIC;
        player_x           : in  integer range 0 to 639;
        enemy_alive        : in  STD_LOGIC_VECTOR(0 to 4);
        eb_x, eb_y         : in  integer range 0 to 639; 
        eb_active          : in  STD_LOGIC;
        shoot_trigger      : out STD_LOGIC;
        collision_detected : out STD_LOGIC;
        player_lives       : out integer range 0 to 4;
        game_over          : out STD_LOGIC
    ); end component;

    component pixel_generator port (
        clk                         : in STD_LOGIC;
        vidon                       : in STD_LOGIC;
        hc, vc                      : in STD_LOGIC_VECTOR(9 downto 0);
        player_x                    : in integer range 0 to 639;
        enemy_x                     : in STD_LOGIC_VECTOR(0 to 49);
        enemy_y                     : in integer range 0 to 479;
        enemy_alive                 : in STD_LOGIC_VECTOR(0 to 4);
        bullet_x                    : in integer range 0 to 639;
        bullet_y                    : in integer range 0 to 479;
        bullet_active               : in STD_LOGIC;
        eb_x                        : in integer range 0 to 639;
        eb_y                        : in integer range 0 to 479;
        eb_active                   : in STD_LOGIC;
        player_lives                : in integer range 0 to 4;
        game_over                   : in STD_LOGIC;
        vga_r, vga_g, vga_b         : out STD_LOGIC_VECTOR(3 downto 0)
    ); end component;

    -- Signalen
    signal clk_25mhz : STD_LOGIC;
    signal locked    : STD_LOGIC;
    signal sys_reset : STD_LOGIC;
    signal btn_l, btn_r, btn_s : STD_LOGIC;

    -- Coördinaten
    signal player_x    : integer range 0 to 639;
    signal enemy_x     : STD_LOGIC_VECTOR(0 to 49);
    signal enemy_y     : integer range 0 to 479;
    signal enemy_alive : STD_LOGIC_VECTOR(0 to 4);

    -- Bullets
    signal bullet_x, bullet_y : integer range 0 to 639;
    signal bullet_active      : STD_LOGIC;
    signal enemy_hit          : STD_LOGIC_VECTOR(0 to 4);

    signal eb_x, eb_y         : integer range 0 to 639;
    signal eb_active          : STD_LOGIC;
    
    -- Interconnects Game Logic -> Controllers
    signal shoot_trigger      : STD_LOGIC;
    signal eb_collision_ack   : STD_LOGIC; 
    
    signal player_lives       : integer range 0 to 4;
    signal game_over          : STD_LOGIC;
    
    signal hc, vc : STD_LOGIC_VECTOR(9 downto 0);
    signal vidon  : STD_LOGIC;

begin
    sys_reset <= reset or not locked;

    -- Instantiaties
    clk_wiz_inst : clk_wiz_0
        port map (clk_in1 => clk, reset => reset, clk_out1 => clk_25mhz, locked => locked);

    vga_sync_inst : vga_sync
        port map (clk => clk_25mhz, clr => sys_reset, hsync => hsync, vsync => vsync, hc => hc, vc => vc, vidon => vidon);

    deb_l : debouncer port map(clk_25mhz, sys_reset, btn_left,  btn_l);
    deb_r : debouncer port map(clk_25mhz, sys_reset, btn_right, btn_r);
    deb_s : debouncer port map(clk_25mhz, sys_reset, btn_shoot, btn_s);

    player_inst : player_controller
        port map (clk => clk_25mhz, reset => sys_reset, btn_left => btn_l, btn_right => btn_r, player_x => player_x);

    enemy_inst : enemy_controller
        port map (clk => clk_25mhz, reset => sys_reset, enemy_hit => enemy_hit,
                  enemy_x => enemy_x, enemy_y => enemy_y, enemy_alive => enemy_alive);

    bullet_inst : bullet_controller
        port map (
            clk => clk_25mhz, reset => sys_reset, btn_shoot => btn_s,
            player_x => player_x, enemy_x => enemy_x, enemy_y => enemy_y, enemy_alive => enemy_alive,
            bullet_x => bullet_x, bullet_y => bullet_y, bullet_active => bullet_active, enemy_hit => enemy_hit
        );

    -- NIEUWE GAME LOGIC
    game_logic_inst : game_logic_controller
        port map (
            clk                => clk_25mhz,
            reset              => sys_reset,
            player_x           => player_x,
            enemy_alive        => enemy_alive,
            eb_x               => eb_x,
            eb_y               => eb_y,
            eb_active          => eb_active,
            shoot_trigger      => shoot_trigger,     -- Output
            collision_detected => eb_collision_ack,  -- Output
            player_lives       => player_lives,      -- Output
            game_over          => game_over          -- Output
        );

    -- AANGEPASTE ENEMY BULLET CONTROLLER
    enemy_bullet_inst : enemy_bullet_controller
        port map (
            clk                => clk_25mhz, 
            reset              => sys_reset,
            enemy_alive        => enemy_alive, 
            enemy_x            => enemy_x, 
            enemy_y            => enemy_y,
            shoot_trigger      => shoot_trigger,     -- Input van Game Logic
            collision_detected => eb_collision_ack,  -- Input van Game Logic
            eb_x               => eb_x, 
            eb_y               => eb_y, 
            eb_active          => eb_active
        );

    pixel_inst : pixel_generator
        port map (
            clk => clk_25mhz, vidon => vidon, hc => hc, vc => vc,
            player_x => player_x, enemy_x => enemy_x, enemy_y => enemy_y, enemy_alive => enemy_alive,
            bullet_x => bullet_x, bullet_y => bullet_y, bullet_active => bullet_active,
            eb_x => eb_x, eb_y => eb_y, eb_active => eb_active,
            player_lives => player_lives, 
            game_over => game_over,
            vga_r => vga_r, vga_g => vga_g, vga_b => vga_b
        );

end Behavioral;