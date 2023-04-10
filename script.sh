#!/bin/bash
set -eu

# Parameters
read -p "Enter your NameSpace: " NAMESPACE
read -p "Enter your ServiceAccountName: " SERVICE_ACCOUNT_NAME
read -p "Enter your Role name: " ROLE_NAME
read -p "Enter your RoleBinding name: " ROLE_BINDING_NAME
SECRET_NAME=${SERVICE_ACCOUNT_NAME}-token
KUBECONFIG_DIR="."
KUBECONFIG_FILE="config"

# Create the service account
if ! kubectl get sa ${SERVICE_ACCOUNT_NAME} -n ${NAMESPACE} >/dev/null 2>&1; then
  kubectl create sa ${SERVICE_ACCOUNT_NAME} --namespace ${NAMESPACE}
else 
  echo -e "\033[31mError: The given ServiceAccount ${SERVICE_ACCOUNT_NAME} already exist! Try to create new one\033[0m"
  exit
fi

# Create the secret manually
if ! kubectl get secret ${SERVICE_ACCOUNT_NAME} -n ${NAMESPACE} >/dev/null 2>&1; then
cat <<EOF | kubectl apply --namespace ${NAMESPACE} -f -
apiVersion: v1
kind: Secret
type: kubernetes.io/service-account-token
metadata:
  name: ${SERVICE_ACCOUNT_NAME}
  namespace: ${NAMESPACE}
  annotations:
    kubernetes.io/service-account.name: "${SERVICE_ACCOUNT_NAME}"
EOF
else
  echo -e "\033[31mError: The given Secret ${SERVICE_ACCOUNT_NAME} already exist! Try to create new one\033[0m"
  exit
fi

# Create the role
if ! kubectl get role ${ROLE_NAME} -n ${NAMESPACE} >/dev/null 2>&1; then
cat <<EOF | kubectl apply --namespace ${NAMESPACE} -f -
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
EOF
else
  echo -e "\033[31mError: The given Role ${ROLE_NAME} already exist! Try to create new one\033[0m"
  exit
fi

# Create the role binding
if ! kubectl get rolebinding ${ROLE_BINDING_NAME} -n ${NAMESPACE} >/dev/null 2>&1; then
cat <<EOF | kubectl apply --namespace ${NAMESPACE} -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ${ROLE_BINDING_NAME}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: ${ROLE_NAME}
subjects:
- kind: ServiceAccount
  name: ${SERVICE_ACCOUNT_NAME}
EOF
else
  echo -e "\033[31mError: The given RoleBinding ${ROLE_BINDING_NAME} already exist! Try to create new one\033[0m"
  exit
fi

# Fetch Token
kubectl get secret ${SERVICE_ACCOUNT_NAME} --namespace ${NAMESPACE} -o jsonpath='{.data.token}' | base64 --decode > ${SECRET_NAME}

# Get the kubeconfig file for the created user
cp ~/.kube/config ~/.kube/config.backup
kubectl config set-credentials ${SERVICE_ACCOUNT_NAME} --token=$(cat ${SECRET_NAME})
kubectl config set-context ${SERVICE_ACCOUNT_NAME} --cluster=$(kubectl config view --minify --output 'jsonpath={.clusters[0].name}') --user=${SERVICE_ACCOUNT_NAME} --namespace=${NAMESPACE}
kubectl config use-context ${SERVICE_ACCOUNT_NAME}

# Clean up the temporary secret file
rm ${SECRET_NAME}

echo -e "\033[32m!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo -e "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo -e "!!!   Congratulation, your Account has been created successfully     !!!"
echo -e "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo -e "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\033[0m"
