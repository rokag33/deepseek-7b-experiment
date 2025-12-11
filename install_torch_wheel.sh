#!/usr/bin/env bash
set -euo pipefail
# Detect CUDA version and install matching PyTorch wheel
# Usage: ./install_torch_wheel.sh [--cuda 12.1] [--index-url <index>]

CUDA_OVERRIDE=""
INDEX_URL="https://download.pytorch.org/whl"
while [ "$#" -gt 0 ]; do
  case "$1" in
    --cuda)
      shift
      CUDA_OVERRIDE=${1:-}
      ;;
    --index-url)
      shift
      INDEX_URL=${1:-$INDEX_URL}
      ;;
    --help|-h)
      echo "Usage: $0 [--cuda 12.1] [--index-url https://download.pytorch.org/whl]"
      exit 0
      ;;
    *)
      echo "Unknown arg: $1"
      exit 1
      ;;
  esac
  shift || true
done

if [ -n "$CUDA_OVERRIDE" ]; then
  cuda="$CUDA_OVERRIDE"
else
  if ! command -v nvidia-smi >/dev/null 2>&1; then
    echo "No nvidia-smi detected; skipping GPU torch wheel install. Use --cuda to force an install."
    exit 0
  fi
  cuda=$(nvidia-smi | grep -Po 'CUDA Version: \K[0-9.]+') || true
fi

if [ -z "$cuda" ]; then
  echo "Could not detect CUDA version (nvidia-smi), skipping GPU torch wheel install. Use --cuda to force an install."
  exit 0
fi

# Convert 12.1 -> cu121
cu_ver=$(echo "$cuda" | tr -d '.' | sed 's/^/cu/')
echo "Detected CUDA: $cuda (wheel tag: $cu_ver)"

PY_INDEX_URL="${INDEX_URL}/${cu_ver}"
echo "Installing torch from index: $PY_INDEX_URL"
python -m pip install --upgrade pip setuptools wheel
python -m pip install --index-url "$PY_INDEX_URL" --upgrade torch || {
  echo "Failed to install torch from: $PY_INDEX_URL. Trying CPU-only wheel as fallback."
  python -m pip install --upgrade torch
}

echo "torch installed successfully"
