
let g:VTable = {}

fun! g:VTable.source()
  return "ls -l"
endf

fun! g:VTable.help()
endf

fun! g:VTable.render()
  let save_cursor = getcurpos()
  if b:source_changed || !exists('b:source_cache')
    let b:source_cache = self.source()
    let b:source_changed = 0
  endif

  let current_search = getline(2)
  let s = strpart(current_search, len(g:vikube_search_prefix))

  if len(s) > 0
    let lines = split(b:source_cache, "\n")
    let rows = lines[1:]
    cal filter(rows, 'v:val =~ "' . s . '"')
    let out = join(lines[:0] + rows, "\n")
  else
    let out = b:source_cache
  endif

  setlocal modifiable

  " clear the buffer
  silent 1,$d

  if !exists('b:current_search') || len(b:current_search) < len(g:vikube_search_prefix)
    cal setline(1, g:vikube_search_prefix)
  else
    cal setline(1, b:current_search)
  endif

  " prepend the help message
  cal self.help()

  " draw the result
  2put=out
  redraw

  if t:search_inserting
    let save_cursor[1] = 2
    if save_cursor[2] < len(g:vikube_search_prefix) + 1
      let save_cursor[2] = len(g:vikube_search_prefix) + 1
    endif
    call setpos('.', save_cursor)
    setlocal modifiable
    startinsert
  else
    if save_cursor[1] < 4 && line('$') >= 5
      let save_cursor[1] = 4
    endif

    call setpos('.', save_cursor)

    " trigger CursorHold event
    if exists("g:vikube_autoupdate")
      call feedkeys("\e")
    endif
    setlocal nomodifiable
    " the redraw will flush the autoupdate message
    redraw | echomsg "list updated at " . strftime("%c")
  endif
endf

if !exists("g:vikube_default_logs_tail")
  let g:vikube_default_logs_tail = 100
endif

let s:VikubeExplorer = copy(g:VTable)

fun! s:VikubeExplorer.source()
  let cmd = s:cmdbase()
  let cmd = cmd . " get " . b:resource_type
  if b:wide
    let cmd = cmd . " -o wide"
  endif
  if b:all_namespace
    let cmd = cmd . " --all-namespaces"
  endif
  if b:show_all
    let cmd = cmd . " --show-all"
  endif
  redraw | echomsg cmd

  " sort by the first column
  return system(cmd . "| awk 'NR == 1; NR > 1 {print $0 | \"sort -b -k1\"}'")
endf

fun! s:VikubeExplorer.help()
  cal g:Help.reg(s:header(),
    \" ]]      - Next resource type\n".
    \" [[      - Previous resource type\n".
    \" <Right> - Next resource type\n".
    \" <Left>  - Previous resource type\n".
    \" }}      - Next namespace\n".
    \" {{      - Previous namespace type\n".
    \" u       - Update List\n" .
    \" e       - Explain the current resource\n" .
    \" w       - Toggle wide option\n" .
    \" a       - Toggle show all option\n" .
    \" N       - Toggle all namespaces\n" .
    \" n       - Switch namespace view\n" .
    \" r       - Switch resource type view\n" .
    \" cx      - Switch context\n" .
    \" l       - See logs of " . b:resource_type . "\n" .
    \" x       - Execute in the selected pod\n" .
    \" L       - Label " . b:resource_type . "\n" .
    \" S       - Scale " . b:resource_type . "\n" .
    \" D       - Delete " . b:resource_type . "\n" .
    \" s       - Describe " . b:resource_type . "\n" .
    \" Enter   - Describe " . b:resource_type . "\n"
    \,1)
endf

" fun! s:VikubeExplorer.render()
"   call call(g:VTable.render, [], s:VikubeExplorer)
" endf



" Deployment, ReplicaSet, Replication Controller, or Job

let g:kubernetes_scalable_resources = ["deployments", "replicasets", "replicationcontrollers", "jobs", "statefulsets"]

let g:kubernetes_resource_aliases = {
      \  'pods': 'po',
      \  'nodes': 'no',
      \  'services': 'svc',
      \  'persistentvolumeclaims': 'pvc',
      \  'persistentvolumes': 'pv'
      \}

