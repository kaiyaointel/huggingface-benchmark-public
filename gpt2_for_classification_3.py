from transformers import GPT2ForSequenceClassification, GPT2Tokenizer

model = GPT2ForSequenceClassification.from_pretrained("gpt2", num_labels=3)
tokenizer = GPT2Tokenizer.from_pretrained("gpt2")

# Define a padding token
tokenizer.pad_token = tokenizer.eos_token
model.config.pad_token_id = tokenizer.pad_token_id

# Save the model and tokenizer in a directory
model.save_pretrained("./gpt2-model-for-classification_3/")
tokenizer.save_pretrained("./gpt2-model-for-classification_3/")
