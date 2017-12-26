if !exists("g:vikube_default_logs_tail")
  let g:vikube_default_logs_tail = 100
endif

" Deployment, ReplicaSet, Replication Controller, or Job

let g:kubernetes_scalable_resources = ["deployments", "replicasets", "replicationcontrollers", "jobs"]

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

fun! s:source()
  let cmd = "kubectl get " . b:resource_type
  if b:wide
    let cmd = cmd . " -o wide"
  endif
  if b:all_namespace
    let cmd = cmd . " --all-namespaces"
  else
    let cmd = cmd . " --namespace=" . b:namespace
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
  return "Kubernetes namespace=" . b:namespace . " resource=" . b:resource_type . " wide=" . b:wide
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
  cal s:render()
endf

fun! s:deleteResource(line)
  if a:line < 4
    return
  endif

  let key = s:key(getline(a:line))
  let cmd = 'kubectl delete ' . b:resource_type . " --namespace=" . b:namespace . ' ' . shellescape(key)
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
  cal s:render()
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
  cal s:render()
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
  cal s:render()
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

  let cmd = "kubectl exec -it --namespace=" . b:namespace . " --container=" . cont . ' ' . key . ' ' . contcmd
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

  redraw | echomsg "querying container information..."

  if resource_type == "pods"
    let cmd = "kubectl get --namespace=" . b:namespace . ' ' . resource_type . ' ' . key . " -o=go-template --template '{{range .spec.containers}}{{.name}}{{\"\\n\"}}{{end}}'"
  else
    let cmd = "kubectl get --namespace=" . b:namespace . ' ' . resource_type . ' ' . key . " -o=go-template --template '{{range .spec.template.spec.containers}}{{.name}}{{\"\\n\"}}{{end}}'"
  endif

  let out = system(cmd)
  let containers = split(out)
  let cont = s:chooseContainer(containers)
  let cmd = "kubectl logs --tail=" . g:vikube_default_logs_tail . " --namespace=" . b:namespace . " --container=" . cont . ' ' . resource_type . '/' . key

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
  let cmd = 'kubectl explain ' . resource_type
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

fun! s:handleDescribe()
  if line('.') < 4
    return
  endif
  
  let line = getline('.')
  let namespace = s:namespace(line)
  let key = s:key(line)
  let resource_type = b:resource_type
  let cmd = 'kubectl describe ' . resource_type . ' --namespace=' . namespace . ' ' . key
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
  silent normal ggdd
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
  cal s:render()
endf

fun! s:handleNextNamespace()
  let namespaces = vikube#get_namespaces()
  let x = index(namespaces, b:namespace) + 1
  if x >= len(namespaces)
    let x = 0
  endif
  let b:namespace = namespaces[x]
  let b:source_changed = 1
  cal s:render()
endf

fun! s:handlePrevNamespace()
  let namespaces = vikube#get_namespaces()
  let x = index(namespaces, b:namespace) - 1
  if x < 0
    let x = len(namespaces) - 1
  endif
  let b:namespace = namespaces[x]
  let b:source_changed = 1
  cal s:render()
endf

fun! s:handleResourceTypeChange()
  cal inputsave()
  let new_resource_type = input('Resource Type:', '', 'customlist,KubernetesResourceTypeCompletion')
  cal inputrestore()
  if len(new_resource_type) > 0
    let b:resource_type = new_resource_type
  endif
  let b:source_changed = 1
  cal s:render()
endf


fun! s:handlePrevResourceType()
  let x = index(g:kubernetes_common_resource_types, b:resource_type)
  let x = x - 1
  if x < 0
    let x = len(g:kubernetes_common_resource_types) - 1
  endif
  let b:resource_type = g:kubernetes_common_resource_types[x]

  let b:source_changed = 1
  cal s:render()
endf


fun! s:handleNextResourceType()
  let x = index(g:kubernetes_common_resource_types, b:resource_type) + 1
  if x >= len(g:kubernetes_common_resource_types)
    let x = 0
  endif
  let b:resource_type = g:kubernetes_common_resource_types[x]

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

fun! s:handleToggleShowAll()
  if b:show_all == 1
    let b:show_all = 0
  else
    let b:show_all = 1
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

fun! s:handleApplySearch()
  let b:current_search = getline(2)
  cal s:render()
endf


fun! s:handleStartSearch()
  let t:search_inserting = 1
  setlocal nocursorline
  cal s:render()
endf

fun! s:handleStopSearch()
  let t:search_inserting = 0
  setlocal cursorline
  cal s:render()
endf




fun! s:render()
  let save_cursor = getcurpos()
  if b:source_changed || !exists('b:source_cache')
    let b:source_cache = s:source()
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
  redraw
  normal ggdG

  " draw the result
  redraw
  put=out

  " remove the first empty line
  redraw
  normal ggdd

  " prepend the help message
  cal s:help()

  cal append(1, "")
  if !exists('b:current_search') || len(b:current_search) < len(g:vikube_search_prefix)
    cal setline(2, g:vikube_search_prefix)
  else
    cal setline(2, b:current_search)
  endif

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
    redraw | echomsg "list updated at " . strftime("%c")
  endif
endf


fun! s:Vikube(resource_type)
  tabnew
  let t:search_inserting = 0
  let t:result_window_buf = bufnr('%')

  let b:namespace = "default"
  let b:show_all = 0
  let b:source_changed = 1
  let b:current_search = g:vikube_search_prefix
  let b:wide = 1
  let b:all_namespace = 0
  let b:resource_type = a:resource_type
  exec "silent file VikubeExplorer"
  setlocal noswapfile  
  setlocal nobuflisted nowrap cursorline nonumber fdc=0 buftype=nofile bufhidden=wipe
  setlocal cursorline
  setlocal updatetime=2000
  cal s:render()
  silent exec "setfiletype vikube-" . b:resource_type

  " default local bindings
  nnoremap <script><buffer> /     :cal <SID>handleStartSearch()<CR>

  com! -buffer -range VikubeDeleteResource  :call <SID>handleDelete(<line1>, <line2>)

  " Modification Actions
  nnoremap <script><buffer> D     :VikubeDeleteResource<CR>
  vnoremap <script><buffer> D     :VikubeDeleteResource<CR>

  nnoremap <script><buffer> L     :cal <SID>handleLabel()<CR>
  nnoremap <script><buffer> S     :cal <SID>handleScale()<CR>

  " Actions
  nnoremap <script><buffer> l     :cal <SID>handleLogs()<CR>
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
  hi CursorLine term=reverse cterm=reverse ctermbg=darkcyan
endf

com! VikubeNodeList :cal s:Vikube("nodes")
com! VikubePVList :cal s:Vikube("persistentvolumes")
com! VikubePVCList :cal s:Vikube("persistentvolumeclaims")
com! VikubeServiceList :cal s:Vikube("services")
com! VikubeStatefulsetList :cal s:Vikube("statefulsets")
com! VikubeDeploymentList :cal s:Vikube("deployments")
com! VikubePodList :cal s:Vikube("pods")
com! Vikube :cal s:Vikube("pods")

if exists("g:vikube_autoupdate")
  au! CursorHold VikubeExplorer :cal <SID>render()
endif
