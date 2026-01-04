#!/bin/zsh

MODEL="$HOME/models/Qwen2.5-Coder-7B-Instruct.Q2_K.gguf"
LLAMA="$HOME/llama.cpp/build/bin/llama-cli"
PROMPT_FILE="$HOME/llama.cpp/os_agent_prompt.txt"

echo "🧠 macOS AI Agent başlatılıyor..."
echo "Yetki seviyesi: USER + Full Disk Access"
echo "---------------------------------------"

while true; do
    echo
    read -p "🧠 Agent > " USER_INPUT

    [[ "$USER_INPUT" == "exit" ]] && break

    RESPONSE=$(
        echo "$USER_INPUT" | $LLAMA \
            -m "$MODEL" \
            -n 256 \
            -t 2 \
            --prompt-file "$PROMPT_FILE" \
            --simple-io
    )

    echo
    echo "🤖 LLaMA:"
    echo "$RESPONSE"
    echo

    # 🔀 KARAR YÖNLENDİRME
    if echo "$RESPONSE" | grep -q "\[READ_FILE\]"; then
        FILE=$(echo "$RESPONSE" | sed -n 's/.*\[READ_FILE\] \(.*\)/\1/p')
        echo "📄 Dosya okunuyor: $FILE"
        cat "$FILE" | head -n 200
    fi

    if echo "$RESPONSE" | grep -q "\[SHOW_LOGS\]"; then
        echo "📜 Son sistem logları:"
        log show --last 5m --style syslog | tail -n 50
    fi

    if echo "$RESPONSE" | grep -q "\[LIST_APPS\]"; then
        echo "📦 Yüklü uygulamalar:"
        ls /Applications | head
    fi

done

echo "❌ Agent kapatıldı."
