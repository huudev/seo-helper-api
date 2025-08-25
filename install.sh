#!/bin/bash

set -e  # Dừng nếu có lỗi

REPO_URL="https://github.com/huudev/seo-helper-api.git"
CLONE_DIR="seo-helper-api"
INSTALL_OK_FILE="install.ok"

echo "🚀 Bắt đầu cài đặt..."

# --- Clone repo ---
if [ ! -d "$CLONE_DIR" ]; then
  echo "📥 Đang clone repository..."
  git clone "$REPO_URL" "$CLONE_DIR"
fi

cd "$CLONE_DIR"

# Nếu đã cài rồi thì bỏ qua
if [ -f "$INSTALL_OK_FILE" ]; then
  echo "✅ Đã cài đặt trước đó, bỏ qua bước cài đặt."
else
  # --- Cài Cloudflare Tunnel ---
  echo "🌐 Đang cài cloudflared..."
  sudo curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared
  sudo chmod +x /usr/local/bin/cloudflared
  
  # --- Cài Python 3.10 ---
  echo "🐍 Đang cài đặt Python 3.10..."
  sudo apt update
  sudo apt install -y software-properties-common
  sudo add-apt-repository -y ppa:deadsnakes/ppa
  sudo apt update
  sudo apt install -y python3.10 python3.10-venv python3.10-dev

  # --- Tạo virtualenv ---
  echo "📦 Đang tạo virtual environment..."
  python3.10 -m venv .venv
  source .venv/bin/activate

  # --- Cài requirements.txt ---
  echo "📚 Đang cài đặt requirements.txt..."
  pip install --upgrade pip
  pip install -r requirements.txt

  # --- Đánh dấu đã cài ---
  touch "$INSTALL_OK_FILE"
  echo "✅ Cài đặt hoàn tất!"
fi

# --- Kích hoạt venv và chạy server ---
echo "🚀 Đang khởi động server..."
source .venv/bin/activate
uvicorn app.main:app --host 0.0.0.0 --port 8000 &

# --- Publish với Cloudflare Tunnel ---
echo "🌍 Đang publish port 8000 qua Cloudflare Tunnel..."
cloudflared tunnel --url http://localhost:8000
