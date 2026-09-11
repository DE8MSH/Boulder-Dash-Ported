.include "platform.inc"

.import game_exit_open
.import game_player_x
.import game_player_y
.import game_player_alive
.import game_video_dirty
.import game_flow_init
.import game_flow_lose_life
.import game_flow_add_time_bonus
.import game_game_over
.import platform_benchmark_reset
.import platform_benchmark_tick
.import platform_benchmark_show

.export game_progress_init
.export game_progress_tick
.export game_cave_complete
.export game_cave_time

CAVE1_TIME_SECONDS = 150
CAVE1_EXIT_X       = $26
CAVE1_EXIT_Y       = $12
FRAMES_PER_SECOND  = 60
DEATH_WAIT_FRAMES  = 60

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
    lda #CAVE1_TIME_SECONDS
    sta game_cave_time
    jsr platform_benchmark_reset
    rts
.endproc

.proc game_progress_init
    jsr game_flow_init
    jsr game_progress_reset_attempt
    rts
.endproc

.proc game_progress_tick
    lda game_game_over
    bne @done
    lda game_cave_complete
    bne @hold_result

    jsr platform_benchmark_tick

    lda game_player_alive
    bne @check_exit
    inc game_progress_death_wait
    lda game_progress_death_wait
    cmp #DEATH_WAIT_FRAMES
    bcc @done
    jsr game_flow_lose_life
    lda game_game_over
    bne @done
    jsr game_progress_reset_attempt
    rts

@check_exit:
    stz game_progress_death_wait

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
    sta game_video_dirty
    stz game_player_alive

    lda game_cave_time
    jsr game_flow_add_time_bonus
    stz game_cave_time
    jsr platform_benchmark_show
    rts

@hold_result:
    lda #1
    sta game_video_dirty
    jsr platform_benchmark_show
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
