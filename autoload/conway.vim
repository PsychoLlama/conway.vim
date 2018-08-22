function! s:GetCursorPosition() abort
  let [l:buffer, l:line, l:col, l:off] = getpos('.')

  " Compensate for 0-based indexing.
  let l:col -= 1
  let l:line -= 1

  return [l:line, l:col]
endfunction

function! conway#ToggleCell() abort
  let [l:y, l:x] = s:GetCursorPosition()
  let l:line_contents = getline('.')
  let l:should_be_alive = !conway#CellIsAlive(l:x, l:y, b:cells)
  let l:next_contents = split(l:line_contents, '\zs')
  let l:next_contents[l:x] = conway#GetChar(l:should_be_alive)
  let l:cell_index = conway#FormatIndex(l:x, l:y)
  if l:should_be_alive
    let b:cells[l:cell_index] = l:should_be_alive
  else
    call remove(b:cells, l:cell_index)
  endif

  " Line numbers start at 1.
  call setline(l:y + 1, join(l:next_contents, ''))
endfunction

let s:patterns = {
      \   'glider': [
      \     [0, 0, 1],
      \     [1, 0, 1],
      \     [0, 1, 1],
      \   ],
      \   'blinker': [
      \     [0, 1],
      \     [0, 1],
      \     [0, 1],
      \   ],
      \   'toad': [
      \     [0, 1, 1, 1],
      \     [1, 1, 1, 0],
      \   ],
      \   'spaceship': [
      \     [0, 1, 1, 1, 1],
      \     [1, 0, 0, 0, 1],
      \     [0, 0, 0, 0, 1],
      \     [1, 0, 0, 1, 0],
      \   ],
      \   'beacon': [
      \     [1, 1, 0, 0],
      \     [1, 0, 0, 0],
      \     [0, 0, 0, 1],
      \     [0, 0, 1, 1],
      \   ],
      \   'pulsar': [
      \     [0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0],
      \     [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      \     [1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1],
      \     [1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1],
      \     [1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1],
      \     [0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0],
      \     [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      \     [0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0],
      \     [1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1],
      \     [1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1],
      \     [1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1],
      \     [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      \     [0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0],
      \   ],
      \   'pentadecathlon': [
      \     [0, 1, 0],
      \     [0, 1, 0],
      \     [1, 0, 1],
      \     [0, 1, 0],
      \     [0, 1, 0],
      \     [0, 1, 0],
      \     [0, 1, 0],
      \     [1, 0, 1],
      \     [0, 1, 0],
      \     [0, 1, 0],
      \   ],
      \   'block': [
      \     [1, 1],
      \     [1, 1],
      \   ],
      \   'beehive': [
      \     [0, 1, 1, 0],
      \     [1, 0, 0, 1],
      \     [0, 1, 1, 0],
      \   ],
      \   'loaf': [
      \     [0, 1, 1, 0],
      \     [1, 0, 0, 1],
      \     [0, 1, 0, 1],
      \     [0, 0, 1, 0],
      \   ],
      \   'boat': [
      \     [1, 1, 0],
      \     [1, 0, 1],
      \     [0, 1, 0],
      \   ],
      \   'tub': [
      \     [0, 1, 0],
      \     [1, 0, 1],
      \     [0, 1, 0],
      \   ],
      \   'acorn': [
      \     [0, 1, 0, 0, 0, 0, 0],
      \     [0, 0, 0, 1, 0, 0, 0],
      \     [1, 1, 0, 0, 1, 1, 1],
      \   ],
      \   'pentomeno': [
      \     [0, 1, 1],
      \     [1, 1, 0],
      \     [0, 1, 1],
      \   ],
      \   'diehard': [
      \     [0, 0, 0, 0, 0, 0, 1, 0],
      \     [1, 1, 0, 0, 0, 0, 0, 0],
      \     [0, 1, 0, 0, 0, 1, 1, 1],
      \   ],
      \   'line': [
      \     [
      \       1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1,
      \       0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1,
      \     ]
      \   ],
      \   'gosper': [
      \     [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      \     [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      \     [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1],
      \     [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1],
      \     [1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      \     [1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      \     [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      \     [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      \     [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      \   ],
      \ }

function! s:PositionPattern(pattern) abort
  let l:pattern = copy(a:pattern)
  let [l:y, l:x] = s:GetCursorPosition()
  let l:x_prefix = map(range(l:x), {-> 0})
  let l:y_prefix = map(range(l:y), {-> []})

  let l:line_index = 0
  while l:line_index < len(l:pattern)
    let l:row = l:pattern[l:line_index]
    let l:pattern[l:line_index] = l:x_prefix + l:row
    let l:line_index += 1
  endwhile

  return l:y_prefix + l:pattern
endfunction

function! s:ApplyPattern(pattern, state) abort
  for l:key in keys(a:pattern)
    let a:state[l:key] = 1
  endfor
endfunction

function! conway#PlacePattern(name) abort
  if !exists('s:patterns.' . a:name)
    echo "\nPattern '" . a:name . "' isn't defined."
    echo 'Perhaps you meant one of these?'
    echo '[' . join(keys(s:patterns), ', ') . ']'
    return
  endif

  let l:pattern = s:patterns[a:name]
  let l:positioned_pattern = s:PositionPattern(l:pattern)
  let l:world_state = conway#ToWorldState(l:positioned_pattern)
  call s:ApplyPattern(l:world_state, b:cells)
  call conway#RenderWorld(b:cells)
endfunction

function! conway#PlaceBlockPrompt() abort
  let l:pattern_name = input("Insert pattern name\n> ")

  " Empty if the user presses <esc>
  if !empty(l:pattern_name)
    call conway#PlacePattern(l:pattern_name)
  endif
endfunction

function! conway#ToWorldState(cells) abort
  let l:state = {}

  let l:y = 0
  while l:y < len(a:cells)
    let l:row = a:cells[l:y]

    let l:x = 0
    while l:x < len(l:row)
      let l:alive = !!l:row[l:x]

      if l:alive
        let l:index = conway#FormatIndex(l:x, l:y)
        let l:state[l:index] = l:alive
      endif

      let l:x += 1
    endwhile

    let l:y += 1
  endwhile

  return l:state
endfunction

function! conway#NewBoard() abort
  tabnew Game of Life

  setlocal buftype=nowrite bufhidden=delete signcolumn=no
  setlocal listchars= nowriteany nobuflisted nonumber
  let b:cells = {}
  let b:paused = 1

  call conway#RenderWorld(b:cells)

  nnoremap <buffer><silent><space> :call conway#ToggleCell()<cr>
  nnoremap <buffer><silent>p :call conway#TogglePlayState()<cr>
  nnoremap <buffer><silent>a :call conway#PlaceBlockPrompt()<cr>
  nnoremap <buffer><silent>i :call conway#PlaceBlockPrompt()<cr>
  nnoremap <buffer><silent>r :call conway#ResetState()<cr>

  if exists('&signcolumn')
    setlocal signcolumn=no
  endif
endfunction

function! conway#FormatIndex(x, y) abort
  return a:x . ':' . a:y
endfunction

function! conway#CellIsAlive(x, y, state) abort
  let l:index = conway#FormatIndex(a:x, a:y)
  return exists('a:state["' . l:index . '"]')
endfunction!

function! conway#GetLiveNeighbors(x, y, state) abort
  let l:sum = 0
  let l:indices = conway#GetNeighborIndices(a:x, a:y)

  for [l:x, l:y] in l:indices
    let l:sum += conway#CellIsAlive(l:x, l:y, a:state)
  endfor

  return l:sum
endfunction

function! conway#ShouldCellLive(x, y, state) abort
  let l:neighbors = conway#GetLiveNeighbors(a:x, a:y, a:state)

  if conway#CellIsAlive(a:x, a:y, a:state)
    return l:neighbors == 2 || l:neighbors == 3
  endif

  return l:neighbors == 3
endfunction

function! conway#GetNeighborIndices(x, y) abort
  let l:indices = []

  let l:y = a:y - 1
  while l:y <= a:y + 1

    let l:x = a:x - 1
    while l:x <= a:x + 1
      if l:x != a:x || l:y != a:y
        let l:indices += [[l:x, l:y]]
      endif

      let l:x += 1
    endwhile

    let l:y += 1
  endwhile

  return l:indices
endfunction

function! conway#GenerateNextState(state) abort
  let l:new_state = {}
  let l:neighbors_to_check = {}

  for l:key in keys(a:state)
    let [l:x, l:y] = split(l:key, ':')

    if conway#ShouldCellLive(l:x, l:y, a:state)
      let l:new_state[l:key] = 1
    endif

    for [l:nx, l:ny] in conway#GetNeighborIndices(l:x, l:y)
      if conway#ShouldCellLive(l:nx, l:ny, a:state)
        let l:new_state[conway#FormatIndex(l:nx, l:ny)] = 1
      endif
    endfor
  endfor

  return l:new_state
endfunction

function! conway#GetChar(alive) abort
  return a:alive ? '#' : ' '
endfunction

function! conway#RenderWorld(state) abort
  let l:height = winheight('$')
  let l:indices = range(0, &columns - 4)

  for l:index in range(1, l:height)
    let l:y = l:index - 1
    let l:row_chars = map(l:indices, {x -> conway#GetChar(conway#CellIsAlive(x, l:y, a:state))})
    let l:row = join(l:row_chars, '')

    call setline(l:index, l:row)
  endfor
endfunction

function! conway#RenderNextState() abort
  let l:next_state = conway#GenerateNextState(b:cells)
  call conway#RenderWorld(l:next_state)
  let l:changed = b:cells != l:next_state
  let b:cells = l:next_state

  return l:changed
endfunction

function! conway#RenderLoop(timer_id) abort
  " Window closed.
  if !exists('b:cells') || b:paused
    return
  endif

  if !conway#RenderNextState()
    return
  endif

  call timer_start(10, funcref('conway#RenderLoop'))
endfunction

function! conway#Pause() abort
  let b:paused = 1
endfunction

function! conway#Play() abort
  let b:paused = 0
  call conway#RenderLoop(0)
endfunction

function! conway#TogglePlayState() abort
  if b:paused
    call conway#Play()
  else
    call conway#Pause()
  endif
endfunction

function! conway#ResetState() abort
  call conway#Pause()
  let b:cells = {}
  call conway#RenderWorld(b:cells)
endfunction
