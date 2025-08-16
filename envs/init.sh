#!/opt/homebrew/bin/bash
set -euo pipefail

declare -A kubecontext

kubecontext["dev"]="arn:aws:eks:ap-south-1:986069063944:cluster/dev-eks"
kubecontext["prod"]="arn:aws:eks:ap-south-1:986069063944:cluster/prod-eks"

ENV=$1

init_config_paths="
argocd/
argocd-appproj/
external-secrets-operator/
external-secrets/
"

kubectl config use-context "${kubecontext[$ENV]}" || {
    echo "Error: Invalid environment '$ENV'. Available environments are: ${!kubecontext[@]}"
    exit 1
}
cd $ENV/bootstrap-system

for path in $init_config_paths; do
    echo "Checking for changes in $path..."
    IS_DIFF=$(kubectl diff -k "$path" 2>&1 || true)

    if [ -n "$IS_DIFF" ]; then
        echo "Changes detected in $path. Applying changes..."
        kubectl apply -k "$path" | grep -v "unchanged"
        kubectl wait --for=condition=available --timeout=60s --all deployments -A > /dev/null

        IS_APPS=$(kubectl get application -A --no-headers | wc -l)
        if [ "$IS_APPS" -gt 0 ]; then
            kubectl wait --for=jsonpath='{.status.health.status}'=Healthy --timeout 130s --all app -A > /dev/null
        fi
        
        echo "Successfully applied changes in $path."

        sleep 5
    else
        echo "No changes detected in $path."
    fi
done

kubectl apply -f ../applicationSet.yaml