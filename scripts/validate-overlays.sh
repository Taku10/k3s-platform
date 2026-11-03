#!/usr/bin/env bash

set -euo pipefail

roots=(apps argocd kargo platform)
mapfile -d '' packages < <(
  find "${roots[@]}" -type f -name kustomization.yaml -print0 | sort -z
)

if (( ${#packages[@]} == 0 )); then
  echo "No Kustomize packages found." >&2
  exit 1
fi

work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

for kustomization in "${packages[@]}"; do
  package_dir="$(dirname "$kustomization")"
  output_file="$work_dir/$(echo "$package_dir" | tr '/' '_').yaml"

  echo "Rendering $package_dir"
  kubectl kustomize "$package_dir" > "$output_file"

  if [[ ! -s "$output_file" ]]; then
    echo "Rendered output is empty: $package_dir" >&2
    exit 1
  fi

  if grep -Eq '^[[:space:]]*kind:[[:space:]]*Secret[[:space:]]*$' "$output_file"; then
    echo "Plain Kubernetes Secret rendered by $package_dir." >&2
    echo "Store only secret references in Git; create secret values outside the repository." >&2
    exit 1
  fi

  if [[ "$package_dir" == */overlays/* ]] &&
    grep -Eq '^[[:space:]]*image:[[:space:]]*[^[:space:]]*:latest([[:space:]]|$)' "$output_file"; then
    echo "Mutable :latest image found in deployable overlay $package_dir." >&2
    exit 1
  fi
done

echo "Validated ${#packages[@]} Kustomize package(s)."
