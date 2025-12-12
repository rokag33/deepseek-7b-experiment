# deepseek-7b-experiment

Lightweight repo to test loading a 7B model with quantization in a Codespace.

## Quick Start (Codespaces)

1. Click **Code → Codespaces → Create codespace on main** to start the environment.
2. Wait for the Codespace to build. It will run the post-create command which installs requirements and attempts to install `git-lfs`.
3. Open a terminal and run a quick test with a CPU-friendly small model (recommended for testing):

```bash
python quick_run.py
```

4. To run the main suggested script with the 7B model (requires GPU and HF access):

```bash
# Option 1: Use CLI arg (recommended for quick testing with smaller models):
python load_and_test_model.py --model distilgpt2

# Option 2: Run with the default 7B model (may require GPU and auth):
python load_and_test_model.py

# Option 3: Simulate a response without model dependencies (for quick environment checks):
python load_and_test_model.py --simulate
```

If you prefer the original minimal script (no CLI flags), use `load_and_test_model_simple.py`:
```bash
python load_and_test_model_simple.py
```

If you get push failures due to a `git-lfs` hook, ensure `git-lfs` is installed inside the Codespace or push with hook bypass:

```bash
git -c core.hooksPath=/dev/null push origin main
```

## Notes
- `quick_run.py` is a small test script that uses a lighter model (distilgpt2) so you can validate environment and code quickly without heavy downloads or GPU.
- `load_and_test_model.py` accepts `--model`, `--simulate`, and `--no-quant` flags and reads `MODEL_ID` from the environment if set. Below are environment variable examples.

### Environment variable example
Set the model via an environment variable and run the loader (Linux/macOS):

```bash
export MODEL_ID=deepseek-ai/DeepSeek-R1-Distill-Qwen-7B
python load_and_test_model.py
```

For testing with a smaller model:

```bash
export MODEL_ID=distilgpt2
python load_and_test_model.py
```

### 7B Model Notes
- Loading the 7B model with 4-bit quantization (`BitsAndBytesConfig`) requires `bitsandbytes` and a CUDA-enabled GPU. If these are missing, use `--simulate` or test with `distilgpt2`.
- If you hit device or memory errors, run with `--no-quant` or test with a smaller model ID.

### Running in a GPU Codespace (recommended)

1. Create a GPU-enabled Codespace: GitHub -> Code -> Codespaces -> Create codespace on main. Choose a machine with GPU support (e.g., Standard_NV12 or similar) if available on your account.
2. Wait for the devcontainer to finish building (it will install `git-lfs` and Python packages).
3. Open a terminal inside the Codespace and run the helper script to create a venv, install packages, attempt the model load, and capture logs. The script will try to detect CUDA via `nvidia-smi` and install a matching PyTorch wheel; use `--cuda` to override if detection fails:

```bash
# Run with automatic torch wheel installation (detects CUDA):
./run_in_codespace.sh

# Provide a specific CUDA version if detection fails (example: 12.1):
./run_in_codespace.sh --cuda 12.1

# Skip torch install if you already installed it in your venv:
./run_in_codespace.sh --skip-torch
```

## CI and GPU-run workflows

- **CI** runs `quick_run.py --simulate` across Python 3.10 and 3.11 on push or PR to `main` and validates non-torch dependencies. See [.github/workflows/ci.yml](.github/workflows/ci.yml#L1-L25).
- **GPU Run** is a manual workflow designed to run on a self-hosted GPU runner. Trigger it in GitHub Actions (Actions → GPU Run) with `model_id`, `no_quant`, and optional `cuda` input to run the full 7B loader. See [.github/workflows/gpu_run.yml](.github/workflows/gpu_run.yml#L1-L40).

Notes:
- GPU-run requires a self-hosted runner labeled with `gpu` for the job to run on your hardware. Follow GitHub docs to register a self-hosted runner: https://docs.github.com/en/actions/hosting-your-own-runners.
- The GPU-run workflow will attempt to detect CUDA and install a matching `torch` wheel; if detection fails, provide `cuda` input (e.g., `12.1`).
- **Optional**: If you want the workflow to upload `logs/loader.log` as a private Gist for easier sharing, add a repository secret named `GIST_TOKEN` containing a personal access token (scope: `gist`) and set `upload_gist` to true when you run the workflow. The workflow will print the new Gist URL when the upload completes.

Notes:
- GPU-run requires a self-hosted runner labeled with `gpu` for the job to run on your hardware. Follow GitHub docs to register a self-hosted runner: https://docs.github.com/en/actions/hosting-your-own-runners.
- The GPU-run workflow will attempt to detect CUDA and install a matching `torch` wheel; if detection fails, provide `cuda` input (e.g., `12.1`).

To run without 4-bit quantization if you experience memory or device errors:

```bash
./run_in_codespace.sh --no-quant
```

Logs will be written to `logs/loader.log`. If you'd like me to verify the logs or further troubleshoot, paste them here and I can help analyze.

### Sharing logs (easy)
After running `./run_in_codespace.sh`, use `collect_logs.sh` to print the final lines and optionally upload as a private gist (requires `GITHUB_TOKEN`):

```bash
# show last 200 lines
./collect_logs.sh --tail 200

# show the last 500 lines
./collect_logs.sh --tail 500

# upload full loader log as private gist (set GITHUB_TOKEN first):
GITHUB_TOKEN=ghp_xxx ./collect_logs.sh --upload
```

If you prefer not to use gists, paste the last 500 lines of `logs/loader.log` into the conversation and I can analyze them.
# DeepSeek 7B Experiment

This repository contains a simple environment to load and test the DeepSeek 7B model using 4-bit quantization in a Codespace.

## Files
- `.devcontainer/devcontainer.json`: Codespaces/devcontainer configuration with GPU/CUDA and git-lfs support.
- `requirements.txt`: Python dependencies to install.
- `load_and_test_model.py`: Script that loads the quantized model and runs a sample prompt.

## Launch in Codespaces
1. Open the repo on GitHub, click **Code** → **Codespaces** → **Create codespace on main**.
2. Wait for the Codespace to build (postCreateCommand will install Python dependencies).

Note: By default, this repo uses the improved devcontainer configuration at `.devcontainer/devcontainer.json` which installs git-lfs, attempts robust pip setup, and detects CUDA for torch wheel installation. If you prefer the original minimal devcontainer, use the optional `.devcontainer/devcontainer.simple.json` (rename to `devcontainer.json` to use it).

## Run locally in the Codespace
```bash
python -m pip install -r requirements.txt
python load_and_test_model.py
```

Notes:
- The devcontainer includes the `git-lfs` feature; Codespaces will install the tool automatically.
- If you run into `git-lfs` pre-push hook issues outside Codespaces, install `git-lfs` on your host or bypass hooks with `git -c core.hooksPath=/dev/null push origin main`.
- Model downloads can be large and require GPU. Consider running in a GPU-enabled Codespace.
