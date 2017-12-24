
fun! vikube#kubectl_ns(action, namespace, ...)
  return printf("kubectl %s --namespace=%s ", a:action, a:namespace) . join(a:000, ' ')
endf

fun! vikube#get_namespaces()
  return split(system("kubectl get namespace --no-headers | awk '{ print $1 }'"))
endf
