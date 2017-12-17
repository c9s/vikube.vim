fun! vikube#get_namespaces()
  return split(system("kubectl get namespace --no-headers | awk '{ print $1 }'"))
endf
