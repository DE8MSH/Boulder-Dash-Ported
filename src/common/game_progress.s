.include "platform.inc"

.import game_exit_open
.import game_player_x
.import game_player_y
.import game_player_alive
.import game_video_dirty
.import game_pad_pressed
.import game_flow_init
.import game_flow_restart_game
.import game_flow_next_cave
.import game_flow_lose_life
.import game_flow_add_time_bonus
.import game_game_over
.import game_current_cave

.export game_progress_init
.export game_progress_tick
.export game_cave_complete
.export game_cave_time

CAVE123_TIME_SECONDS = 150
CAVE4_TIME_SECONDS   = 120
CAVE1_EXIT_X      = $26
CAVE1_EXIT_Y      = $12
CAVE2_EXIT_X      = $12
CAVE2_EXIT_Y      = $16
CAVE3_EXIT_X      = $27
CAVE3_EXIT_Y      = $14
CAVE4_EXIT_X      = $26
CAVE4_EXIT_Y      = $16
FRAMES_PER_SECOND = 60
DEATH_WAIT_FRAMES = 60

.segment "BSS"
game_progress_frame:      .res 1
game_progress_death_wait: .res 1
game_cave_complete:       .res 1
game_cave_time:           .res 1

.segment "CODE"

.proc game_progress_reset_attempt
    stz game_progress_frame
    stz game_progress_death_wait
    stz game_cave_complete
    lda game_current_cave
    cmp #4
    bne :+
    lda #CAVE4_TIME_SECONDS
    bra @store_time
:
    lda #CAVE123_TIME_SECONDS
@store_time:
    sta game_cave_time
    rts
.endproc

.proc game_progress_init
    jsr game_flow_init
    jsr game_progress_reset_attempt
    rts
.endproc

.proc game_progress_tick
    lda game_game_over
    beq @not_game_over

    lda game_pad_pressed
    and #PAD_START
    bne :+
    jmp @done
:
    jsr game_flow_restart_game
    jsr game_progress_reset_attempt
    rts

@not_game_over:
    lda game_cave_complete
    beq :+
    jmp @hold_result
:

    lda game_player_alive
    bne @check_exit
    inc game_progress_death_wait
    lda game_progress_death_wait
    cmp #DEATH_WAIT_FRAMES
    bcs :+
    jmp @done
:
    jsr game_flow_lose_life
    lda game_game_over
    beq :+
    jmp @done
:
    jsr game_progress_reset_attempt
    rts

@check_exit:
    stz game_progress_death_wait
    lda game_exit_open
    bne :+
    jmp @count_time
:

    lda game_current_cave
    cmp #2
    beq @check_cave2_exit
    cmp #3
    beq @check_cave3_exit
    cmp #4
    beq @check_cave4_exit

    lda game_player_x
    cmp #CAVE1_EXIT_X
    beq :+
    jmp @count_time
:
    lda game_player_y
    cmp #CAVE1_EXIT_Y
    beq :+
    jmp @count_time
:
    jmp @cave_finished

@check_cave2_exit:
    lda game_player_x
    cmp #CAVE2_EXIT_X
    beq :+
    jmp @count_time
:
    lda game_player_y
    cmp #CAVE2_EXIT_Y
    beq :+
    jmp @count_time
:
    jmp @cave_finished

@check_cave3_exit:
    lda game_player_x
    cmp #CAVE3_EXIT_X
    beq :+
    jmp @count_time
:
    lda game_player_y
    cmp #CAVE3_EXIT_Y
    beq :+
    jmp @count_time
:
    jmp @cave_finished

@check_cave4_exit:
    lda game_player_x
    cmp #CAVE4_EXIT_X
    beq :+
    jmp @count_time
:
    lda game_player_y
    cmp #CAVE4_EXIT_Y
    beq :+
    jmp @count_time
:

@cave_finished:
    lda game_cave_time
    jsr game_flow_add_time_bonus
    stz game_cave_time

    lda game_current_cave
    cmp #4
    bcs @final_hold

    jsr game_flow_next_cave
    jsr game_progress_reset_attempt
    rts

@final_hold:
    lda #1
    sta game_cave_complete
    sta game_video_dirty
    stz game_player_alive
    rts

@hold_result:
    rts

@count_time:
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
    stz game_player_alive
    stz game_progress_death_wait

@done:
    rts
.endproc
