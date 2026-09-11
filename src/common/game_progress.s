.include "platform.inc"

.import game_exit_open
.import game_player_x
.import game_player_y
.import game_player_alive

.export game_progress_tick
.export game_cave_complete
.export game_cave_time

; Cave 1 original header values.
CAVE1_TIME_SECONDS = 150
CAVE1_EXIT_X       = $26
CAVE1_EXIT_Y       = $12
FRAMES_PER_SECOND  = 60

.segment "BSS"
game_progress_initialized: .res 1
game_progress_frame:       .res 1
game_cave_complete:        .res 1
game_cave_time:            .res 1

.segment "CODE"

.proc game_progress_tick
    lda game_progress_initialized
    bne @initialized
    lda #1
    sta game_progress_initialized
    stz game_progress_frame
    stz game_cave_complete
    lda #CAVE1_TIME_SECONDS
    sta game_cave_time

@initialized:
    lda game_cave_complete
    bne @done

    ; The original open exit completes the cave when Rockford enters it.
    lda game_exit_open
    beq @count_time
    lda game_player_x
    cmp #CAVE1_EXIT_X
    bne @count_time
    lda game_player_y
    cmp #CAVE1_EXIT_Y
    bne @count_time
    lda #1
    sta game_cave_complete
    stz game_player_alive
    rts

@count_time:
    ; Cave 1 starts at $96 = 150 seconds. This is deliberately kept separate
    ; from the movement cadence so later timing calibration does not alter the
    ; cave clock.
    inc game_progress_frame
    lda game_progress_frame
    cmp #FRAMES_PER_SECOND
    bcc @done
    stz game_progress_frame

    lda game_cave_time
    beq @time_out
    dec game_cave_time
    bne @done

@time_out:
    ; Match the C64 game-state transition: zero time ends the current attempt.
    stz game_player_alive

@done:
    rts
.endproc
