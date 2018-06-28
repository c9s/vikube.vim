Vikube - Operating Kubernetes Cluster from Vim, in Vim
======================================================

Screenshots
-----------

<img src="https://raw.githubusercontent.com/c9s/vikube.vim/master/assets/01_pod_describe.png" height="200"/>
<img src="https://raw.githubusercontent.com/c9s/vikube.vim/master/assets/02_top.png" height="200"/>
<img src="https://raw.githubusercontent.com/c9s/vikube.vim/master/assets/03_pod_list.png" height="200"/>

Install
-------

If you use vundle:

```vim
call vundle#begin()
    Plugin 'c9s/helper.vim'
    Plugin 'c9s/treemenu.vim'
    Plugin 'c9s/vikube.vim'
call vundle#end()
```

And run:

```
:PluginInstall
```

See [Vundle](https://github.com/VundleVim/Vundle.vim) for more details.

Commands
--------

- `:VikubeContextList` - Open the context list buffer.

- `:Vikube [ResourceType]` - Open the vikube explorer with a specific resource type.

- `:VikubeNodeList` - Open the node list buffer.

- `:VikubePodList` - Open the pod list buffer.

- `:VikubeServiceList` - Open the service list buffer.

- `:VikubePVCList` - Open the service list buffer.

- `:VikubeTop` - Open the top buffer.

VikubeContextList
-----------------

- `s` - Switch to the selected context.
- `R` - Rename the selected context.
- `D` - Delete the selected context.

VikubeExplorer
--------------

- `]]` - Navigate to the next resource type.
- `[[` - Navigate to the previous resource type.

- `e` - Explain the current resource type.
- `s` - Describe the selected resource.
- `n` - Switch namespace.
- `r` - Switch resource type.
- `N` - Toggle "all namespaces" option.
- `u` - Update the current list.
- `w` - Toggle wide option.
- `l` - Show logs of the pod
- `tl` - Open a terminal to follow the logs
- `o` - Get the resource YAML
- `x` - Execute a command in the container
- `cx` - Switch context (buffer scope)
- `L` - Label the selected resource.  (Input form: `Label=Value Label2=Value2`)
- `D` - Delete the selected resource.

VikubeTop
---------

- `n` - switch to nodes top.
- `p` - switch to pods top.
- `s` - describe the selected pod or node.

Configuration
---------------

To turn on automatic list update:

    let g:vikube_autoupdate = 1

To change the default tail lines for logs:

    g:vikube_default_logs_tail = 100

To use current namespace instead of "default":

    g:vikube_use_current_namespace = 1

To disable the default highlight for CursorLine:

    g:vikube_disable_custom_highlight = 1

Default Mapping
---------------

- `<leader>kc` - Open the (**k**)ubernetes (**c**)ontext list buffer.

- `<leader>kno` - Open the (**k**)ubernetes (**no**)de list buffer.

- `<leader>kpo` - Open the (**k**)ubernetes (**po**)d list buffer.

- `<leader>ksv` - Open the (**k**)ubernetes (**s**)er(**v**)ice list buffer.

- `<leader>kt` - Open the (**k**)ubernetes (**t**)op buffer.

- `<leader>kpvc` - Open the (**k**)ubernetes persistent volume claim buffer.


Changelogs
----------

### Sun Dec 17 17:04:01 2017

- Change all action keys to lower case but keep the deletion in uppercase.


License
----------
MIT License
