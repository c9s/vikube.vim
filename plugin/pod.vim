fun! s:source()
  return system("kubectl get " . b:object . " -o wide | awk 'NR == 1; NR > 1 {print $0 | \"sort -b -k1\"}'")
endf

fun! s:help()
  cal g:Help.reg("Kubernetes object=" . b:object . " namespace=" . b:namespace,
    \" D     - Delete " . b:object . "\n" .
    \" u     - Update List\n" .
    \" d     - Describe " . b:object . "\n" .
    \" Enter - Describe " . b:object . "\n"
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

fun! s:handleDelete()
  let key = s:key(getline('.'))
  redraw | echomsg key

  let out = system('kubectl delete ' . b:object . ' ' . shellescape(key))
  redraw | echomsg split(out, "\n")[0]
  cal s:render()
endf

fun! s:handleDescribe()
  let key = s:key(getline('.'))
  redraw | echomsg key

  let out = system('kubectl describe ' . b:object . ' ' . key)
  botright new
  silent exec "file " . key
  setlocal noswapfile nobuflisted nowrap cursorline nonumber fdc=0
  setlocal buftype=nofile bufhidden=wipe
  setlocal modifiable
  silent put=out
  redraw
  silent normal ggdd
  silent exec "setfiletype kdescribe" . b:object
  setlocal nomodifiable

  nnoremap <script><buffer> q :q<CR>

  syn match Label +^\S.\{-}:+ 
  syn match Error +Error+ 
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

fun! s:Vikube(object)
  tabnew
  let b:namespace = "default"
  let b:object = a:object
  exec "silent file VikubeExplorer"
  setlocal noswapfile  
  setlocal nobuflisted nowrap cursorline nonumber fdc=0 buftype=nofile bufhidden=wipe
  setlocal cursorline
  setlocal updatetime=5000
  cal s:render()
  silent exec "setfiletype k" . b:object . "list"

  " local bindings
  nnoremap <script><buffer> D     :cal <SID>handleDelete()<CR>
  nnoremap <script><buffer> u     :cal <SID>handleUpdate()<CR>
  nnoremap <script><buffer> <CR>  :cal <SID>handleDescribe()<CR>
  nnoremap <script><buffer> d     :cal <SID>handleDescribe()<CR>

  syn match Comment +^#.*+ 
  syn match CurrentPod +^\*.*+
  hi link CurrentPod Identifier
endf

com! VikubePodList :cal s:Vikube("pod")
com! Vikube :cal s:Vikube("pod")

if exists("g:vikube_autoupdate")
  au! CursorHold VikubeExplorer :cal <SID>render()
endif