let g:kubernetes_resource_types = [
      \  'certificatesigningrequests',
      \  'clusterrolebindings',
      \  'clusterroles',
      \  'clusters',
      \  'componentstatuses',
      \  'configmaps',
      \  'controllerrevisions',
      \  'cronjobs',
      \  'customresourcedefinition',
      \  'daemonsets',
      \  'deployments',
      \  'endpoints',
      \  'events',
      \  'horizontalpodautoscalers' ,
      \  'ingresses' ,
      \  'jobs',
      \  'limitranges' ,
      \  'namespaces' ,
      \  'networkpolicies' ,
      \  'nodes',
      \  'persistentvolumeclaims',
      \  'persistentvolumes',
      \  'poddisruptionbudgets',
      \  'podpreset',
      \  'pods',
      \  'podsecuritypolicies' ,
      \  'podtemplates',
      \  'replicasets' ,
      \  'replicationcontrollers' ,
      \  'resourcequotas',
      \  'rolebindings',
      \  'roles',
      \  'secrets',
      \  'serviceaccounts',
      \  'services',
      \  'statefulsets',
      \  'storageclasses']

let g:kubernetes_loggable_resource_types = [
      \"pods",
      \"deployments",
      \"replicasets",
      \"statefulsets",
      \"jobs"]

let g:kubernetes_common_resource_types = [
      \"pods",
      \"persistentvolumeclaims",
      \"persistentvolumes", 
      \"statefulsets", 
      \"replicasets",
      \"deployments", 
      \"endpoints", 
      \"replicasets", 
      \"services", 
      \"serviceaccounts"]

let g:vikube_search_prefix = '> '


fun! g:KubernetesNamespaceCompletion(lead, cmd, pos)
  let entries = vikube#get_namespaces()
  cal filter(entries , 'v:val =~ "^' .a:lead. '"')
  return entries
endf

fun! g:KubernetesResourceTypeCompletion(lead, cmd, pos)
  let entries = g:kubernetes_resource_types[:] + values(g:kubernetes_resource_aliases)
  cal filter(entries , 'v:val =~ "^' .a:lead. '"')
  return entries
endf

fun! g:KubernetesContexts()
  let out = system("kubectl config get-contexts --no-headers | cut -d' ' -f2- | awk '{ print $1 }'")
  return split(out)
endf

fun! g:KubernetesContextCompletion(lead, cmd, pos)
  let entries = g:KubernetesContexts()
  cal filter(entries , 'v:val =~ "^' .a:lead. '"')
  return entries
endf

fun! s:cmdbase()
  let cmd = "kubectl"
  if exists('b:context') && len(b:context) > 0
    let cmd = cmd . " --context=" . b:context
  endif

  if exists('b:namespace') && len(b:namespace) > 0
    let cmd = cmd . " --namespace=" . b:namespace
  endif
  return cmd
endf

fun! s:source()
  let cmd = s:cmdbase()
  let cmd = cmd . " get " . b:resource_type
  if b:wide
    let cmd = cmd . " -o wide"
  endif
  if b:all_namespace
    let cmd = cmd . " --all-namespaces"
  endif
  if b:show_all
    let cmd = cmd . " --show-all"
  endif
  redraw | echomsg cmd
  return system(cmd . "| awk 'NR == 1; NR > 1 {print $0 | \"sort -b -k1\"}'")
endf

fun! s:chooseContainer(containers)
  if len(a:containers) == 1
    return a:containers[0]
  else
    cal inputsave()
    " let cont = input('Container (' . join(containers, ',') . '):', '')
    let items = a:containers[:]
    let list = ['Select Container:'] + map(items, 'v:key + 1 . ") " . v:val')
    let x = inputlist(list)
    cal inputrestore()
    if x > 0
      return a:containers[x - 1]
    endif
    return a:containers[0]
  endif
endf

fun! s:header()
  let context = vikube#get_current_context()
  if exists('b:context') && len(b:context) > 0
    let context = b:context
  endif
  return "Kubernetes "
        \ . " context=" . context
        \ . " namespace=" . b:namespace 
        \ . " resource=" . b:resource_type 
        \ . " wide=" . b:wide
        \ . " all=" . b:show_all
endf

