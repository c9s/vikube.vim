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

fun! vikube#buffer#init(...)
  if a:1  =~ '^v'
    let size = g:HyperGitBufferWidth
  else
    let size = g:HyperGitBufferHeight
  endif

  if a:0 == 2
    exec g:GitBufferDefaultPosition . ' ' . size . a:1 . ' ' . a:2
  elseif a:0 == 1
    exec g:GitBufferDefaultPosition . ' ' . size . a:1 
    setlocal buftype=nofile 
  endif
  setlocal nobuflisted nowrap cursorline nonumber fdc=0 noswapfile
endf
