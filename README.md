Vikube - Operating Kubernetes Cluster from Vim, in Vim
======================================================

Install
-------

If you use vundle:

```
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


Default Mapping
---------------

- `<leader>kc` - Open the **k**ubernetes **c**ontext list buffer.

- `<leader>kn` - Open the **k**ubernetes **n**ode list buffer.

- `<leader>kp` - Open the **k**ubernetes **p**od list buffer.

- `<leader>kv` - Open the **k**ubernetes ser*v*ice list buffer.

- `<leader>kt` - Open the **k**ubernetes **t**op buffer.


License
----------
MIT License
