#!/usr/bin/env bash
set -euo pipefail

# Script to run in a GPU-enabled Codespace to load the 7B model and log output.
# Usage: ./run_in_codespace.sh [--model MODEL_ID] [--no-quant] [--log FILE]

MODEL_ID="${1:-${MODEL_ID:-deepseek-ai/DeepSeek-R1-Distill-Qwen-7B}}"
LOGFILE=${2:-logs/loader.log}
NO_QUANT=${3:-}

mkdir -p logs
echo "Creating virtualenv at .venv (if missing)"
python -m venv .venv
. .venv/bin/activate
python -m pip install --upgrade pip setuptools wheel
python -m pip install -r requirements.txt

export MODEL_ID
echo "Starting model load: $MODEL_ID"
if [ "${NO_QUANT}" = "--no-quant" ]; then
  python load_and_test_model.py --no-quant | tee "${LOGFILE}"
else
  python load_and_test_model.py | tee "${LOGFILE}"
fi

echo "Logs written to ${LOGFILE}"
