#!/bin/bash

# Função para detectar o gerenciador de pacotes
detect_package_manager() {
    if command -v apt &> /dev/null; then
        PACKAGE_MANAGER="apt"
    elif command -v dnf &> /dev/null; then
        PACKAGE_MANAGER="dnf"
    elif command -v pacman &> /dev/null; then
        PACKAGE_MANAGER="pacman"
    elif command -v zypper &> /dev/null; then
        PACKAGE_MANAGER="zypper"
    elif command -v yay &> /dev/null; then
        PACKAGE_MANAGER="yay"
    else
        echo "Nenhum gerenciador de pacotes compatível encontrado."
        exit 1
    fi
}

# Função para instalar pacotes usando o gerenciador de pacotes detectado
install_packages() {
    case $PACKAGE_MANAGER in
        apt)
            sudo apt update
            sudo apt install -y "$@"
            ;;
        dnf)
            sudo dnf install -y "$@"
            ;;
        pacman)
            sudo pacman -Syu --noconfirm "$@"
            ;;
        zypper)
            sudo zypper refresh
            sudo zypper install -y "$@"
            ;;
        yay)
            yay -Syu --noconfirm "$@"
            ;;
        *)
            echo "Gerenciador de pacotes não suportado."
            exit 1
            ;;
    esac
}

# Detectar o gerenciador de pacotes
detect_package_manager

# Atualizar o sistema e instalar Zsh
echo "Atualizando o sistema e instalando Zsh..."
install_packages zsh curl wget git unzip fontconfig

# Instalar Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Instalando Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Baixar e instalar a fonte Nerd Font MesloLGS
echo "Baixando e instalando a fonte Nerd Font MesloLGS..."
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/Meslo.zip -O Meslo.zip
unzip Meslo.zip -d "$FONT_DIR"
rm Meslo.zip
fc-cache -fv

# Instalar o tema Powerlevel10k
echo "Instalando o tema Powerlevel10k..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
sed -i 's/ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc

# Instalar plugins zsh-autosuggestions e zsh-syntax-highlighting
echo "Instalando plugins zsh-autosuggestions e zsh-syntax-highlighting..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Adicionar os plugins ao .zshrc
sed -i 's/plugins=(.*)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc

# Baixar e instalar o tema Dracula Gtk Theme
echo "Baixando e instalando o Dracula Gtk Theme..."
THEME_DIR="$HOME/.themes"
mkdir -p "$THEME_DIR"
git clone https://github.com/dracula/gtk.git "$THEME_DIR/Dracula"
gsettings set org.gnome.desktop.interface gtk-theme "Dracula"

# Baixar e instalar os ícones Kora
echo "Baixando e instalando os ícones Kora..."
ICON_DIR="$HOME/.icons"
mkdir -p "$ICON_DIR"
git clone https://github.com/bikass/kora.git "$ICON_DIR/Kora"
gsettings set org.gnome.desktop.interface icon-theme "Kora"

# Trocar o shell padrão para Zsh
echo "Trocando o shell padrão para Zsh..."
chsh -s $(which zsh)

echo "Operação concluída! Reinicie seu terminal para ver as mudanças."
