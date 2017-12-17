fun! s:source()
  return system("kubectl get service | awk 'NR == 1; NR > 1 {print $0 | \"sort -b -k1\"}'")
endf

fun! s:help()
  cal g:Help.reg("Kubernetes Services:",
    \" D - Delete Service\n" .
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

fun! s:handleUpdate()
  redraw | echomsg "Updating service list ..."
  cal s:render()
endf

fun! s:handleDeleteService()
  let key = s:key(getline('.'))
  redraw | echomsg key

  let out = system('kubectl delete service ' . shellescape(key))
  redraw | echomsg split(out, "\n")[0]
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

fun! s:VikubeServiceList()
  tabnew
  silent file KServiceList
  setlocal noswapfile  
  setlocal nobuflisted nowrap cursorline nonumber fdc=0 buftype=nofile bufhidden=wipe
  setlocal cursorline
  setlocal updatetime=5000
  cal s:render()
  setfiletype kservicelist

  " local bindings
  nnoremap <script><buffer> D     :cal <SID>handleDeleteService()<CR>
  nnoremap <script><buffer> U     :cal <SID>handleUpdate()<CR>

  syn match Comment +^#.*+ 
  syn match CurrentService +^\*.*+
  hi link CurrentService Identifier
endf

com! VikubeServiceList :cal s:VikubeServiceList()

if exists("g:vikube_autoupdate")
  au! CursorHold KServiceList :cal <SID>render()
endif

" VikubeServiceList
nmap <leader>kv  :VikubeServiceList<CR>
