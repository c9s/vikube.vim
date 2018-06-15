fun! vikube#buffer#bottomright(...)
  let height = a:1
  if a:0 == 2
    exec 'botright ' . height . 'new ' . a:2
  elseif a:0 == 1
    exec 'botright ' . height . 'new'
    setlocal buftype=nofile 
  endif
  setlocal nobuflisted nowrap cursorline nonumber fdc=0 noswapfile
endf

fun! vikube#buffer#init_nofile()
  setlocal buftype=nofile nobuflisted cursorline nonumber fdc=0 nohidden nocursorline noswapfile
endf

fun! vikube#buffer#init()
  " set the display buffer mode
  setlocal noswapfile buftype=nofile bufhidden=wipe nobuflisted

  " set the visual look, disable the fold column and disable the text wrapping
  setlocal nowrap nonumber fdc=0 

  " enable the cursorline for selection
  setlocal cursorline
endf
