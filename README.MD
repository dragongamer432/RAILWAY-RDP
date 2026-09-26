# 🖥️ Windows 10 in Docker Container

![Docker](https://img.shields.io/badge/Docker-2CA5E0?style=for-the-badge&logo=docker&logoColor=white)
![KVM](https://img.shields.io/badge/KVM-FF6600?style=for-the-badge&logo=linux&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-10-0078D6?style=for-the-badge&logo=windows&logoColor=white)

A Docker container solution for running Windows 10 with KVM acceleration, providing remote access via VNC and RDP.

## 🚀 Getting Started

### Prerequisites
- Docker installed
- KVM enabled system
- Administrative privileges

## 📦 Features

- ⚡ Run Windows 10 inside a Docker container
- 🔒 Secure with isolated environment
- 🖥️ Access via noVNC (web browser) or RDP
- 🚀 Fast virtualization using KVM (requires host support)
- 💾 Persistent storage using Docker volumes

---

## 🛠️ Requirements

- **Linux host** with:
  - KVM enabled (`/dev/kvm` should exist)
  - Docker installed
- **Windows 10 ISO** (for initial installation)
- Modern web browser (for noVNC access)

---

## 🚀 Installation

### 1. Clone the Repository
```bash
git clone https://github.com/dragongamer432/RAILWAY-RDP

cd RAILWAY-RDP


docker build -t windows10-vm .


docker run -it --rm \
  --device /dev/kvm \
  -p 6080:6080 \
  -p 3389:3389 \
  -v windows_data:/data \
  -v windows_iso:/iso \
  windows10-vm
