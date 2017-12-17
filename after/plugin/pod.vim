let s:object_type = 'pod'
let s:object_label = 'Pod'

fun! s:source()
  return system("kubectl get " . s:object_type . " -o wide | awk 'NR == 1; NR > 1 {print $0 | \"sort -b -k1\"}'")
endf

fun! s:help()
  cal g:Help.reg("Kubernetes " . s:object_label . ":",
    \" D     - Delete " . s:object_label . "\n" .
    \" U     - Update List\n" .
    \" S     - Describe " . s:object_label . "\n" .
    \" Enter - Describe " . s:object_label . "\n"
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

  let out = system('kubectl delete ' . s:object_type . ' ' . shellescape(key))
  redraw | echomsg split(out, "\n")[0]
  cal s:render()
endf

fun! s:handleDescribe()
  let key = s:key(getline('.'))
  redraw | echomsg key

  let out = system('kubectl describe ' . s:object_type . ' ' . key)
  botright new
  silent exec "file " . key
  setlocal noswapfile nobuflisted nowrap cursorline nonumber fdc=0
  setlocal buftype=nofile bufhidden=wipe
  setlocal modifiable
  silent put=out
  redraw
  silent normal ggdd
  silent exec "setfiletype kdescribe" . s:object_type
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

fun! s:VikubePodList()
  tabnew
  silent exec "silent file K" . s:object_label . "List"
  setlocal noswapfile  
  setlocal nobuflisted nowrap cursorline nonumber fdc=0 buftype=nofile bufhidden=wipe
  setlocal cursorline
  setlocal updatetime=5000
  cal s:render()
  silent exec "setfiletype k" . s:object_type . "list"

  " local bindings
  nnoremap <script><buffer> D     :cal <SID>handleDeletePod()<CR>
  nnoremap <script><buffer> U     :cal <SID>handleUpdate()<CR>
  nnoremap <script><buffer> <CR>  :cal <SID>handleDescribe()<CR>
  nnoremap <script><buffer> S     :cal <SID>handleDescribe()<CR>

  syn match Comment +^#.*+ 
  syn match CurrentPod +^\*.*+
  hi link CurrentPod Identifier
endf

com! VikubePodList :cal s:VikubePodList()

if exists("g:vikube_autoupdate")
  au! CursorHold KPodList :cal <SID>render()
endif

" VikubePodList
nmap <leader>ko  :VikubePodList<CR>
