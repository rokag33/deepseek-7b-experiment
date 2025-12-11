import argparse
import os
import sys


def simulate_response(prompt: str) -> str:
    # Basic, harmless simulated reply for environments without model libs installed
    return (
        "A phase transition is when a substance changes states, like water "
        "turning into vapor or ice. At certain temperatures and pressures, "
        "the arrangement of particles changes suddenly, which we observe "
        "as a transition between states of matter."
    )


def main():
    parser = argparse.ArgumentParser(description='Quick model test script')
    parser.add_argument('--model', type=str, default=os.environ.get('MODEL_ID', 'distilgpt2'), help='HF model ID to load')
    parser.add_argument('--simulate', action='store_true', help='Simulate a model response without importing heavy libraries')
    args = parser.parse_args()

    prompt = "Explain the water cycle in simple terms."

    if args.simulate:
        print("Simulating model response (no dependencies required)")
        print("\n--- Model Response ---")
        print(simulate_response(prompt))
        return

    try:
        import torch
        from transformers import AutoTokenizer, AutoModelForCausalLM
    except Exception as e:
        print("Required packages are not installed:", e)
        print("Run with --simulate to see a sample response, or install requirements first.")
        sys.exit(2)

    model_id = args.model
    print(f"Quick test: loading model {model_id} on device")
    device = 'cuda' if torch.cuda.is_available() else 'cpu'
    print(f"Using device: {device}")

    try:
        tokenizer = AutoTokenizer.from_pretrained(model_id)
        model = AutoModelForCausalLM.from_pretrained(model_id).to(device)
    except Exception as e:
        print("Failed to load model:", e)
        sys.exit(1)

    inputs = tokenizer(prompt, return_tensors='pt').to(device)
    with torch.no_grad():
        outputs = model.generate(**inputs, max_new_tokens=50)
        print("\n--- Model Response ---")
        print(tokenizer.decode(outputs[0], skip_special_tokens=True))


if __name__ == '__main__':
    main()
