#!/usr/bin/env bash

set -euo pipefail

mapfile -d '' overlays < <(
  find apps -type f -path '*/overlays/*/kustomization.yaml' -print0 | sort -z
)

if (( ${#overlays[@]} == 0 )); then
  echo "No Kustomize overlays found under apps/." >&2
  exit 1
fi

work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

for kustomization in "${overlays[@]}"; do
  overlay_dir="$(dirname "$kustomization")"
  output_file="$work_dir/$(echo "$overlay_dir" | tr '/' '_').yaml"

  echo "Rendering $overlay_dir"
  kubectl kustomize "$overlay_dir" > "$output_file"

  if [[ ! -s "$output_file" ]]; then
    echo "Rendered output is empty: $overlay_dir" >&2
    exit 1
  fi

  if grep -Eq '^[[:space:]]*kind:[[:space:]]*Secret[[:space:]]*$' "$output_file"; then
    echo "Plain Kubernetes Secret rendered by $overlay_dir." >&2
    echo "Store only secret references in Git; create secret values outside the repository." >&2
    exit 1
  fi

  if grep -Eq '^[[:space:]]*image:[[:space:]]*[^[:space:]]*:latest([[:space:]]|$)' "$output_file"; then
    echo "Mutable :latest image found in $overlay_dir." >&2
    exit 1
  fi
done

echo "Validated ${#overlays[@]} Kustomize overlay(s)."
