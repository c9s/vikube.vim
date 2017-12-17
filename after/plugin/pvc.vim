let s:object_type = 'pvc'
let s:object_label = 'PersistentVolumeClaim'

fun! s:source()
  return system("kubectl get " . s:object_type . " | awk 'NR == 1; NR > 1 {print $0 | \"sort -b -k1\"}'")
endf

fun! s:help()
  cal g:Help.reg("Kubernetes " . s:object_label,
    \" D - Delete " . s:object_label . "\n" .
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
  redraw | echomsg "Updating ..."
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

fun! s:handleDelete()
  let key = s:key(getline('.'))
  redraw | echomsg key

  let out = system('kubectl delete ' . s:object_type . ' ' . shellescape(key))
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

fun! s:VikubePVCList()
  tabnew
  silent exec "silent file K" . s:object_label . "List"
  setlocal noswapfile  
  setlocal nobuflisted nowrap cursorline nonumber fdc=0 buftype=nofile bufhidden=wipe
  setlocal cursorline
  setlocal updatetime=5000
  cal s:render()
  exec 'setfiletype k' . s:object_type . 'list'

  " local bindings
  nnoremap <script><buffer> D     :cal <SID>handleDelete()<CR>
  nnoremap <script><buffer> U     :cal <SID>handleUpdate()<CR>
  nnoremap <script><buffer> <CR>  :cal <SID>handleDescribe()<CR>
  nnoremap <script><buffer> S     :cal <SID>handleDescribe()<CR>

  syn match Comment +^#.*+ 
  syn match CurrentPVC +^\*.*+
  hi link CurrentPVC Identifier
endf

com! VikubePVCList :cal s:VikubePVCList()

if exists("g:vikube_autoupdate")
  au! CursorHold KPVCList :cal <SID>render()
endif

" VikubePVCList
nmap <leader>kp  :VikubePVCList<CR>
