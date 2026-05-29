// ============================================================
// Modul 1: Data Flow (assign statements untuk decoding)
// Modul 2: Sub-module yang dapat di-reuse (7-seg decoder)
// ============================================================
// Decoder 7-Segment untuk menampilkan inisial state (3-bit, 6 state):
//   S_IDLE     (3'b000) → 'I'  (Idle)
//   S_CHECK    (3'b001) → 'C'  (Check Sensor)
//   S_WATER    (3'b010) → 'A'  (Air = menyiram)
//   S_RAIN     (3'b011) → 'H'  (Hujan)
//   S_DRY_WAIT (3'b100) → 'E'  (Error / menunggu konfirmasi kering)
//   S_DONE     (3'b101) → 'd'  (Done)
//
// 7-Segment Common Anode (aktif rendah):
//   Segmen ON  = 0
//   Segmen OFF = 1
//
// Layout segmen:
//     aaa
//    f   b
//     ggg
//    e   c
//     ddd
//
// seg[6:0] = {g, f, e, d, c, b, a}
// ============================================================

module seven_seg_decoder(
    input  wire [2:0] state,
    output reg  [6:0] seg,    // Segmen {g,f,e,d,c,b,a}, aktif rendah
    output reg  [7:0] an      // Anode, aktif rendah (hanya AN0 aktif)
);

    always @(*) begin
        an = 8'b11111110;     // AN0=0 (aktif), AN7..AN1=1 (nonaktif)

        case (state)
            // 'I' : segmen e,f ON → 7'b1001111
            3'b000: seg = 7'b1001111;

            // 'C' : segmen a,d,e,f ON → 7'b1000110
            3'b001: seg = 7'b1000110;

            // 'A' : segmen a,b,c,e,f,g ON → 7'b0001000
            3'b010: seg = 7'b0001000;

            // 'H' : segmen b,c,e,f,g ON → 7'b0001001
            3'b011: seg = 7'b0001001;

            // 'E' : segmen a,d,e,f,g ON → 7'b0000110
            3'b100: seg = 7'b0000110;

            // 'd' : segmen b,c,d,e,g ON → 7'b0100001
            3'b101: seg = 7'b0100001;

            default: seg = 7'b1111111;  // Semua segmen OFF
        endcase
    end

endmodule
