#!/bin/bash

# Colors for output
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
RED="\e[31m"
RESET="\e[0m"

# Header & Footer
print_header() {
    echo -e "${CYAN}"
    echo "============================================"
    echo "         🔧 SERVER AUTO CONFIG SCRIPT        "
    echo "============================================"
    echo -e "${RESET}"
}

print_footer() {
    echo -e "${CYAN}"
    echo "============================================"
    echo "      ✅ SETUP COMPLETED SUCCESSFULLY       "
    echo "============================================"
    echo -e "${RESET}"
}

# Logging Steps
print_step() { echo -e "${YELLOW}▶️  $1${RESET}"; }
print_success() { echo -e "${GREEN}✔ $1${RESET}"; }
print_error() { echo -e "${RED}✖ $1${RESET}"; }

# Start
print_header

### STEP 1: SSH Configuration ###
print_step "Configuring SSH to allow root login and password authentication..."

SSHD_CONFIG="/etc/ssh/sshd_config"

# Backup existing SSH config
cp $SSHD_CONFIG ${SSHD_CONFIG}.bak

# Update settings
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' $SSHD_CONFIG
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' $SSHD_CONFIG
sed -i 's/^#\?UsePAM.*/UsePAM no/' $SSHD_CONFIG
sed -i 's/^#\?Port.*/Port 9022/' $SSHD_CONFIG

# Add settings if missing
grep -q "^PermitRootLogin" $SSHD_CONFIG || echo "PermitRootLogin yes" >> $SSHD_CONFIG
grep -q "^PasswordAuthentication" $SSHD_CONFIG || echo "PasswordAuthentication yes" >> $SSHD_CONFIG
grep -q "^UsePAM" $SSHD_CONFIG || echo "UsePAM no" >> $SSHD_CONFIG
grep -q "^Port" $SSHD_CONFIG || echo "Port 9022" >> $SSHD_CONFIG

print_success "SSH configuration updated"

### STEP 2: Unmask & Restart SSH ###
print_step "Unmasking and restarting SSH service..."

systemctl unmask ssh >/dev/null 2>&1
systemctl unmask ssh.socket >/dev/null 2>&1
systemctl enable ssh >/dev/null 2>&1
systemctl restart ssh ssh.socket 2>&1
systemctl restart ssh.socket 2>&1
systemctl restart ssh && print_success "SSH service restarted" || print_error "Failed to restart SSH"

### STEP 3: Change root password ###
print_step "Changing root password..."

echo "root:123qwe!@#" | chpasswd && print_success "Root password changed to '123qwe!@#'" || print_error "Failed to change root password"

### STEP 4: Docker & containerd ###
print_step "Unmasking and starting Docker & containerd..."

systemctl unmask docker >/dev/null 2>&1
systemctl unmask docker.socket >/dev/null 2>&1
systemctl unmask containerd >/dev/null 2>&1
systemctl enable docker>/dev/null 2>&1
systemctl restart docker && print_success "Docker & containerd restarted" || print_error "Failed to start Docker/containerd"

### STEP 5: Install and start Tailscale ###
print_step "Checking Tailscale installation..."

if ! command -v tailscale &>/dev/null; then
    print_step "Tailscale not found. Installing..."
    curl -fsSL https://tailscale.com/install.sh >/dev/null 2>&1 | sh && print_success "Tailscale installed"
    systemctl start tailscaled >/dev/null 2>&1
    
else
    print_success "Tailscale is already installed"
fi

print_step "Enabling and starting tailscaled service..."
systemctl enable --now tailscaled && print_success "tailscaled service enabled" || print_error "Failed to enable tailscaled"

print_step "Bringing up Tailscale (you may need to authenticate)..."
tailscale up

### DONE ###
print_footer
