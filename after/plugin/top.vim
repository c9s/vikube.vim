
fun! s:source()
  return system("kubectl top " . b:top_mode . " | awk 'NR == 1; NR > 1 {print $0 | \"sort -b -k1\"}'")
endf

fun! s:help()
  cal g:Help.reg("Kubernetes Top: " . b:top_mode,
    \" N - Show Nodes\n" .
    \" P - Show Pods\n" .
    \" U - Update List\n"
    \,1)
endf

fun! s:canonicalizeRow(row)
  return substitute(a:row, '^\*\?\s*' , '' , '')
endf

fun! s:fields(row)
  let matched = s:canonicalizeRow(a:row)
  return split(matched, '\s\+')
endf

fun! s:key(row)
  let fields = s:fields(a:row)
  return fields[0]
endf

fun! s:handleNodeMode()
  let b:top_mode = "nodes"
  cal s:render()
endf

fun! s:handlePodMode()
  let b:top_mode = "pods"
  cal s:render()
endf


fun! s:handleUpdate()
  redraw | echomsg "Updating ..."
  cal s:render()
endf

fun! s:render()
  let save_cursor = getcurpos()

  setlocal modifiable
  normal ggdG
  let out = s:source()
  put=out
  normal ggdd
  cal s:help()
  redraw

  call setpos('.', save_cursor)

  " trigger CursorHold event
  if exists("g:vikube_autoupdate")
    call feedkeys("f\e")
  endif
  set nomodifiable
endf

fun! s:VikubeTop()
  tabnew
  silent file KTop

  setlocal noswapfile  
  setlocal nobuflisted nowrap cursorline nonumber fdc=0 buftype=nofile bufhidden=wipe
  setlocal cursorline
  setlocal updatetime=5000

  let b:top_mode = "pods"
  cal s:render()
  setfiletype ktop

  " local bindings
  nnoremap <script><buffer> U     :cal <SID>handleUpdate()<CR>
  nnoremap <script><buffer> N     :cal <SID>handleNodeMode()<CR>
  nnoremap <script><buffer> P     :cal <SID>handlePodMode()<CR>

  syn match Comment +^#.*+ 
endf

com! VikubeTop :cal s:VikubeTop()

if exists("g:vikube_autoupdate")
  au! CursorHold KTopList :cal <SID>render()
endif

" VikubeTop
nmap <leader>kt  :VikubeTop<CR>

