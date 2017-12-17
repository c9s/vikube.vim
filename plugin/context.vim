fun! s:source()
  " return system("kubectl config get-contexts | awk 'NR == 1; NR > 1 {print $0 | \"sort -b -k2\"}'")
  return system("kubectl config get-contexts | awk 'NR == 1; NR > 1 {print $0 | \"sort -b -k2\"}'")
endf

fun! s:help()
  cal g:Help.reg("Kubernetes Contexts: kubectl config get-contexts",
    \" D - Delete Context\n" .
    \" R - Rename Context\n" .
    \" S - Switch Context\n" 
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

fun! s:handleDeleteContext()
  let key = s:key(getline('.'))
  redraw | echomsg key

  let out = system('kubectl config delete-context ' . shellescape(key))
  redraw | echomsg split(out, "\n")[0]
  cal s:render()
endf

fun! s:handleSwitchContext()
  let key = s:key(getline('.'))
  redraw | echomsg key

  let out = system('kubectl config use-context ' . shellescape(key))
  redraw | echomsg split(out, "\n")[0]
  cal s:render()
endf

fun! s:handleRenameContext()
  let key = s:key(getline('.'))

  cal inputsave()
  let newName = input('Context:', key)
  cal inputrestore()

  let out = system('kubectl config rename-context ' . shellescape(key) . ' ' . shellescape(newName))
  redraw | echomsg split(out, "\n")[0]
  cal s:render()
endf

fun! s:render()
  setlocal modifiable
  normal ggdG
  let out = s:source()
  put=out
  normal ggdd
  cal s:help()
  redraw
  set nomodifiable
endf

fun! s:VikubeContextList()
  tabnew
  silent file KContextList
  setlocal noswapfile  
  setlocal nobuflisted nowrap cursorline nonumber fdc=0 buftype=nofile bufhidden=wipe
  setlocal cursorline
  cal s:render()
  setfiletype kcontextlist

  " local bindings
  nnoremap <script><buffer> s     :cal <SID>handleSwitchContext()<CR>
  nnoremap <script><buffer> r     :cal <SID>handleRenameContext()<CR>
  nnoremap <script><buffer> D     :cal <SID>handleDeleteContext()<CR>

  syn match Comment +^#.*+ 
  syn match CurrentContext +^\*.*+
  hi link CurrentContext Identifier
endf
com! VikubeContextList :cal s:VikubeContextList()
