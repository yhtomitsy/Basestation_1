library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity tracker_top is
    generic (
        VERSION             : std_logic_vector(15 downto 0) := x"0001";
        NUMBER_OF_SENSORS   : integer:= 8);
    port (
        CLK_IN          : in    std_logic;
        RESET           : in    std_logic;
        D               : inout std_logic_vector(NUMBER_OF_SENSORS-1 downto 0);
        E               : inout std_logic_vector(NUMBER_OF_SENSORS-1 downto 0);
        UART_TX_PIN     : out   std_logic;
        LEDS            : out   std_logic_vector(7 downto 0));
end tracker_top;

architecture RTL of tracker_top is

    component tracker_pll is
    port (
        REFERENCECLK    : in  std_logic;
        RESET           : in  std_logic;
        PLLOUTCORE      : out std_logic;
        PLLOUTGLOBAL    : out std_logic);
    end component;

    component uart_tx
    generic (
        CLKS_PER_BIT    : std_logic_vector(8 downto 0) := "001101000");
    port (
        i_Clock         : in  std_logic;
        i_Tx_DV         : in  std_logic;
        i_Tx_Byte       : in  std_logic_vector(7 downto 0);
        o_Tx_Active     : out std_logic;
        o_Tx_Serial     : out std_logic;
        o_Tx_Done       : out std_logic);
    end component;

    component ts4231
    port (
        clk             : in    std_logic;
        rst             : in    std_logic;
        D               : inout std_logic;
        E               : inout std_logic;
        sensor_STATE    : out   std_logic_vector(2 downto 0);
        current_STATE   : out   std_logic_vector(3 downto 0));
    end component;

    component lighthouse_sensor
    generic (sensor_id : unsigned(9 downto 0):=(others => '0'));
    port (
        clk             : in std_logic; -- 50 MHz clock
        sensor          : in std_logic;    -- sensor INPUT
        duration_nskip_to_sweep: out unsigned(31 downto 0); -- duration NSKIP to SWEEP
        lighthouse_id   : out std_logic;    -- which lighthouse emitted the sweep
        axis            : out std_logic;                -- sweep x or y axis
        valid           : out std_logic;                -- is '1' if (300 * 50 < duration < 8000 * 50)
        combined_data   : out unsigned(31 downto 0);
        sync            : out std_logic; -- spikes on sync pulse of non-skipping lighthouse (used for triggering data transmission)
        led             : out std_logic;
        payload         : out std_logic_vector (263 downto 0);
        crc32           : out std_logic_vector (31 downto 0)
        -- combined data layout:
        -- bit 31        lighthouse_id
        -- bit 30        axis
        -- bit 29        valid
        -- bits 28:19  sensor_id
        -- bits 18:0    duration (divide by 50 to get microseconds)
    );
    end component;


    signal clk              : std_logic;
    signal tick_clk         : std_logic;

    type sensor_state_t     is array(0 to NUMBER_OF_SENSORS-1) of std_logic_vector(2 downto 0);
    type curren"001101000"t_state_t    is array(0 to NUMBER_OF_SENSORS-1) of std_logic_vector(3 downto 0);
    type combine_data_us_t  is array(0 to NUMBER_OF_SENSORS-1) of unsigned(31 downto 0);
    type combine_data_t     is array(0 to NUMBER_OF_SENSORS-1) of std_logic_vector(31 downto 0);

    signal sensor_state     : sensor_state_t;
    signal current_state    : current_state_t;
    signal combined_data    : combine_data_t;
    signal combined_data_us : combine_data_us_t;
    signal combined_data_d  : combine_data_t;

    signal sync             : std_logic_vector(NUMBER_OF_SENSORS-1 downto 0);
    signal sync_zeros       : std_logic_vector(NUMBER_OF_SENSORS-1 downto 0) := (others => '0');
    signal sync_all         : std_logic;
    signal sync_all_d       : std_logic;
    signal data_ready_pulse : std_logic;

    signal is_watch         : std_logic_vector(NUMBER_OF_SENSORS-1 downto 0);

    signal tx_data_valid    : std_logic;
    signal tx_data_valid_d  : std_logic;

    signal tx_done          : std_logic;

    signal sensor_count     : integer range 0 to NUMBER_OF_SENSORS;
    signal tx_count         : integer range 0 to 4;
    signal tx_byte          : std_logic_vector(7 downto 0);

    type state_type is ( S_WAIT_FOR_DATA,
                         S_START_SEND_DATA,
                         S_SEND_DATA_SENSOR,
                         S_SEND_DATA,
                         S_WAIT_SEND_DATA,
                         S_SEND_NEXT_DATA,
                         S_SEND_NEXT_SENSOR,
                         S_SEND_IDLE_LINE);

     signal state           : state_type;
     signal sensor_data     : std_logic_vector(NUMBER_OF_SENSORS-1 downto 0);

