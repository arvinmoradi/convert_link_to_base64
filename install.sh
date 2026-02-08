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

check_status() {
  if [ -d "${BOT_DIR}" ] && [ -d "${BOT_DIR}/.git" ]; then
    return 0
  else
    return 1
  fi
}

if check_status; then
  status="${GREEN}INSTALLED${NC}"
else
  status="${RED}NOT INSTALLED${NC}"
fi

show_menu() {
  clear
  echo -e "${MAGNETA}===========================${NC}"
  echo -e "${GREEN}Convert Link To Base64${NC}"
  echo -e "${PURPLE}Created by ${BLUE}ArM${NC}"
  echo -e "${BLUE}Telegram: @ArvinMoradi${NC}"
  echo -e "${TURQUOISE}Status: ${status}${NC}"
  echo -e "Version: ${VERSION}"
  echo -e "${MAGNETA}===========================${NC}"
  echo -e "1) Install"
  echo -e "2) Update"
  echo -e "3) Restart"
  echo -e "4) Uninstall"
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

  echo -e "${GREEN}Installing requirements...${NC}"
  pip install --upgrade pip >/dev/null
  pip install -r requirements.txt >/dev/null
  
  if [ -f "$BOT_DIR/.env.example" ] && [ ! -f "$BOT_DIR/.env" ]; then
      cp "${BOT_DIR}/.env.example" "${BOT_DIR}/.env"
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
  deactivate

  status="${GREEN}INSTALLED${NC}"
  echo -e "Before doing anything else, you must first edit the .env file"
  echo -e "${PURPLE}nano ${BOT_DIR}/.env${NC}"
  press_key
}

update() {
  if check_status; then
    echo -e "🚀 ${BLUE}Updating bot...${NC}"
    cd "$BOT_DIR"
    source venv/bin/activate >/dev/null 2>&1
    git pull origin main
    pip install --upgrade -r requirements.txt >/dev/null 2>&1
    deactivate
    sudo systemctl daemon-reload
    sudo systemctl restart $SERVICE_NAME
    echo -e "✅ ${GREEN}Update completed!${NC}"
  else
    read -r -p "❌ Bot not installed. Do you want to install it now? (y/n): " ans
    if [[ $ans == 'y'  ||  $ans == 'y' ]]; then
      install
    fi
  fi
  press_key
}

restart() {
    if check_status; then
        echo -e "🔄️ ${BLUE}Restarting bot...${NC}"
        sudo systemctl daemon-reload
        sudo systemctl restart $SERVICE_NAME
        echo -e "✅ ${GREEN}Restart is Done${NC}"
        press_key
    else
        read -r -p "❌ Bot not installed. Do you want to install it now? (y/n): " ans
        if [[ $ans == "y" || $ans == "Y" ]]; then
            install_bot
        else
            press_key
        fi
    fi
}

uninstall() {
    if check_status; then
        echo -e "🗑 ${RED}Uninstalling bot...${NC}"
        read -r -p "Do you want to uninstall (y/n) ? " ans
        if [[ "$ans" == "y" || "$ans" == 'Y' ]]; then
            if systemctl list-units --full -all | grep -Fq "$SERVICE_NAME"; then
                sudo systemctl stop $SERVICE_NAME
                sudo systemctl disable $SERVICE_NAME
                sudo rm -f /etc/systemd/system/$SERVICE_NAME
                sudo systemctl daemon-reload
            fi
            rm -rf $BOT_DIR
            echo -e "✅ ${GREEN}Directory is Remove${NC}"
            crontab -l 2>/dev/null | grep -v "sender.py" | crontab -
            echo -e "✅ ${GREEN}Bot completely uninstalled!${NC}"
            cd $HOME
        else
            return
        fi
    else
        echo -e "❌ ${RED}Nothing to uninstall${NC}"
    fi

    status="${RED}NOT INSTALLED${NC}"

    press_key
}

while true; do
  show_menu
  case $choice in
    1) install ;;
    2) update ;;
    3) restart ;;
    4) uninstall ;;
    0) echo "Exit..."; exit 0 ;;
    *) echo "Invalid Choice"; sleep 2 ;;
  esac
done
