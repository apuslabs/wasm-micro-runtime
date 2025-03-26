#!/bin/bash

/usr/bin/expect <<'EOF'
spawn bash -c "LD_LIBRARY_PATH=/usr/local/lib ./build/iwasm --env=\"n_gpu_layers=32\" --env=\"enable_log=true\" ./wasmedge-ggml-qwen.wasm ./qwen1_5-0_5b-chat-q2_k.gguf"

expect {
    -ex "USER:" {
        send "Write a short story of 1000 words starts with 'Once upon a time...'.\r"
        set start_time [clock milliseconds]
    }
    timeout {
        puts stderr "Error: Did not receive USER: prompt within 5 minutes"
        exit 1
    }
}

expect {
    -ex "USER:" {
        set end_time [clock milliseconds]
        set duration [format "%.3f" [expr ($end_time - $start_time)/1000.0]]
        puts "\nGeneration time: $duration seconds"
        send \x03
    }
}

expect eof
EOF
