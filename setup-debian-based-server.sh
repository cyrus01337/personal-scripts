#!/usr/bin/env bash
set -e

DEBIAN_FRONTEND=noninteractive

_initialise_docker_repository() {
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo groupadd docker
    sudo usermod -aG docker $USER
}

_setup_gh_cli_repository() {
    sudo mkdir -p -m 755 /etc/apt/keyrings \
        && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
        && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
        && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
}

_setup_shell() {
    chsh -s $(which zsh) $USER

    if [[ ! "$GITHUB_USERNAME" ]]; then
        echo "GITHUB_USERNAME not set, skipping dotfiles..."
    else
        sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME

        echo "Shell setup, re-login for changes to take effect..."
    fi
}

sudo apt-get update
sudo apt-get dist-upgrade -y
sudo apt-get install -y ca-certificates curl gpg zsh

_initialise_docker_repository
_setup_gh_cli_repository
_setup_shell

sudo apt-get install -y containerd.io docker-buildx-plugin docker-ce docker-ce-cli docker-compose-plugin gh git
