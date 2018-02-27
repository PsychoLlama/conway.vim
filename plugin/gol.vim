scriptencoding utf-8

command! GOL call game_of_life#new_board()
command! GOLPause call game_of_life#pause()
command! GOLPlay call game_of_life#play()
command! GOLReset call game_of_life#reset_state()
command! -nargs=1 GOLPattern call game_of_life#place_pattern(<f-args>)
