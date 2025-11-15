if [ -z "$1" ]; then
  echo "Usage: $0 <namespace>"
  exit 1
fi

NAMESPACE=$1

kubectl -n $NAMESPACE create secret generic bastion-authorized-keys --from-file=authorized_keys=$HOME/.ssh/id_rsa.pub
kubectl -n $NAMESPACE apply -f sshBastion.yaml

echo "MongoDB admin password:"
kubectl -n $NAMESPACE get secrets mongodb-admin -o jsonpath="{.data.password}" | base64 -d

echo ""