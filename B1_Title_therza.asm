; Therza intro variant derived from the original B1_Title.asm.
; First two C64 screen rows (40 cells each) are replaced; the remaining
; 920 cells are inherited byte-for-byte from the original title matrix.
;
; Row 1 centered: "A **THE RZA** PORT"
; Row 2: blank ($20 in all 40 cells).

TxtTitleScreen    .byte $20 ; leading blank 1
                  .byte $20 ; leading blank 2
                  .byte $20 ; leading blank 3
                  .byte $21 ; A left
                  .byte $55 ; A right
                  .byte $20 ; blank
                  .byte $74 ; * left
                  .byte $75 ; * right
                  .byte $74 ; * left
                  .byte $75 ; * right
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
                  .byte $74 ; * left
                  .byte $75 ; * right
                  .byte $74 ; * left
                  .byte $75 ; * right
                  .byte $20 ; blank
                  .byte $30 ; P left
                  .byte $64 ; P right
                  .byte $2f ; O left
                  .byte $63 ; O right
                  .byte $32 ; R left
                  .byte $66 ; R right
                  .byte $34 ; T left
                  .byte $68 ; T right
                  .byte $20 ; trailing blank 1
                  .byte $20 ; trailing blank 2
                  .byte $20 ; trailing blank 3
                  .byte $20 ; trailing blank 4

; Row 2: completely blank.
                  .byte $20
                  .byte $20
                  .byte $20
                  .byte $20
                  .byte $20
                  .byte $20
                  .byte $20
                  .byte $20
                  .byte $20
                  .byte $20
                  .byte $20
                  .byte $20
                  .byte $20
                  .byte $20
                  .byte $20
                  .byte $20
                  .byte $20
                  .byte $20
                  .byte $20
                  .byte $20
                  .byte $20
                  .byte $20
                  .byte $20
                  .byte $20
                  .byte $20
                  .byte $20
                  .byte $20
                  .byte $20
                  .byte $20
                  .byte $20
                  .byte $20
                  .byte $20
                  .byte $20
                  .byte $20
                  .byte $20
                  .byte $20
                  .byte $20
                  .byte $20
                  .byte $20
                  .byte $20

; @inherit-title-tail B1_Title.asm 80
