#!/bin/bash

set -e

#COLORS
GREEN='\e[32m'
RED='\e[31m'
YELLOW='\e[33m'
BLUE='\e[34m'
PURPLE='\e[35m'
TURQUOISE='\e[36m'
WHITE='\e[37m'
MAGNETA='\e[35m'
NC='\e[39m'

#DIR
BOT_DIR="$HOME/link2base64_bot"
REPO_DIR="https://github.com/arvinmoradi/convert_link_to_base64.git"


#SERVICE_NAME
SERVICE_NAME='link2base64_bot.service'
VERSION='v1.0.0'

press_key() {
    read -r -p "press key to back main menu..."
}

show_menu() {
  clear
  echo -e "${MAGNETA}===========================${NC}"
  echo -e "${GREEN}Convert Link To Base64${NC}"
  echo -e "${PURPLE}Created by ${BLUE}ArM${NC}"
  echo -e "${BLUE}Telegram: @ArvinMoradi${NC}"
  echo -e "Version: ${VERSION}"
  echo -e "${MAGNETA}===========================${NC}"
  echo -e "1) Install"
  echo -e "2) Update"
  echo -e "3) Restart"
  echo -e "4) Set Cronjob"
  echo -e "5) Uninstall"
  echo -e "0) Exit"
  echo -e "${MAGNETA}===========================${NC}"
  read -r -p "Choose: " choice
}

install() {
  echo -e "${BLUE}Updating Packages...${NC}"
  sudo apt update -y >/dev/null 2>&1
  echo -e "${BLUE}Installing Packages...${NC}"
  sudo apt-get install python3 python3-venv python3-pip git >/dev/null 2>&1

  sudo mkdir -p "${BOT_DIR}"
  cd "${BOT_DIR}"

  echo -e "${BLUE}Installing...${NC}"
  git clone "${REPO_DIR}" . >/dev/null 2>&1 || { echo "❌ Clone failed"; exit 1; }
  echo -e "${BLUE}Create Virtual Environment...${NC}"
  python3 -m  venv venv
  source venv/bin/activate

  echo -e "${GREEN}Installing requitements...${NC}"
  pip install --upgrade pip >/dev/null
  pip install -r requitements.txt >/dev/null
  
  if [ -f "$BOT_DIR/.env.example" ] && [ ! -f "$BOT_DIR/.env" ]; then
      cp "${BOT_DIR}/.evn.example" "${BOT_DIR}/.env"
      echo -e "✅ .env created"
  else
      echo -e "️ Skipping .env creation (already exists or .env.example missing)"
  fi

  echo -e "⚙️ ${BLUE}Creating systemd service...${NC}"
  SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}"
  sudo tee $SERVICE_FILE > /dev/null <<EOF
[Unit]
Description= Convert Link to Base64
After=network.target

[Service]
User=root
WorkingDirectory=$BOT_DIR
ExecStart=$BOT_DIR/venv/bin/python3 $BOT_DIR/main.py
Restart=always
RestartSec=10
EnvironmentFile=/root/link2base64_bot/.env

[Install]
WantedBy=multi-user.target
EOF

  sudo sed -i 's/^[[:space:]]*//' $SERVICE_FILE
  echo -e "🔹 Enabling and starting service..."
  sudo systemctl daemon-reload
  sudo systemctl enable "${SERVICE_NAME}"
  sudo systemctl start "${SERVICE_NAME}"

  echo -e "✅ ${GREEN}Bot installed and service created successfully!${NC}"
  deactive

  status="${GREEN}INSTALLED${NC}"
  echo -e "Before doing anything else, you must first edit the .env file"
  echo -e "${PURPLE}nano ${BOT_DIR}/.env${NC}"
  press_key
}

while true; do
  show_menu
  case $choice in
    1) install ;;
    2) update ;;
    3) restart ;;
    4) set_cronjob ;;
    5) uninstall ;;
    6) echo "Exit..."; exit 0 ;;
    *) echo "Invalid Choice"; sleep 2 ;;
  esac

done
