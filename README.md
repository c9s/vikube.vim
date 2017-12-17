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

See ![https://github.com/VundleVim/Vundle.vim](vundle) for more details.

Commands
--------

- `:VikubeContextList` - Open the context list buffer

- `:VikubePodList` - Open the pod list buffer

- `:VikubeServiceList` - Open the service list buffer


Default Mapping
---------------

- `<leader>kc` - Open the **k**ubernetes **c**ontext list

- `<leader>kp` - Open the **k**ubernetes **p**od list

- `<leader>kv` - Open the **k**ubernetes ser*v*ice list


License
----------
MIT License
