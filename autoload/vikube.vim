
fun! vikube#kubectl_ns(action, namespace, ...)
  return printf("kubectl %s --namespace=%s ", a:action, a:namespace) . join(a:000, ' ')
endf

fun! vikube#get_pod_containers(namespace, pod)
  let cmd = "kubectl get --namespace=" . a:namespace . ' pod ' . a:pod . " -o=go-template --template '{{range .spec.containers}}{{.name}}{{\"\\n\"}}{{end}}'"
  let out = system(cmd)
  return split(out)
endf

fun! vikube#get_namespaces()
  return split(system("kubectl get namespace --no-headers | awk '{ print $1 }'"))
endf
