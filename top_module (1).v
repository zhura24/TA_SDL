// ============================================================
// Modul 2: Structural (Top Module)
// Top Module menginstansiasi seluruh sub-module:
//   1. clock_divider     → Modul 3 (Clocking Function)
//   2. fsm_controller    → Modul 1,4,5 (Behavioral, D-FF, FSM)
//   3. seven_seg_decoder → Modul 1,2 (Data Flow, Reuse)
//
// 6 State FSM dengan RGB LED berbeda tiap state:
//   S_IDLE     (000) → LED OFF
//   S_CHECK    (001) → LED KUNING  (R+G)
//   S_WATER    (010) → LED BIRU    (B) + Pompa ON
//   S_RAIN     (011) → LED HIJAU   (G)
//   S_DRY_WAIT (100) → LED MERAH   (R)
//   S_DONE     (101) → LED MAGENTA (R+B)
// ============================================================

module top_module(
    // --- Clock ---
    input  wire clk,

    // --- Input Switches ---
    input  wire reset,
    input  wire enable,
    input  wire sensor_kering,
    input  wire sensor_hujan,

    // --- Output RGB LED ---
    output wire led_r,          // RGB LED Red   channel
    output wire led_g,          // RGB LED Green channel
    output wire led_b,          // RGB LED Blue  channel

    // --- Output 7-Segment ---
    output wire [6:0] seg,
    output wire dp,
    output wire [7:0] an
);

    // ========================================================
    // Wire Internal
    // ========================================================
    wire slow_clk;
    wire [2:0] state_bus;
    wire pompa_air_wire;

    // ========================================================
    // Modul 3: Instansiasi Clock Divider
    // ========================================================
    clock_divider u_clock_divider(
        .clk      (clk),
        .reset    (reset),
        .slow_clk (slow_clk)
    );

    // ========================================================
    // Modul 4 & 5: Instansiasi FSM Controller
    // ========================================================
    fsm_controller u_fsm(
        .slow_clk      (slow_clk),
        .reset         (reset),
        .enable        (enable),
        .sensor_kering (sensor_kering),
        .sensor_hujan  (sensor_hujan),
        .pompa_air     (pompa_air_wire),
        .led_r         (led_r),
        .led_g         (led_g),
        .led_b         (led_b),
        .state_out     (state_bus)
    );

    // ========================================================
    // Modul 1 & 2: Instansiasi 7-Segment Decoder
    // ========================================================
    seven_seg_decoder u_seven_seg(
        .state (state_bus),
        .seg   (seg),
        .an    (an)
    );

    // ========================================================
    // Decimal point selalu OFF (aktif rendah = 1)
    // ========================================================
    assign dp = 1'b1;

endmodule