begin

    LEDS <= x"A5";

    tracker_pll_u : tracker_pll
    port map (
        REFERENCECLK    => CLK_IN,      -- 12MHz
        RESET           => RESET,
        PLLOUTCORE      => tick_clk,
        PLLOUTGLOBAL    => open
    );

    clk <= CLK_IN;

    SENSOR_GEN : for idx in 0 to 1 generate

        ts4231_u : ts4231
        port map (
            clk             => tick_clk,
            rst             => RESET,
            D               => D(idx),
            E               => E(idx),
            sensor_STATE    => sensor_state(idx),
            current_STATE   => current_state(idx)
        );

        is_watch(idx)   <= '1' when sensor_state(idx) = "001" else '0';
        sensor_data(idx)<= not(E(idx)) and is_watch(idx);

        -- Need to modify this module to tick clock of 1MHz (1us period)
        lighthouse_sensor_u : lighthouse_sensor
        generic map (
            sensor_id       => to_unsigned(idx, 10))
        port map (
            clk                     => tick_clk,
            sensor                  => sensor_data(idx),
            duration_nskip_to_sweep => open,
            lighthouse_id           => open,
            combined_data           => combined_data_us(idx),
            led                     => open,
            payload                 => open,
            crc32                   => open,
            sync                    => sync(idx)
        );

        combined_data(idx) <= std_logic_vector(combined_data_us(idx));

    end generate SENSOR_GEN;

    sync_all <= '1' when sync /= sync_zeros else '0';

    process (tick_clk) begin
        if rising_edge(tick_clk) then
            if sync_all = '1' then
                combined_data_d <= combined_data;
            end if;
        end if;
    end process;

    process (clk) begin
        if rising_edge(clk) then
            sync_all_d <= sync_all;
        end if;
    end process;

    -- Neg edge detect
    data_ready_pulse <= not(sync_all) and sync_all_d;

    -- TODO add more data
    -- Sensor ID
    -- AXIS
    process (clk) begin
        if rising_edge(clk) then
            case state is
                when S_WAIT_FOR_DATA =>
                    if data_ready_pulse = '1' then
                        state   <= S_START_SEND_DATA;
                    end if;

                when S_START_SEND_DATA =>
                    sensor_count<= 0;
                    state       <= S_SEND_DATA_SENSOR;

                when S_SEND_DATA_SENSOR =>
                    tx_count    <= 0;
                    state       <= S_SEND_DATA;

                when S_SEND_DATA =>
                    state    <= S_WAIT_SEND_DATA;

                when S_WAIT_SEND_DATA =>
                    if tx_done = '1' then
                        tx_count <= tx_count + 1; 
                        state    <= S_SEND_NEXT_DATA;
                    end if;

                when S_SEND_NEXT_DATA =>
                    if tx_count < 4  then
                        state   <= S_SEND_DATA;
                    else
                        state   <= S_SEND_NEXT_SENSOR;
                        sensor_count<= sensor_count + 1;
                    end if;

                when S_SEND_NEXT_SENSOR =>
                    if sensor_count < NUMBER_OF_SENSORS then
                        state   <= S_SEND_DATA_SENSOR;
                    else
                        state   <= S_SEND_IDLE_LINE;
                    end if;

                when S_SEND_IDLE_LINE =>
                    state       <= S_WAIT_FOR_DATA;

                when others =>
                    state       <= S_WAIT_FOR_DATA;
            end case;
        end if;
    end process;

    process (clk) begin
        if rising_edge(clk) then
            if state = S_SEND_DATA then
                tx_byte <= combined_data_d(sensor_count)((8*(tx_count+1))-1 downto 8*tx_count);
            elsif state = S_SEND_IDLE_LINE then
                tx_byte <= x"16"; -- Idle sync
            end if;
        end if;
    end process;
"001101000"
    tx_data_valid <= '1' when state = S_SEND_DATA or
                              state = S_SEND_IDLE_LINE else '0';

    process (clk) begin
        if rising_edge(clk) then
            tx_data_valid_d <= tx_data_valid;
        end if;
    end process;

    uart_tx_u : uart_tx
    generic map ( CLKS_PER_BIT => "001101000") -- Clock 12MHz
    port map (
        i_Clock     => clk,
        i_Tx_DV     => tx_data_valid_d,
        i_Tx_Byte   => tx_byte,
        o_Tx_Active => open,
        o_Tx_Serial => UART_TX_PIN,
        o_Tx_Done   => tx_done
    );

end RTL;
