import subprocess
import gradio as gr

LLAMA_BIN = "/Users/szar/llama.cpp/build/bin/llama-cli"
MODEL = "/Users/szar/models/Qwen2.5-Coder-7B-Instruct.Q2_K.gguf"

def chat(prompt, history):
    full_prompt = ""
    for user, assistant in history:
        full_prompt += f"User: {user}\nAssistant: {assistant}\n"
    full_prompt += f"User: {prompt}\nAssistant:"

    cmd = [
        LLAMA_BIN,
        "-m", MODEL,
        "-c", "2048",
        "-t", "3",
        "--temp", "0.7",
        "--top-p", "0.9",
        "-p", full_prompt
    ]

    result = subprocess.run(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True
    )

    output = result.stdout.split("Assistant:")[-1].strip()
    history.append((prompt, output))
    return history, history

with gr.Blocks(title="Local LLaMA Chat") as demo:
    gr.Markdown("## 🦙 Local LLaMA Chat (llama.cpp)")
    chatbot = gr.Chatbot()
    msg = gr.Textbox(label="Mesajın")
    clear = gr.Button("Temizle")

    msg.submit(chat, [msg, chatbot], [chatbot, chatbot])
    clear.click(lambda: [], None, chatbot)

demo.launch()
