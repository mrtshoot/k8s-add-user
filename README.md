# k8s-add-user
A simple script to add user in K8S cluster

#### Note1: This script backup your default configuration file ~/.kube/config. so don't worry about that.
#### Note2: This script is only compatible with Kubernetes version 1.24 and later.
https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.24.md#urgent-upgrade-notes


### Steps

1. change role section in line38(apiGroup, Resources, Verbs) based on your need.

sample role
```
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: ${ROLE_NAME}
rules:
- apiGroups:
  - ""
  resources:
  - pods
  - services
  - pods/log
  - pods/exec
  - pods/attach
  verbs:
  - get
  - list
  - watch
  - create
  - patch
```

2. run your script to create resources. Then Answer the interactive questions.
```
chmod +x script.sh
./script.sh
```

## Donation:
```
Tether: TNCtD7pARiD7iEffov2ARXAP6fGNVvtFaA
```

```
Buy me a Book: 
https://www.buymeacoffee.com/mrtshoot
```
