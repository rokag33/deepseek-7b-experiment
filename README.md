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
python load_and_test_model.py
```

If you get push failures due to a `git-lfs` hook, ensure `git-lfs` is installed inside the Codespace or push with hook bypass:

```bash
git -c core.hooksPath=/dev/null push origin main
```

## Notes
- `quick_run.py` is a small test script that uses a lighter model (distilgpt2) so you can validate environment and code quickly without heavy downloads or GPU.
- The full model in `load_and_test_model.py` uses quantized loading and expects GPU and correct device drivers.
# DeepSeek 7B Experiment

This repository contains a simple environment to load and test the DeepSeek 7B model using 4-bit quantization in a Codespace.

## Files
- `.devcontainer/devcontainer.json`: Codespaces/devcontainer configuration with GPU/CUDA and git-lfs support.
- `requirements.txt`: Python dependencies to install.
- `load_and_test_model.py`: Script that loads the quantized model and runs a sample prompt.

## Launch in Codespaces
1. Open the repo on GitHub, click **Code** → **Codespaces** → **Create codespace on main**.
2. Wait for the Codespace to build (postCreateCommand will install Python dependencies).

## Run locally in the Codespace
```bash
python -m pip install -r requirements.txt
python load_and_test_model.py
```

Notes:
- The devcontainer includes the `git-lfs` feature; Codespaces will install the tool automatically.
- If you run into `git-lfs` pre-push hook issues outside Codespaces, install `git-lfs` on your host or bypass hooks with `git -c core.hooksPath=/dev/null push origin main`.
- Model downloads can be large and require GPU. Consider running in a GPU-enabled Codespace.
