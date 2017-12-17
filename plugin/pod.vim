

let g:vikube_object_types = ["pod", "pvc", "pv", "statefulset", "deployment", "service", "serviceaccount"]

fun! s:source()
  let cmd = "kubectl get " . b:object
  if b:wide
    let cmd = cmd . " -o wide"
  endif
  if b:all_namespace
    let cmd = cmd . " --all-namespaces"
  endif
  return system(cmd . "| awk 'NR == 1; NR > 1 {print $0 | \"sort -b -k1\"}'")
endf

fun! s:header()
  return "Kubernetes object=" . b:object . " namespace=" . b:namespace . " wide=" . b:wide
endf

fun! s:help()
  cal g:Help.reg(s:header(),
    \" D     - Delete " . b:object . "\n" .
    \" u     - Update List\n" .
    \" w     - Toggle wide option\n" .
    \" s     - Describe " . b:object . "\n" .
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

fun! s:namespace(row)
  let fields = s:fields(a:row)
  if b:all_namespace
    return fields[0]
  else
    return b:namespace
  endif
endf

fun! s:key(row)
  let fields = s:fields(a:row)
  if b:all_namespace
    return fields[1]
  endif
  return fields[0]
endf

fun! s:handleUpdate()
  redraw | echomsg "Updating pod list ..."
  let b:source_changed = 1
  cal s:render()
endf

fun! s:handleDelete()
  let key = s:key(getline('.'))
  redraw | echomsg key

  let out = system('kubectl delete ' . b:object . ' ' . shellescape(key))
  redraw | echomsg split(out, "\n")[0]
  let b:source_changed = 1
  cal s:render()
endf

fun! s:handlePrevObjectType()
  let x = index(g:vikube_object_types, b:object)
  let x = x - 1
  if x < 0
    let x = len(g:vikube_object_types) - 1
  endif
  let b:object = g:vikube_object_types[x]

  let b:source_changed = 1
  cal s:render()
endf

fun! s:handleNextObjectType()
  let x = index(g:vikube_object_types, b:object)
  let x = x + 1
  if x >= len(g:vikube_object_types)
    let x = 0
  endif
  let b:object = g:vikube_object_types[x]

  let b:source_changed = 1
  cal s:render()
endf

fun! s:handleToggleAllNamepsace()
  if b:all_namespace == 1
    let b:all_namespace = 0
  else
    let b:all_namespace = 1
  endif

  let b:source_changed = 1
  cal s:render()
endf

fun! s:handleToggleWide()
  if b:wide == 1
    let b:wide = 0
  else
    let b:wide = 1
  endif

  let b:source_changed = 1
  cal s:render()
endf

fun! s:handleDescribe()
  let line = getline('.')
  let namespace = s:namespace(line)
  let key = s:key(line)
  redraw | echomsg key 
  let object = b:object
  let out = system('kubectl describe ' . object . ' --namespace=' . namespace . ' ' . key)
  botright new
  silent exec "file " . key
  setlocal noswapfile nobuflisted nowrap cursorline nonumber fdc=0
  setlocal buftype=nofile bufhidden=wipe
  setlocal modifiable
  silent put=out
  redraw
  silent normal ggdd
  silent exec "setfiletype kdescribe" . object
  setlocal nomodifiable

  nnoremap <script><buffer> q :q<CR>

  syn match Label +^\S.\{-}:+ 
  syn match Error +Error+ 
endf


fun! s:render()
  let save_cursor = getcurpos()

  setlocal modifiable
  redraw
  normal ggdG

  if b:source_changed || !exists('b:source_cache')
    let out = s:source()
    let b:source_cache = out
    let b:source_changed = 0
  else
    let out = b:source_cache
  endif

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
  let b:source_changed = 1
  let b:search_enabled = 0
  let b:search = ""
  let b:wide = 1
  let b:all_namespace = 0
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
  nnoremap <script><buffer> s     :cal <SID>handleDescribe()<CR>
  nnoremap <script><buffer> w     :cal <SID>handleToggleWide()<CR>
  nnoremap <script><buffer> a     :cal <SID>handleToggleAllNamepsace()<CR>
  nnoremap <script><buffer> ]]     :cal <SID>handleNextObjectType()<CR>
  nnoremap <script><buffer> [[     :cal <SID>handlePrevObjectType()<CR>

  syn match Comment +^#.*+ 
  syn match CurrentPod +^\*.*+
  hi link CurrentPod Identifier
endf

com! VikubePodList :cal s:Vikube("pod")
com! Vikube :cal s:Vikube("pod")

if exists("g:vikube_autoupdate")
  au! CursorHold VikubeExplorer :cal <SID>render()
endif
