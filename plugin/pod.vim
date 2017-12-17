let g:kubernetes_resource_types = [
      \  'all',
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
      \  'nodes' ,
      \  'persistentvolumeclaims' ,
      \  'persistentvolumes' ,
      \  'poddisruptionbudgets' ,
      \  'podpreset',
      \  'pods' ,
      \  'podsecuritypolicies' ,
      \  'podtemplates',
      \  'replicasets' ,
      \  'replicationcontrollers' ,
      \  'resourcequotas' ,
      \  'rolebindings',
      \  'roles',
      \  'secrets',
      \  'serviceaccounts' ,
      \  'services',
      \  'statefulsets',
      \  'storageclasses',
      \ ]

let g:kubernetes_common_resource_types = ["pod", "pvc", "pv", "statefulset", "deployment", "service", "serviceaccount"]

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
  return system(cmd . "| awk 'NR == 1; NR > 1 {print $0 | \"sort -b -k1\"}'")
endf

fun! s:header()
  return "Kubernetes object=" . b:resource_type . " namespace=" . b:namespace . " wide=" . b:wide
endf

fun! s:help()
  cal g:Help.reg(s:header(),
    \" D     - Delete " . b:resource_type . "\n" .
    \" u     - Update List\n" .
    \" w     - Toggle wide option\n" .
    \" s     - Describe " . b:resource_type . "\n" .
    \" Enter - Describe " . b:resource_type . "\n"
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

  let out = system('kubectl delete ' . b:resource_type . ' ' . shellescape(key))
  redraw | echomsg split(out, "\n")[0]
  let b:source_changed = 1
  cal s:render()
endf

fun! s:handlePrevObjectType()
  let x = index(g:kubernetes_common_resource_types, b:resource_type)
  let x = x - 1
  if x < 0
    let x = len(g:kubernetes_common_resource_types) - 1
  endif
  let b:resource_type = g:kubernetes_common_resource_types[x]

  let b:source_changed = 1
  cal s:render()
endf


fun! g:KubernetesNamespaceCompletion(lead, cmd, pos)
  let entries = split(system("kubectl get namespace --no-headers | awk '{ print $1 }'"))
  cal filter(entries , 'v:val =~ "^' .a:lead. '"')
  return entries
endf

func s:handleNamespaceChange()
  cal inputsave()
  let new_namespace = input('Namespace:', b:namespace, 'customlist,KubernetesNamespaceCompletion')
  cal inputrestore()
  if len(new_namespace) > 0
    let b:namespace = new_namespace
  endif
  let b:source_changed = 1
  cal s:render()
endf


fun! g:KubernetesResourceTypeCompletion(lead, cmd, pos)
  let entries = g:kubernetes_resource_types
  cal filter(entries , 'v:val =~ "^' .a:lead. '"')
  return entries
endf

func s:handleResourceTypeChange()
  cal inputsave()
  let new_resource_type = input('Resource Type:', b:namespace, 'customlist,KubernetesResourceTypeCompletion')
  cal inputrestore()
  if len(new_resource_type) > 0
    let b:resource_type = new_resource_type
  endif
  let b:source_changed = 1
  cal s:render()
endf


fun! s:handleNextObjectType()
  let x = index(g:kubernetes_common_resource_types, b:resource_type)
  let x = x + 1
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
  let object = b:resource_type
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
  let b:resource_type = a:object
  exec "silent file VikubeExplorer"
  setlocal noswapfile  
  setlocal nobuflisted nowrap cursorline nonumber fdc=0 buftype=nofile bufhidden=wipe
  setlocal cursorline
  setlocal updatetime=5000
  cal s:render()
  silent exec "setfiletype k" . b:resource_type . "list"

  " local bindings
  nnoremap <script><buffer> D     :cal <SID>handleDelete()<CR>
  nnoremap <script><buffer> u     :cal <SID>handleUpdate()<CR>
  nnoremap <script><buffer> <CR>  :cal <SID>handleDescribe()<CR>
  nnoremap <script><buffer> s     :cal <SID>handleDescribe()<CR>
  nnoremap <script><buffer> w     :cal <SID>handleToggleWide()<CR>
  nnoremap <script><buffer> a     :cal <SID>handleToggleAllNamepsace()<CR>
  nnoremap <script><buffer> n     :cal <SID>handleNamespaceChange()<CR>
  nnoremap <script><buffer> r     :cal <SID>handleResourceTypeChange()<CR>
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
