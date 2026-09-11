; Therza intro variant derived from the original B1_Title.asm.
; First C64 screen row (40 cells) is replaced; the remaining 960 cells
; are inherited byte-for-byte from the original title matrix.
;
; Centered text: "A THE RZA PORT"
; 7 blank cells left, 8 blank cells right.

TxtTitleScreen    .byte $20 ; blank 1
                  .byte $20 ; blank 2
                  .byte $20 ; blank 3
                  .byte $20 ; blank 4
                  .byte $20 ; blank 5
                  .byte $20 ; blank 6
                  .byte $20 ; blank 7
                  .byte $21 ; A left
                  .byte $55 ; A right
                  .byte $20 ; blank
                  .byte $34 ; T left
                  .byte $68 ; T right
                  .byte $28 ; H left
                  .byte $5c ; H right
                  .byte $25 ; E left
                  .byte $59 ; E right
                  .byte $20 ; blank
                  .byte $32 ; R left
                  .byte $66 ; R right
                  .byte $3a ; Z left
                  .byte $6e ; Z right
                  .byte $21 ; A left
                  .byte $55 ; A right
                  .byte $20 ; blank
                  .byte $30 ; P left
                  .byte $64 ; P right
                  .byte $2f ; O left
                  .byte $63 ; O right
                  .byte $32 ; R left
                  .byte $66 ; R right
                  .byte $34 ; T left
                  .byte $68 ; T right
                  .byte $20 ; blank 1
                  .byte $20 ; blank 2
                  .byte $20 ; blank 3
                  .byte $20 ; blank 4
                  .byte $20 ; blank 5
                  .byte $20 ; blank 6
                  .byte $20 ; blank 7
                  .byte $20 ; blank 8

; @inherit-title-tail B1_Title.asm 40
