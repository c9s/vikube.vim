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

- `:VikubeTop` - Open the top buffer.

VikubeContextList
-----------------

- `S` - Switch to the selected context.
- `R` - Rename the selected context.
- `D` - Delete the selected context.

VikubeNodeList
--------------

- `L` - Label the selected node.
- `U` - Update list.

VikubePodList
-------------

- `D` - delete the selected pod.
- `S` - describe the selected pod.
- `U` - Update list.

VikubeServiceList
-----------------

- `D` - delete the selected service.

VikubeTop
---------

- `N` - switch to nodes top.
- `P` - switch to pods top.



Default Mapping
---------------

- `<leader>kc` - Open the **k**ubernetes **c**ontext list buffer.

- `<leader>kn` - Open the **k**ubernetes **n**ode list buffer.

- `<leader>ko` - Open the **k**ubernetes p**o**d list buffer.

- `<leader>kv` - Open the **k**ubernetes ser**v**ice list buffer.

- `<leader>kt` - Open the **k**ubernetes **t**op buffer.


License
----------
MIT License
