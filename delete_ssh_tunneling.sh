if [ -z "$1" ]; then
  echo "Usage: $0 <namespace>"
  exit 1
fi

NAMESPACE=$1

kubectl -n $NAMESPACE delete secret bastion-authorized-keys
kubectl -n $NAMESPACE delete -f sshBastion.yaml