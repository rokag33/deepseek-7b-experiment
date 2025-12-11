import os
import sys
import torch
from transformers import AutoTokenizer, AutoModelForCausalLM

def main():
    model_id = os.environ.get('MODEL_ID', 'distilgpt2')
    print(f"Quick test: loading model {model_id} on device")

    device = 'cuda' if torch.cuda.is_available() else 'cpu'
    print(f"Using device: {device}")

    try:
        tokenizer = AutoTokenizer.from_pretrained(model_id)
        model = AutoModelForCausalLM.from_pretrained(model_id)
    except Exception as e:
        print("Failed to load model:", e)
        sys.exit(1)

    prompt = "Explain the water cycle in simple terms."
    inputs = tokenizer(prompt, return_tensors='pt').to(device)
    with torch.no_grad():
        outputs = model.generate(**inputs, max_new_tokens=50)
        print("\n--- Model Response ---")
        print(tokenizer.decode(outputs[0], skip_special_tokens=True))

if __name__ == '__main__':
    main()
