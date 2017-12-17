fun! s:source()
  return system("kubectl get pods | awk 'NR == 1; NR > 1 {print $0 | \"sort -b -k1\"}'")
endf

fun! s:help()
  cal g:Help.reg("Kubernetes Pods:",
    \" D - Delete Pod\n" .
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
  redraw | echomsg "Updating pod list ..."
  cal s:render()
endf

fun! s:handleDeletePod()
  let key = s:key(getline('.'))
  redraw | echomsg key

  let out = system('kubectl delete pod ' . shellescape(key))
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
  call feedkeys("f\e")
  set nomodifiable
endf

fun! s:VikubePodList()
  tabnew
  silent file KPodList
  setlocal noswapfile  
  setlocal nobuflisted nowrap cursorline nonumber fdc=0 buftype=nofile bufhidden=wipe
  setlocal cursorline
  setlocal updatetime=5000
  cal s:render()
  setfiletype kpodlist

  " local bindings
  nnoremap <script><buffer> D     :cal <SID>handleDeletePod()<CR>
  nnoremap <script><buffer> U     :cal <SID>handleUpdate()<CR>

  syn match Comment +^#.*+ 
  syn match CurrentPod +^\*.*+
  hi link CurrentPod Identifier
endf

com! VikubePodList :cal s:VikubePodList()
au! CursorHold KPodList :cal <SID>render()

" VikubePodList
nmap <leader>kp  :VikubePodList<CR>
