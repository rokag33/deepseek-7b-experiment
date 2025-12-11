
#!/usr/bin/env bash
set -euo pipefail

# Script to run in a GPU-enabled Codespace to load the 7B model and log output.
# Usage: ./run_in_codespace.sh [--model MODEL_ID] [--no-quant] [--log FILE] [--skip-torch] [--cuda 12.1]

MODEL_ID="deepseek-ai/DeepSeek-R1-Distill-Qwen-7B"
LOGFILE="logs/loader.log"
NO_QUANT=""
SKIP_TORCH=""
CUDA_OVERRIDE=""
POSITIONAL=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    --model)
      shift; MODEL_ID=${1:-$MODEL_ID};;
    --log)
      shift; LOGFILE=${1:-$LOGFILE};;
    --no-quant)
      NO_QUANT=1;;
    --skip-torch)
      SKIP_TORCH=1;;
    --cuda)
      shift; CUDA_OVERRIDE=${1:-};;
    -h|--help)
      echo "Usage: $0 [--model MODEL_ID] [--no-quant] [--log FILE] [--skip-torch] [--cuda 12.1]"; exit 0;;
    *)
      POSITIONAL+=($1);;
  esac
  shift || true
done

MODEL_ID=${MODEL_ID:-${MODEL_ID_FROM_ENV:-$MODEL_ID}}
LOGFILE=${LOGFILE}



mkdir -p logs
echo "Creating virtualenv at .venv (if missing)"
python -m venv .venv
. .venv/bin/activate
python -m pip install --upgrade pip setuptools wheel

if [ -z "$SKIP_TORCH" ]; then
  echo "Installing PyTorch wheel matched to CUDA (if present)..."
  if [ -n "$CUDA_OVERRIDE" ]; then
    ./install_torch_wheel.sh --cuda "$CUDA_OVERRIDE"
  else
    ./install_torch_wheel.sh || true
  fi
fi

echo "Installing python dependencies from requirements.txt"
python -m pip install -r requirements.txt

export MODEL_ID
echo "Starting model load: $MODEL_ID"
if [ -n "$NO_QUANT" ]; then
  python load_and_test_model.py --no-quant --model "$MODEL_ID" | tee "${LOGFILE}"
else
  python load_and_test_model.py --model "$MODEL_ID" | tee "${LOGFILE}"
fi

echo "Logs written to ${LOGFILE}"
