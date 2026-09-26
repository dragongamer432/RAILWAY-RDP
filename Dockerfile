FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive


RUN apt-get update && apt-get install -y --no-install-recommends \
    qemu-system-x86 \
    qemu-utils \
    novnc \
    websockify \
    wget \
    curl \
    net-tools \
    unzip \
    python3 \
    && rm -rf /var/lib/apt/lists/*


RUN mkdir -p /data /iso /novnc


RUN wget https://github.com/novnc/noVNC/archive/refs/heads/master.zip -O /tmp/novnc.zip && \
    unzip /tmp/novnc.zip -d /tmp && \
    mv /tmp/noVNC-master/* /novnc && \
    rm -rf /tmp/novnc.zip /tmp/noVNC-master


ENV ISO_URL="https://archive.org/download/windows-10-lite-edition-19h2-x64/Windows%2010%20Lite%20Edition%2019H2%20x64.iso"


RUN echo '#!/bin/bash\n\
set -e\n\
\n\
# Check for KVM support\n\
if [ -e /dev/kvm ]; then\n\
  echo "✅ KVM acceleration available"\n\
  KVM_ARG="-enable-kvm"\n\
  CPU_ARG="host"\n\
  MEMORY="4G"\n\
  SMP_CORES=4\n\
else\n\
  echo "⚠️  KVM not available - using slower emulation mode"\n\
  KVM_ARG=""\n\
  CPU_ARG="qemu64"\n\
  MEMORY="2G"\n\
  SMP_CORES=1\n\
fi\n\
\n\
# Download ISO if needed\n\
if [ ! -f "/iso/os.iso" ]; then\n\
  echo "📥 Downloading Windows 10 ISO..."\n\
  wget -q --show-progress "$ISO_URL" -O "/iso/os.iso"\n\
fi\n\
\n\
# Create disk image if not exists\n\
if [ ! -f "/data/disk.qcow2" ]; then\n\
  echo "💽 Creating 100GB virtual disk..."\n\
  qemu-img create -f qcow2 "/data/disk.qcow2" 100G\n\
fi\n\
\n\
# Windows-specific boot parameters\n\
BOOT_ORDER="-boot order=c,menu=on"\n\
if [ ! -s "/data/disk.qcow2" ] || [ $(stat -c%s "/data/disk.qcow2") -lt 1048576 ]; then\n\
  echo "🚀 First boot - installing Windows from ISO"\n\
  BOOT_ORDER="-boot order=d,menu=on"\n\
fi\n\
\n\
echo "⚙️ Starting Windows 10 VM with ${SMP_CORES} CPU cores and ${MEMORY} RAM"\n\
\n\
# Start QEMU with Windows-optimized settings\n\
qemu-system-x86_64 \\\n\
  $KVM_ARG \\\n\
  -machine q35,accel=kvm:tcg \\\n\
  -cpu $CPU_ARG \\\n\
  -m $MEMORY \\\n\
  -smp $SMP_CORES \\\n\
  -vga std \\\n\
  -usb -device usb-tablet \\\n\
  $BOOT_ORDER \\\n\
  -drive file=/data/disk.qcow2,format=qcow2 \\\n\
  -drive file=/iso/os.iso,media=cdrom \\\n\
  -netdev user,id=net0,hostfwd=tcp::3389-:3389 \\\n\
  -device e1000,netdev=net0 \\\n\
  -display vnc=:0 \\\n\
  -name "Windows10_VM" &\n\
\n\
# Start noVNC\n\
sleep 5\n\
websockify --web /novnc 6080 localhost:5900 &\n\
\n\
echo "===================================================="\n\
echo "🌐 Connect via VNC: http://localhost:6080"\n\
echo "🔌 After install, use RDP: localhost:3389"\n\
echo "❗ First boot may take 20-30 minutes for Windows install"\n\
echo "===================================================="\n\
\n\
tail -f /dev/null\n' > /start.sh && chmod +x /start.sh

VOLUME ["/data", "/iso"]
EXPOSE 6080 3389
CMD ["/start.sh"]
