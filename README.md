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

- `:VikubeNodeList` - Open the node list buffer.

- `:VikubePodList` - Open the pod list buffer.

- `:VikubeServiceList` - Open the service list buffer.

- `:VikubePVCList` - Open the service list buffer.

- `:VikubeTop` - Open the top buffer.

VikubeContextList
-----------------

- `s` - Switch to the selected context.
- `r` - Rename the selected context.
- `D` - Delete the selected context.

VikubeNodeList
--------------

- `l` - Label the selected node.  (Input form: `Label=Value Label2=Value2`)
- `d` - describe the selected node.
- `u` - Update list.

VikubePodList
-------------

- `D` - delete the selected pod.
- `d` - describe the selected pod.
- `s` - describe the selected pod.
- `u` - Update list.

VikubeServiceList
-----------------

- `D` - delete the selected service.
- `d` - describe the selected service.

VikubeTop
---------

- `n` - switch to nodes top.
- `p` - switch to pods top.
- `d` - describe the selected pod or node.

Configuration
---------------

To turn on automatic list update:

    let g:vikube_autoupdate = 1

Default Mapping
---------------

- `<leader>kc` - Open the **k**ubernetes **c**ontext list buffer.

- `<leader>kno` - Open the **k**ubernetes **no**de list buffer.

- `<leader>kpo` - Open the **k**ubernetes **po**d list buffer.

- `<leader>ksv` - Open the **k**ubernetes **s**er**v**ice list buffer.

- `<leader>kt` - Open the **k**ubernetes **t**op buffer.

- `<leader>kpvc` - Open the **k**ubernetes persistent volume claim buffer.

Changelogs
----------

### Sun Dec 17 17:04:01 2017

- Change all action keys to lower case but keep the deletion in uppercase.


License
----------
MIT License
