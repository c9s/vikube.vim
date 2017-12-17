let s:object_type = 'node'
let s:object_label = 'Node'

fun! s:source()
  return system("kubectl get " . s:object_type . " -o wide | awk 'NR == 1; NR > 1 {print $0 | \"sort -b -k1\"}'")
endf

fun! s:help()
  cal g:Help.reg("Kubernetes " . s:object_label . ":",
    \" L - Label " . s:object_label . "\n" .
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

fun! s:handleLabel()
  let key = s:key(getline('.'))
  redraw | echomsg key

  cal inputsave()
  let labels = input('Label:', '')
  cal inputrestore()

  let out = system('kubectl label node ' . shellescape(key) . ' ' . labels)
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

fun! s:VikubeNodeList()
  tabnew
  silent file KNodeList
  setlocal noswapfile  
  setlocal nobuflisted nowrap cursorline nonumber fdc=0 buftype=nofile bufhidden=wipe
  setlocal cursorline
  setlocal updatetime=5000
  cal s:render()
  exec 'setfiletype k' . s:object_type . 'list'

  " local bindings
  nnoremap <script><buffer> L     :cal <SID>handleLabel()<CR>
  nnoremap <script><buffer> U     :cal <SID>handleUpdate()<CR>

  syn match Comment +^#.*+ 
endf

com! VikubeNodeList :cal s:VikubeNodeList()

if exists("g:vikube_autoupdate")
  au! CursorHold KNodeList :cal <SID>render()
endif

" VikubeNodeList
nmap <leader>kn  :VikubeNodeList<CR>
