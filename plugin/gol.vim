scriptencoding utf-8

command! GOL call conway#NewBoard()
command! GOLPause call conway#Pause()
command! GOLPlay call conway#Play()
command! GOLReset call conway#ResetState()
command! -nargs=1 GOLPattern call conway#PlacePattern(<f-args>)
