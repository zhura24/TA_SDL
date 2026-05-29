// ============================================================
// Modul 1: Behavioral (FSM Next State Logic)
//           Data Flow  (assign untuk output logika)
// Modul 4: D-Flip-Flop (State Register dengan always posedge clk)
// Modul 5: Desain FSM Moore
// ============================================================
// FSM Moore: Output hanya bergantung pada current_state
//
// State Encoding (3-bit, 6 state):
//   S_IDLE     = 3'b000  → Pompa OFF, 7seg = 'I', LED = OFF
//   S_CHECK    = 3'b001  → Pompa OFF, 7seg = 'C', LED = KUNING (R+G)
//   S_WATER    = 3'b010  → Pompa ON,  7seg = 'A', LED = BIRU
//   S_RAIN     = 3'b011  → Pompa OFF, 7seg = 'H', LED = HIJAU
//   S_DRY_WAIT = 3'b100  → Pompa OFF, 7seg = 'E', LED = MERAH
//   S_DONE     = 3'b101  → Pompa OFF, 7seg = 'd', LED = MAGENTA (R+B)
// ============================================================

module fsm_controller(
    input  wire slow_clk,       // Clock 1 Hz dari clock_divider
    input  wire reset,          // Reset aktif tinggi (asinkron)
    input  wire enable,         // Switch Enable: 1 = sistem aktif
    input  wire sensor_kering,  // 1 = tanah kering, 0 = tanah basah
    input  wire sensor_hujan,   // 1 = hujan, 0 = tidak hujan
    output wire pompa_air,      // 1 = pompa menyala
    output wire led_r,          // RGB LED - Red
    output wire led_g,          // RGB LED - Green
    output wire led_b,          // RGB LED - Blue
    output wire [2:0] state_out // State saat ini untuk 7-seg decoder
);

    // --- Definisi State (Moore FSM, 3-bit) ---
    localparam S_IDLE     = 3'b000;
    localparam S_CHECK    = 3'b001;
    localparam S_WATER    = 3'b010;
    localparam S_RAIN     = 3'b011;
    localparam S_DRY_WAIT = 3'b100;
    localparam S_DONE     = 3'b101;

    reg [2:0] current_state;
    reg [2:0] next_state;

    // ============================================================
    // Modul 4: D-Flip-Flop (State Register)
    // Reset asinkron memastikan FSM langsung ke S_IDLE
    // ============================================================
    always @(posedge slow_clk or posedge reset) begin
        if (reset)
            current_state <= S_IDLE;
        else
            current_state <= next_state;
    end

    // ============================================================
    // Modul 1 (Behavioral) & Modul 5 (FSM): Next State Logic
    // ============================================================
    always @(*) begin
        case (current_state)

            // IDLE: Tunggu enable dinyalakan
            S_IDLE: begin
                if (enable)
                    next_state = S_CHECK;
                else
                    next_state = S_IDLE;
            end

            // CHECK: Baca kondisi sensor
            S_CHECK: begin
                if (!enable)
                    next_state = S_IDLE;
                else if (sensor_hujan)
                    next_state = S_RAIN;          // Ada hujan → ke RAIN
                else if (sensor_kering)
                    next_state = S_DRY_WAIT;      // Tanah kering → ke DRY_WAIT dulu
                else
                    next_state = S_DONE;          // Tanah basah, tidak hujan → DONE
            end

            // DRY_WAIT: Konfirmasi tanah benar-benar kering sebelum pompa menyala
            S_DRY_WAIT: begin
                if (!enable)
                    next_state = S_IDLE;
                else if (sensor_hujan)
                    next_state = S_RAIN;          // Tiba-tiba hujan → ke RAIN
                else if (sensor_kering)
                    next_state = S_WATER;         // Konfirmasi kering → nyalakan pompa
                else
                    next_state = S_DONE;          // Ternyata sudah basah → DONE
            end

            // WATER: Pompa menyiram
            S_WATER: begin
                if (!enable)
                    next_state = S_IDLE;
                else if (sensor_hujan)
                    next_state = S_RAIN;          // Hujan turun → matikan pompa ke RAIN
                else if (!sensor_kering)
                    next_state = S_DONE;          // Tanah sudah basah → DONE
                else
                    next_state = S_WATER;         // Masih kering → terus siram
            end

            // RAIN: Sedang hujan, pompa dilarang menyala
            S_RAIN: begin
                if (!enable)
                    next_state = S_IDLE;
                else if (!sensor_hujan)
                    next_state = S_CHECK;         // Hujan berhenti → kembali cek sensor
                else
                    next_state = S_RAIN;          // Masih hujan → tetap di RAIN
            end

            // DONE: Penyiraman selesai / kondisi normal
            S_DONE: begin
                if (!enable)
                    next_state = S_IDLE;
                else
                    next_state = S_CHECK;         // Kembali monitoring
            end

            default: next_state = S_IDLE;
        endcase
    end

    // ============================================================
    // Modul 1 (Data Flow): Output Logic (Moore)
    // Setiap state punya warna LED RGB berbeda
    //
    //   S_IDLE     (000) → LED OFF              (R=0, G=0, B=0)
    //   S_CHECK    (001) → KUNING               (R=1, G=1, B=0)
    //   S_WATER    (010) → BIRU   + Pompa ON    (R=0, G=0, B=1)
    //   S_RAIN     (011) → HIJAU                (R=0, G=1, B=0)
    //   S_DRY_WAIT (100) → MERAH                (R=1, G=0, B=0)
    //   S_DONE     (101) → MAGENTA              (R=1, G=0, B=1)
    // ============================================================
    assign pompa_air = (current_state == S_WATER) ? 1'b1 : 1'b0;

    assign led_r = (current_state == S_CHECK)    ? 1'b1 :
                   (current_state == S_DRY_WAIT) ? 1'b1 :
                   (current_state == S_DONE)     ? 1'b1 : 1'b0;

    assign led_g = (current_state == S_CHECK)    ? 1'b1 :
                   (current_state == S_RAIN)     ? 1'b1 : 1'b0;

    assign led_b = (current_state == S_WATER)    ? 1'b1 :
                   (current_state == S_DONE)     ? 1'b1 : 1'b0;

    assign state_out = current_state;

endmodule
