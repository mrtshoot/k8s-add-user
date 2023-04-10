# k8s-add-user
Script to add user in K8S cluster

#### Note: this Script backup your default configuration file ~/.kube/config.so don't worry about that

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

## Donate: 
TNCtD7pARiD7iEffov2ARXAP6fGNVvtFaA
