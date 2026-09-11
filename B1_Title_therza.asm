; Therza intro variant derived from the original B1_Title.asm.
; First two C64 screen rows (40 cells each) are replaced; the remaining
; 920 cells are inherited byte-for-byte from the original title matrix.
;
; Row 1 centered: "A VERY FINE PORT BY"
; Row 2 centered: "* ** THE RZA ** *"

TxtTitleScreen    .byte $20 ; leading blank 1
                  .byte $20 ; leading blank 2
                  .byte $20 ; leading blank 3
                  .byte $21 ; A left
                  .byte $55 ; A right
                  .byte $20 ; blank
                  .byte $36 ; V left
                  .byte $6a ; V right
                  .byte $25 ; E left
                  .byte $59 ; E right
                  .byte $32 ; R left
                  .byte $66 ; R right
                  .byte $39 ; Y left
                  .byte $6d ; Y right
                  .byte $20 ; blank
                  .byte $26 ; F left
                  .byte $5a ; F right
                  .byte $29 ; I left
                  .byte $5d ; I right
                  .byte $2e ; N left
                  .byte $62 ; N right
                  .byte $25 ; E left
                  .byte $59 ; E right
                  .byte $20 ; blank
                  .byte $30 ; P left
                  .byte $64 ; P right
                  .byte $2f ; O left
                  .byte $63 ; O right
                  .byte $32 ; R left
                  .byte $66 ; R right
                  .byte $34 ; T left
                  .byte $68 ; T right
                  .byte $20 ; blank
                  .byte $22 ; B left
                  .byte $56 ; B right
                  .byte $39 ; Y left
                  .byte $6d ; Y right
                  .byte $20 ; trailing blank 1
                  .byte $20 ; trailing blank 2
                  .byte $20 ; trailing blank 3

; Row 2.
                  .byte $20 ; leading blank 1
                  .byte $20 ; leading blank 2
                  .byte $20 ; leading blank 3
                  .byte $20 ; leading blank 4
                  .byte $20 ; leading blank 5
                  .byte $74 ; * left
                  .byte $75 ; * right
                  .byte $20 ; blank
                  .byte $74 ; * left
                  .byte $75 ; * right
                  .byte $74 ; * left
                  .byte $75 ; * right
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
                  .byte $74 ; * left
                  .byte $75 ; * right
                  .byte $74 ; * left
                  .byte $75 ; * right
                  .byte $20 ; blank
                  .byte $74 ; * left
                  .byte $75 ; * right
                  .byte $20 ; trailing blank 1
                  .byte $20 ; trailing blank 2
                  .byte $20 ; trailing blank 3
                  .byte $20 ; trailing blank 4
                  .byte $20 ; trailing blank 5
                  .byte $20 ; trailing blank 6

; @inherit-title-tail B1_Title.asm 80
