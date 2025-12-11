import torch
from transformers import AutoModelForCausalLM, AutoTokenizer, BitsAndBytesConfig

# Configuration for 4-bit quantization
bnb_config = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_compute_dtype=torch.float16,
    bnb_4bit_quant_type="nf4",
    bnb_4bit_use_double_quant=True
)

# Specify the correct model ID
model_id = "deepseek-ai/DeepSeek-R1-Distill-Qwen-7B" # Use this for a reasoning-optimized 7B model
# model_id = "deepseek-ai/DeepSeek-LLM-7B-Chat" # Alternative: Original chat model

print(f"Loading model: {model_id}")
print("This will take several minutes...")

# Load the tokenizer and model with quantization
tokenizer = AutoTokenizer.from_pretrained(model_id, trust_remote_code=True)
model = AutoModelForCausalLM.from_pretrained(
    model_id,
    quantization_config=bnb_config,
    device_map="auto", # Automatically places layers on available GPU/CPU
    trust_remote_code=True,
    torch_dtype=torch.float16
)

print("✅ Model and tokenizer loaded successfully!")
print(f"Model is on device: {model.device}")
print(f"Model dtype: {model.dtype}")

# Quick test
prompt = "Explain the concept of phase transitions in simple terms."
inputs = tokenizer(prompt, return_tensors="pt").to(model.device)

with torch.no_grad():
    outputs = model.generate(**inputs, max_new_tokens=150, do_sample=True)
    print("\n--- Model Response ---")
    print(tokenizer.decode(outputs[0], skip_special_tokens=True))
