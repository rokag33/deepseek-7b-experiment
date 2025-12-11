import argparse
import os
import sys

try:
    import torch
except Exception:
    torch = None

try:
    from transformers import AutoModelForCausalLM, AutoTokenizer
except Exception:
    AutoModelForCausalLM = None
    AutoTokenizer = None

try:
    from transformers import BitsAndBytesConfig
except Exception:
    BitsAndBytesConfig = None


def main():
    parser = argparse.ArgumentParser(description='Load and test a HF model (7B recommended for GPU)')
    parser.add_argument('--model', type=str, default=os.environ.get('MODEL_ID', 'deepseek-ai/DeepSeek-R1-Distill-Qwen-7B'), help='HF model ID to load')
    parser.add_argument('--simulate', action='store_true', help='Simulate a response without loading heavy libs')
    parser.add_argument('--no-quant', action='store_true', help='Do not use 4-bit quantization even if supported')
    args = parser.parse_args()

    model_id = args.model
    if args.simulate:
        print(f"Simulated load for model: {model_id}")
        print("This is a simulated run — set --simulate to false and install requirements to run the real model.")
        print("\nSample response:\nPhase transitions occur when a substance changes states; e.g. water to ice.")
        return

    if AutoTokenizer is None or AutoModelForCausalLM is None or torch is None:
        print("Missing required packages: install dependencies using 'pip install -r requirements.txt' or use --simulate.")
        sys.exit(1)

    # Configure optional 4-bit quantization only if available and not explicitly disabled
    quant_config = None
    if BitsAndBytesConfig is not None and not args.no_quant:
        quant_config = BitsAndBytesConfig(
            load_in_4bit=True,
            bnb_4bit_compute_dtype=torch.float16,
            bnb_4bit_quant_type="nf4",
            bnb_4bit_use_double_quant=True,
        )

    print(f"Loading model: {model_id}")
    print("This may take several minutes depending on the model and connection...")

    try:
        tokenizer = AutoTokenizer.from_pretrained(model_id, trust_remote_code=True)
        load_kwargs = dict(trust_remote_code=True, torch_dtype=torch.float16)
        if quant_config is not None:
            load_kwargs['quantization_config'] = quant_config
        load_kwargs['device_map'] = 'auto'
        model = AutoModelForCausalLM.from_pretrained(model_id, **load_kwargs)
    except Exception as e:
        print("Failed to load model:", e)
        print("If you're trying on a local machine, ensure you have appropriate GPU + CUDA drivers, and have installed the requirements.")
        sys.exit(1)

    print("✅ Model and tokenizer loaded successfully!")
    try:
        device_repr = getattr(model, 'device', None) or 'auto'
    except Exception:
        device_repr = 'unknown'
    print(f"Model device: {device_repr}")

    # Quick test
    prompt = "Explain the concept of phase transitions in simple terms."
    inputs = tokenizer(prompt, return_tensors='pt')
    # Move inputs to GPU if a CUDA device is available and the model supports it
    if torch is not None and torch.cuda.is_available():
        inputs = inputs.to('cuda')

    with torch.no_grad():
        outputs = model.generate(**inputs, max_new_tokens=150, do_sample=True)
        print("\n--- Model Response ---")
        print(tokenizer.decode(outputs[0], skip_special_tokens=True))


if __name__ == '__main__':
    main()
