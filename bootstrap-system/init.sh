#!/bin/bash
set -euo pipefail

init_config_paths="
argocd/
external-secrets/
"

for path in $init_config_paths; do
    echo "Checking for changes in $path..."
    IS_DIFF=$(kubectl diff -k "$path" 2>&1 || true)

    if [ -n "$IS_DIFF" ]; then
        echo "Changes detected in $path. Applying changes..."
        kubectl apply -k "$path" | grep -v "unchanged"
        echo "Successfully applied changes in $path."
        sleep 5
    else
        echo "No changes detected in $path."
    fi
done

kubectl apply -f applicationSet.yaml