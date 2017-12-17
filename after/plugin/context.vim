fun! s:GitBranchListRefresh()
  setlocal modifiable
  1,$delete _
  let list = system('git branch')
  put=list
  normal ggdd
  setlocal nomodifiable
endf

fun! g:GitListRemote(A,L,P)
  return system('git remote')
endf

fun! s:promptRemote()
  cal inputsave()
  let remote = input('Remote:','','custom,GitListRemote')
  cal inputrestore()
  return remote
endf
" echo s:promptRemote()

fun! s:getRemoteName()
  let remotes =  split(GitListRemote('','',''))
  if len( remotes ) == 1
    return remotes[0]
  else
    return s:promptRemote()
  endif
endf
" echo s:getRemoteName()

fun! s:branchPull()
  let br = s:getSelectedBranchName()
  let remote = s:getRemoteName()
  exec printf('!git pull %s %s',remote,br)
endf

fun! s:branchPush()
  let br = s:getSelectedBranchName()
  let remote = s:getRemoteName()
  exec printf('!git push %s %s',remote,br)
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

  let out = system('kubectl config delete-context ' . key)
  redraw | echomsg split(out, "\n")[0]
  cal s:render()
endf

fun! s:handleSwitchContext()
  let key = s:key(getline('.'))
  redraw | echomsg key

  let out = system('kubectl config use-context ' . key)
  redraw | echomsg split(out, "\n")[0]
  cal s:render()
endf

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

fun! s:KubeContextList()
  tabnew
  silent file KubeContexts
  setlocal noswapfile  
  setlocal nobuflisted nowrap cursorline nonumber fdc=0 buftype=nofile bufhidden=wipe
  cal s:render()
  setfiletype kubecontexts

  " local bindings
  nnoremap <script><buffer> U     :cal <SID>handleSwitchContext()<CR>
  nnoremap <script><buffer> D     :cal <SID>handleDeleteContext()<CR>

  " nmap <script><buffer> L  :cal <SID>diffFileFromStatusLine()<CR>
  " nnoremap <script><buffer> D     :cal <SID>branchDelete(0)<CR>
  " nnoremap <script><buffer> <C-D> :cal <SID>branchDelete(1)<CR>
  " nnoremap <script><buffer> L     :cal <SID>branchPull()<CR>
  " nnoremap <script><buffer> P     :cal <SID>branchPush()<CR>
  " nmap <script><buffer> E  :cal <SID>splitFileFromStatusLine()<CR>
  " nmap <script><buffer> T  :cal <SID>tabeFileFromStatusLine()<CR>
  " nmap <script><buffer> R  :cal <SID>resetFileFromStatusLine()<CR>
  syn match Comment +^#.*+ 
  syn match CurrentContext +^\*.*+
  hi link CurrentContext Function
endf
com! KubeContextList :cal s:KubeContextList()

" KubeContextList
" nmap <leader>gb  :KubeContextList<CR>
