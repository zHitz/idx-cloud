# 🛠️ IDX Cloud Workspace Script

A one-shot shell script to automatically configure a fresh Linux server (Ubuntu) on IDX Google with:

- SSH access for root user on custom port (`9022`)
- Docker & containerd services enabled
- Root password set (`123qwe!@#`)
- Tailscale installed and activated (Using for connection) -> Check this [https://tailscale.com/](url)

## 📁 Project Structure

```
server-bootstrap/
├── scripts/
│   └── setup-server.sh      # Main automation script
├── README.md                # You're here
└── .gitignore               # Ignore OS and editor artifacts
```

## 🚀 Usage

### Step 1: Clone this repository

```bash
git clone https://github.com/zHitz/idx-cloud.git
cd idx-cloud/scripts
```

### Step 2: Make the script executable

```bash
chmod +x setup-server.sh
```

### Step 3: Run the script as root

```bash
sudo ./setup-server.sh
```

✅ After this, you can:

- SSH to the server as `root` using password `123qwe!@#`
- Use port `9022` for SSH
- Docker and containerd are active
- Tailscale is installed and ready

> ⚠️ Tailscale will require an authentication step via URL on first run.
```bash
To authenticate, visit:

	https://login.tailscale.com/a/.........
```
---

## 🛡️ Security Notice

⚠️ This script sets a **default root password**: `123qwe!@#`.  
You **must** change it after setup for security:

```bash
passwd
```

### 🔑 Recommended: Use SSH key authentication instead of password

To improve security, disable password-based login and use public/private key authentication.

#### Quick guide:

1. On your local machine, generate an SSH key (if you haven't already):
   ```bash
   ssh-keygen -t ed25519
   ```

2. Copy your public key to the server:
   ```bash
   ssh-copy-id -p 9022 root@your-server-ip
   ```

3. On the server, edit `/etc/ssh/sshd_config`:
   ```ini
   PermitRootLogin prohibit-password
   PasswordAuthentication no
   PubkeyAuthentication yes
   ```

4. Restart the SSH service:
   ```bash
   systemctl restart ssh
   ```

✅ From now on, only machines with your private key can access the server.
