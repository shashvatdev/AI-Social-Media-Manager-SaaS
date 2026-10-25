#!/usr/bin/env bash
# ==============================================================================
# Autonomous AI Social Media Manager SaaS - Master Launcher
# ==============================================================================

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$DIR"

# Editorial Banner
echo -e "\033[1;33m"
cat << "EOF"
    ___    ___   ____             _       _      _    ___ 
   / _ \  |_ _| / ___|  ___   ___(_) __ _| |    / \  |_ _|
  / /_\ \  | |  \___ \ / _ \ / __| |/ _` | |   / _ \  | | 
 / /   \ \ | |   ___) | (_) | (__| | (_| | |  / ___ \ | | 
/_/     \_\___| |____/ \___/ \___|_|\__,_|_| /_/   \_\___|

     AUTONOMOUS AI CONTENT LEAD & CREATIVE DIRECTOR
EOF
echo -e "\033[0m"

echo -e "\033[1;36m[1/4] Checking Python Virtual Environment...\033[0m"
if [ ! -d "venv" ]; then
    echo "Virtual environment not found. Creating venv..."
    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
else
    source venv/bin/activate
fi

echo -e "\033[1;36m[2/4] Verifying Environment Credentials...\033[0m"
if [ ! -f ".env" ]; then
    echo -e "\033[1;31m[!] .env not found. Copying .env.example...\033[0m"
    cp .env.example .env
fi

# Cleanup handler on exit
cleanup() {
    echo -e "\n\033[1;33mShutting down services gracefully...\033[0m"
    if [ ! -z "$BACKEND_PID" ]; then
        kill $BACKEND_PID 2>/dev/null || true
    fi
    exit 0
}
trap cleanup SIGINT SIGTERM

echo -e "\033[1;36m[3/4] Launching FastAPI Backend & Autonomous Scheduler...\033[0m"
uvicorn app.main:app --port 8000 &
BACKEND_PID=$!

# Wait for backend to be ready
echo "Waiting for backend at http://127.0.0.1:8000/health..."
for i in {1..30}; do
    if curl -s http://127.0.0.1:8000/health > /dev/null 2>&1; then
        echo -e "\033[1;32m✓ Backend & Autonomous Scheduler are LIVE!\033[0m"
        break
    fi
    sleep 1
done

echo -e "\033[1;36m[4/4] Launching Flutter Luxury Editorial Client...\033[0m"
cd frontend
export PATH="/opt/homebrew/bin:$PATH"

TARGET_DEVICE="macos"
if ! flutter devices | grep -q "macOS"; then
    TARGET_DEVICE="chrome"
fi

echo -e "\033[1;32mLaunching on $TARGET_DEVICE...\033[0m"
flutter run -d "$TARGET_DEVICE"

wait $BACKEND_PID