fun! s:help()
  cal g:Help.reg(s:header(),
    \" ]]      - Next resource type\n".
    \" [[      - Previous resource type\n".
    \" <Right> - Next resource type\n".
    \" <Left>  - Previous resource type\n".
    \" }}      - Next namespace\n".
    \" {{      - Previous namespace type\n".
    \" u       - Update List\n" .
    \" e       - Explain the current resource\n" .
    \" w       - Toggle wide option\n" .
    \" a       - Toggle show all option\n" .
    \" N       - Toggle all namespaces\n" .
    \" n       - Switch namespace view\n" .
    \" r       - Switch resource type view\n" .
    \" cx      - Switch context\n" .
    \" l       - See logs of " . b:resource_type . "\n" .
    \" x       - Execute in the selected pod\n" .
    \" L       - Label " . b:resource_type . "\n" .
    \" S       - Scale " . b:resource_type . "\n" .
    \" D       - Delete " . b:resource_type . "\n" .
    \" s       - Describe " . b:resource_type . "\n" .
    \" Enter   - Describe " . b:resource_type . "\n"
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
  call s:VikubeExplorer.render()
endf

fun! s:deleteResource(line)
  if a:line < 4
    return
  endif

  let key = s:key(getline(a:line))
  let cmd = s:cmdbase() . ' delete ' . b:resource_type . ' ' . shellescape(key)
  redraw | echomsg cmd
  let out = system(cmd)
  redraw | echomsg split(out, "\n")[0]
endf

fun! s:handleDelete(line1, line2)
  if line('.') < 4
    return
  endif

  let lnum = a:line1
  while lnum <= a:line2
      call s:deleteResource(lnum)
      let lnum = lnum + 1
  endwhile

  let b:source_changed = 1
  call s:VikubeExplorer.render()
endf

fun! s:handleScale()
  if line('.') < 4
    return
  endif

  if index(g:kubernetes_scalable_resources, b:resource_type) == -1
    redraw | echomsg b:resource_type . " are not scalable."
    return
  endif

  let key = s:key(getline('.'))

  cal inputsave()
  let num_replicas = input('Scale ' . key . ' to N replicas:', '')
  cal inputrestore()

  if len(num_replicas) == 0
    redraw | echomsg "Please enter a number"
    return
  endif

  let out = system(vikube#kubectl_ns('scale', b:namespace, '--replicas=' . num_replicas, b:resource_type, key))
  redraw | echomsg split(out, "\n")[0]

  let b:source_changed = 1
  call s:VikubeExplorer.render()
endf

fun! s:handleLabel()
  if line('.') < 4
    return
  endif
  
  let key = s:key(getline('.'))

  cal inputsave()
  let labels = input('Label (to ' . key . '):', '')
  cal inputrestore()

  let out = system(vikube#kubectl_ns('label', b:namespace, b:resource_type, shellescape(key), labels))
  redraw | echomsg split(out, "\n")[0]

  let b:source_changed = 1
  call s:VikubeExplorer.render()
endf

fun! s:handleExec()
  if line('.') < 4
    return
  endif

  if b:resource_type != "pods"
    redraw | echomsg "you can only exec into pods."
    return
  endif

  let key = s:key(getline('.'))
  let containers = vikube#get_pod_containers(b:namespace, key)
  let cont = s:chooseContainer(containers)

  cal inputsave()
  let contcmd = input('Enter the command (' . cont . '): ', 'sh')
  cal inputrestore()

  let cmd = s:cmdbase() . " exec -it --namespace=" . b:namespace . " --container=" . cont . ' ' . key . ' ' . contcmd
  let termcmd = "terminal ++close " . cmd
  exec termcmd
endf

fun! s:handleLogs()
  if line('.') < 4
    return
  endif
  
  if index(g:kubernetes_loggable_resource_types, b:resource_type) == -1
    redraw | echomsg "logs are only for " . join(g:kubernetes_loggable_resource_types, ',')
    return
  endif

  let resource_type = b:resource_type
  let key = s:key(getline('.'))


  if resource_type == "pods"
    let cmd = s:cmdbase() . ' get ' . resource_type . ' ' . key . " -o=go-template --template '{{range .spec.containers}}{{.name}}{{\"\\n\"}}{{end}}'"
  else
    let cmd = s:cmdbase() . ' get ' . resource_type . ' ' . key . " -o=go-template --template '{{range .spec.template.spec.containers}}{{.name}}{{\"\\n\"}}{{end}}'"
  endif

  let out = system(cmd)
  let containers = split(out)
  let cont = s:chooseContainer(containers)
  let cmd = s:cmdbase() . " logs --tail=" . g:vikube_default_logs_tail . " --namespace=" . b:namespace . " --timestamps --container=" . cont . ' ' . resource_type . '/' . key

  botright new
  silent exec "file " . key
  setlocal noswapfile nobuflisted cursorline nonumber fdc=0
  setlocal nowrap nocursorline
  setlocal buftype=nofile bufhidden=wipe
  setlocal modifiable

  redraw | echomsg cmd
  let out = system(cmd)
  silent put=out
  redraw
  silent normal ggdd
  silent exec "setfiletype vikube-logs"
  setlocal nomodifiable

  let endofline = line('$')
  cal cursor(endofline, 0)

  nnoremap <script><buffer> q :q<CR>
endf



fun! s:handleExplain()
  if line('.') < 4
    return
  endif
  
  let line = getline('.')
  let namespace = s:namespace(line)
  let key = s:key(line)
  let resource_type = b:resource_type
  let cmd = s:cmdbase() . ' explain ' . resource_type
  redraw | echomsg cmd

  let out = system(cmd)
  botright new
  silent exec "file " . key
  setlocal noswapfile nobuflisted cursorline nonumber fdc=0
  setlocal wrap
  setlocal buftype=nofile bufhidden=wipe
  setlocal modifiable
  setlocal nolist
  silent put=out
  redraw
  silent normal ggdd
  silent exec "setfiletype kexplain" . resource_type
  setlocal nomodifiable
  nnoremap <script><buffer> q :q<CR>
endf

fun! s:handleDump()
  if line('.') < 4
    return
  endif
  
  let line = getline('.')
  let namespace = s:namespace(line)
  let key = s:key(line)
  let resource_type = b:resource_type
  let cmd = s:cmdbase() . ' get ' . resource_type . ' --namespace=' . namespace . ' -o yaml ' . key
  redraw | echomsg cmd

  let out = system(cmd)
  botright new
  silent exec "file " . key
  setlocal noswapfile nobuflisted cursorline nonumber fdc=0
  setlocal wrap nocursorline
  setlocal buftype=nofile bufhidden=wipe
  setlocal modifiable
  silent put=out
  redraw
  silent setfiletype yaml
  setlocal nomodifiable
  nnoremap <script><buffer> q :q<CR>
endf

fun! s:handleDescribe()
  if line('.') < 4
    return
  endif
  
  let line = getline('.')
  let namespace = s:namespace(line)
  let key = s:key(line)
  let resource_type = b:resource_type
  let cmd = s:cmdbase() . ' describe ' . resource_type . ' --namespace=' . namespace . ' ' . key
  redraw | echomsg cmd

  let out = system(cmd)
  botright new
  silent exec "file " . key
  setlocal noswapfile nobuflisted cursorline nonumber fdc=0
  setlocal wrap nocursorline
  setlocal buftype=nofile bufhidden=wipe
  setlocal modifiable
  silent put=out
  redraw
  silent exec "setfiletype kdescribe" . resource_type
  setlocal nomodifiable

  nnoremap <script><buffer> q :q<CR>

  syn match Label +^\S.\{-}:+ 
  syn match Error +Error+ 
endf



fun! s:handleNamespaceChange()
  cal inputsave()
  let new_namespace = input('Namespace:', '', 'customlist,KubernetesNamespaceCompletion')
  cal inputrestore()
  if len(new_namespace) > 0
    let b:namespace = new_namespace
  endif
  let b:source_changed = 1
  call s:VikubeExplorer.render()
endf

fun! s:handleNextNamespace()
  let namespaces = vikube#get_namespaces()
  let x = index(namespaces, b:namespace) + 1
  if x >= len(namespaces)
    let x = 0
  endif
  let b:namespace = namespaces[x]
  let b:source_changed = 1
  call s:VikubeExplorer.render()
endf

fun! s:handlePrevNamespace()
  let namespaces = vikube#get_namespaces()
  let x = index(namespaces, b:namespace) - 1
  if x < 0
    let x = len(namespaces) - 1
  endif
  let b:namespace = namespaces[x]
  let b:source_changed = 1
  call s:VikubeExplorer.render()
endf

fun! s:handleContextChange()
  cal inputsave()
  let new_context = input('Context:', '', 'customlist,KubernetesContextCompletion')
  cal inputrestore()
  if len(new_context) > 0 && index(g:KubernetesContexts(), new_context) != -1
    let b:context = new_context
  endif
  let b:source_changed = 1
  call s:VikubeExplorer.render()
endf


fun! s:handleResourceTypeChange()
  cal inputsave()
  let new_resource_type = input('Resource Type:', '', 'customlist,KubernetesResourceTypeCompletion')
  cal inputrestore()
  if len(new_resource_type) > 0
    let b:resource_type = new_resource_type
  endif
  let b:source_changed = 1
  call s:VikubeExplorer.render()
endf


fun! s:handlePrevResourceType()
  let x = index(g:kubernetes_common_resource_types, b:resource_type)
  let x = x - 1
  if x < 0
    let x = len(g:kubernetes_common_resource_types) - 1
  endif
  let b:resource_type = g:kubernetes_common_resource_types[x]

  let b:source_changed = 1
  call s:VikubeExplorer.render()
endf


fun! s:handleNextResourceType()
  let x = index(g:kubernetes_common_resource_types, b:resource_type) + 1
  if x >= len(g:kubernetes_common_resource_types)
    let x = 0
  endif
  let b:resource_type = g:kubernetes_common_resource_types[x]

  let b:source_changed = 1
  call s:VikubeExplorer.render()
endf

fun! s:handleToggleAllNamepsace()
  if b:all_namespace == 1
    let b:all_namespace = 0
  else
    let b:all_namespace = 1
  endif

  let b:source_changed = 1
  call s:VikubeExplorer.render()
endf

fun! s:handleToggleShowAll()
  if b:show_all == 1
    let b:show_all = 0
  else
    let b:show_all = 1
  endif

  let b:source_changed = 1
  call s:VikubeExplorer.render()
endf

fun! s:handleToggleWide()
  if b:wide == 1
    let b:wide = 0
  else
    let b:wide = 1
  endif

  let b:source_changed = 1
  call s:VikubeExplorer.render()
endf

fun! s:handleApplySearch()
  let b:current_search = getline(2)
  call s:VikubeExplorer.render()
endf


fun! s:handleStartSearch()
  let t:search_inserting = 1
  setlocal nocursorline
  call s:VikubeExplorer.render()
endf

fun! s:handleStopSearch()
  let t:search_inserting = 0
  setlocal cursorline
  call s:VikubeExplorer.render()
endf

fun! s:autoUpdate()
  let b:source_changed = 1
  call s:VikubeExplorer.render()
endf

fun! s:render()
  call s:VikubeExplorer.render()
endf



fun! s:VikubeApply(...)
  let file = expand('%')
  let cmd = s:cmdbase() . " apply "
  let cmd = cmd . join(a:000, " ")
  let cmd = cmd . " -f " . file
  let termcmd = "terminal ++rows=5 " . cmd
  exec termcmd
endf

fun! s:VikubeReplace(...)
  let file = expand('%')
  let cmd = s:cmdbase() . " replace "
  let cmd = cmd . join(a:000, " ")
  let cmd = cmd . " -f " . file
  let termcmd = "terminal ++rows=5 " . cmd
  exec termcmd

endf

fun! s:Vikube(resource_type)

  tabnew
  let t:search_inserting = 0
  let t:result_window_buf = bufnr('%')

  let b:namespace = "default"
  if exists('g:vikube_use_current_namespace') && g:vikube_use_current_namespace
      let b:namespace = vikube#get_current_namespace()
  endif


  " resource mode related flags
  let b:show_all = 0
  let b:source_changed = 1
  let b:current_search = g:vikube_search_prefix
  let b:wide = 1
  let b:context = ''
  let b:all_namespace = 0

  if a:resource_type
    let b:resource_type = a:resource_type
  else
    let b:resource_type = "pods"
  endif

  " set the filename
  silent exec "file VikubeExplorer"

  cal vikube#buffer#init()

  " setup the updatetime for refresh
  setlocal updatetime=2000

  call s:VikubeExplorer.render()

  silent exec "setfiletype vikube-" . b:resource_type

  " default local bindings
  nnoremap <script><buffer> /     :cal <SID>handleStartSearch()<CR>

  com! -buffer -range VikubeDeleteResource  :call <SID>handleDelete(<line1>, <line2>)

  " Modification Actions
  nnoremap <script><buffer> D     :VikubeDeleteResource<CR>
  vnoremap <script><buffer> D     :VikubeDeleteResource<CR>
  vnoremap <script><buffer> d     :VikubeDeleteResource<CR>

  nnoremap <script><buffer> L     :cal <SID>handleLabel()<CR>
  nnoremap <script><buffer> S     :cal <SID>handleScale()<CR>

  " Actions
  nnoremap <script><buffer> l     :cal <SID>handleLogs()<CR>
  nnoremap <script><buffer> o     :cal <SID>handleDump()<CR>
  nnoremap <script><buffer> x     :cal <SID>handleExec()<CR>
  nnoremap <script><buffer> u     :cal <SID>handleUpdate()<CR>
  nnoremap <script><buffer> <CR>  :cal <SID>handleDescribe()<CR>
  nnoremap <script><buffer> s     :cal <SID>handleDescribe()<CR>
  nnoremap <script><buffer> e     :cal <SID>handleExplain()<CR>
  nnoremap <script><buffer> a     :cal <SID>handleToggleShowAll()<CR>
  nnoremap <script><buffer> w     :cal <SID>handleToggleWide()<CR>
  nnoremap <script><buffer> n     :cal <SID>handleNamespaceChange()<CR>
  nnoremap <script><buffer> N     :cal <SID>handleToggleAllNamepsace()<CR>
  nnoremap <script><buffer> r     :cal <SID>handleResourceTypeChange()<CR>
  nnoremap <script><buffer> cx    :cal <SID>handleContextChange()<CR>

  nnoremap <script><buffer> ]]     :cal <SID>handleNextResourceType()<CR>
  nnoremap <script><buffer> [[     :cal <SID>handlePrevResourceType()<CR>

  nnoremap <script><buffer> <Right>     :cal <SID>handleNextResourceType()<CR>
  nnoremap <script><buffer> <Left>     :cal <SID>handlePrevResourceType()<CR>

  nnoremap <script><buffer> }}     :cal <SID>handleNextNamespace()<CR>
  nnoremap <script><buffer> {{     :cal <SID>handlePrevNamespace()<CR>

  inoremap <script><buffer> <C-a>  <home>
  inoremap <script><buffer> <C-e>  <end>
  inoremap <script><buffer> <CR>  <esc>

  au! InsertEnter  <buffer> :cal <SID>handleStartSearch()
  au! InsertLeave  <buffer> :cal <SID>handleStopSearch()
  au! CursorMovedI <buffer> :cal <SID>handleApplySearch()

  syn match Comment +^#.*+ 
  " syn region Search start="^> .*" end="$" keepend

  if exists('g:vikube_enable_custom_highlight') && g:vikube_enable_custom_highlight
      hi CursorLine term=reverse cterm=reverse ctermbg=darkcyan guifg=white guibg=darkcyan
      hi Cursor term=reverse cterm=reverse ctermbg=darkcyan guifg=white guibg=darkcyan
  endif
endf

" YAML file commands
com! -nargs=* KubeApply :cal s:VikubeApply(<q-args>)
com! -nargs=* KubeApplyForce :cal s:VikubeApply('--force', <q-args>)
com! -nargs=* KubeReplace :cal s:VikubeReplace(<q-args>)
com! -nargs=* KubeReplaceForce :cal s:VikubeReplace('--force', <q-args>)

com! VikubeNodeList :cal s:Vikube("nodes")
com! VikubePVList :cal s:Vikube("persistentvolumes")
com! VikubePVCList :cal s:Vikube("persistentvolumeclaims")
com! VikubeServiceList :cal s:Vikube("services")
com! VikubeStatefulsetList :cal s:Vikube("statefulsets")
com! VikubeDeploymentList :cal s:Vikube("deployments")
com! VikubePodList :call s:Vikube("pods")
com! -nargs=* -complete=customlist,g:KubernetesResourceTypeCompletion Vikube :call s:Vikube(<q-args>)

if exists("g:vikube_autoupdate")
  au! CursorHold VikubeExplorer :cal <SID>autoUpdate()
endif
