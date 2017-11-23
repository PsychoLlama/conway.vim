scriptencoding utf8

function! s:get_cursor_position() abort
  let [l:buffer, l:line, l:col, l:off] = getpos('.')

  " Compensate for 0-based indexing.
  let l:col -= 1
  let l:line -= 1

  return [l:line, l:col]
endfunction

function! gol#toggle_cell() abort
  let [l:y, l:x] = s:get_cursor_position()
  let l:line_contents = getline('.')
  let l:should_be_alive = !gol#cell_is_alive(l:x, l:y, b:cells)
  let l:next_contents = split(l:line_contents, '\zs')
  let l:next_contents[l:x] = gol#get_char(l:should_be_alive)
  let l:cell_index = gol#format_index(l:x, l:y)
  if should_be_alive
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
      \     [1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1]
      \   ],
      \ }

function! s:position_pattern(pattern) abort
  let l:pattern = copy(a:pattern)
  let [l:y, l:x] = s:get_cursor_position()
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

function! s:apply_pattern(pattern, state) abort
  for l:key in keys(a:pattern)
    let a:state[l:key] = 1
  endfor
endfunction

function! gol#place_pattern(name) abort
  if !exists('s:patterns.' . a:name)
    echo "\nPattern '" . a:name . "' isn't defined."
    echo 'Perhaps you meant one of these?'
    echo '[' . join(keys(s:patterns), ', ') . ']'
    return
  endif

  let l:pattern = s:patterns[a:name]
  let l:positioned_pattern = s:position_pattern(l:pattern)
  let l:world_state = gol#to_world_state(l:positioned_pattern)
  call s:apply_pattern(l:world_state, b:cells)
  call gol#render_world(b:cells)
endfunction

function! gol#place_block_prompt() abort
  let l:pattern_name = input('Pattern: ')

  " Empty if the user presses <esc>
  if !empty(l:pattern_name)
    call gol#place_pattern(l:pattern_name)
  endif
endfunction

function! gol#to_world_state(cells) abort
  let l:state = {}

  let l:y = 0
  while l:y < len(a:cells)
    let l:row = a:cells[l:y]

    let l:x = 0
    while l:x < len(l:row)
      let l:alive = !!l:row[l:x]

      if l:alive
        let l:index = gol#format_index(l:x, l:y)
        let l:state[l:index] = l:alive
      endif

      let l:x += 1
    endwhile

    let l:y += 1
  endwhile

  return l:state
endfunction

function! gol#new_board() abort
  execute ':tabnew'
  setlocal listchars=
  let b:cells = {}
  let b:paused = 1

  call gol#render_world(b:cells)

  nnoremap <buffer><silent><space> :call gol#toggle_cell()<cr>
  nnoremap <buffer><silent>p :call gol#toggle_play_state()<cr>
  nnoremap <buffer><silent>a :call gol#place_block_prompt()<cr>
  nnoremap <buffer><silent>r :call gol#reset_state()<cr>
endfunction

function! gol#format_index(x, y) abort
  return a:x . ':' . a:y
endfunction

function! gol#cell_is_alive(x, y, state) abort
  let l:index = gol#format_index(a:x, a:y)
  return exists('a:state["' . l:index . '"]')
endfunction!

function! gol#get_live_neighbors(x, y, state) abort
  let l:sum = 0
  let l:indices = gol#get_neighbor_indices(a:x, a:y)

  for [l:x, l:y] in l:indices
    let l:sum += gol#cell_is_alive(l:x, l:y, a:state)
  endfor

  return l:sum
endfunction

function! gol#should_cell_live(x, y, state) abort
  let l:neighbors = gol#get_live_neighbors(a:x, a:y, a:state)

  if gol#cell_is_alive(a:x, a:y, a:state)
    return l:neighbors == 2 || l:neighbors == 3
  endif

  return l:neighbors == 3
endfunction

function! gol#get_neighbor_indices(x, y) abort
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

function! gol#generate_next_state(state) abort
  let l:new_state = {}
  let l:neighbors_to_check = {}

  for l:key in keys(a:state)
    let [l:x, l:y] = split(l:key, ':')

    if gol#should_cell_live(l:x, l:y, a:state)
      let l:new_state[l:key] = 1
    endif

    for [l:nx, l:ny] in gol#get_neighbor_indices(l:x, l:y)
      if gol#should_cell_live(l:nx, l:ny, a:state)
        let l:new_state[gol#format_index(l:nx, l:ny)] = 1
      endif
    endfor
  endfor

  return l:new_state
endfunction

function! gol#get_char(alive) abort
  return a:alive ? '*' : ' '
endfunction

function! gol#render_world(state) abort
  let l:height = winheight('$')
  let l:indices = range(0, &columns - 4)

  for l:index in range(1, l:height)
    let l:y = l:index - 1
    let l:row_chars = map(l:indices, {x -> gol#get_char(gol#cell_is_alive(x, l:y, a:state))})
    let l:row = join(l:row_chars, '')

    call setline(l:index, l:row)
  endfor
endfunction

function! gol#render_next_state() abort
  let l:next_state = gol#generate_next_state(b:cells)
  call gol#render_world(l:next_state)
  let l:changed = b:cells != l:next_state
  let b:cells = l:next_state

  return l:changed
endfunction

function! gol#render_loop(timer_id) abort
  " Window closed.
  if !exists('b:cells') || b:paused
    return
  endif

  if !gol#render_next_state()
    return
  endif

  call timer_start(10, funcref('gol#render_loop'))
endfunction

function! gol#pause() abort
  let b:paused = 1
endfunction

function! gol#play() abort
  let b:paused = 0
  call gol#render_loop(0)
endfunction

function! gol#toggle_play_state() abort
  if b:paused
    call gol#play()
  else
    call gol#pause()
  endif
endfunction

function! gol#reset_state() abort
  call gol#pause()
  let b:cells = {}
  call gol#render_world(b:cells)
endfunction

command! GOL call gol#new_board()
command! GOLPause call gol#pause()
command! GOLPlay call gol#play()
command! GOLReset call gol#reset_state()
command! -nargs=1 GOLPattern call gol#place_pattern(<f-args>)
