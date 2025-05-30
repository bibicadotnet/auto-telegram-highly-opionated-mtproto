## Telegram MTProto Proxy Installer

This Bash script provides a fast and convenient way to deploy a [Telegram MTProto Proxy](https://core.telegram.org/mtproto/mtproto-proxy) using Docker. It supports both **manual** and **automatic** configuration modes, allowing users to set a custom port and fake domain or let the script randomize them.

### 🚀 Quick Install (Auto Mode)

Just copy and paste this command into your terminal:

```bash
wget -qO mtproto.sh https://go.bibica.net/telegram-mtproto && sudo bash mtproto.sh --auto
```

### Features

* One-command deployment using Docker
* Auto mode with randomized port and fake domain
* Manual mode with user input
* Automatically installs Docker if missing
* Disables firewall rules for compatibility
* Generates a ready-to-use `tg://proxy` link
* Lightweight and fast setup (~5-10 seconds if Docker is already installed)

### Requirements

* A Linux system (Ubuntu, CentOS)
* Root privileges

### Manual Usage

```bash
bash mtproto.sh          # Manual mode
bash mtproto.sh --auto   # Auto mode
```

After installation, your Telegram proxy link will be displayed and saved to `~/telegram-mtproto/mtp.txt`.

### Docker Image Source

This script uses the [nineseconds/mtg](https://hub.docker.com/r/nineseconds/mtg) Docker image.

---
