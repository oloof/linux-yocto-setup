#!/usr/bin/env bash
# yocto-host-install.sh
# Generic Yocto build-host install for Ubuntu/Debian based OS
echo 
echo "This script also check for at least 140GB of disk space and 32GB of RAM"
echo "If you intend to run the program with less than 32GB of RAM, please modify the shell prompt"

set -euo pipefail

YOCTO_WORKDIR="${YOCTO_WORKDIR:-$HOME/yocto-work}"
YOCTO_CACHE_DIR="${YOCTO_CACHE_DIR:-$HOME/yocto-cache}"

MIN_DISK_GB=140

#MODIFY THE MINIMUM RAM HERE ps: it actuall does nothing as it will just be a warning msg
RECOMENDED_RAM_GB=32

# 1. Checking OS

if [[ -f /etc/os-release ]]; then
	. /etc/os-release
	echo "Detected OS: ${PRETTY_NAME:-unknown}"
else
	echo "ERROR: CANNOT DETECT OS, THIS SCRIPT IS FOR DEBIAN BASED LINUX ONLY"
	exit 1
fi

case "${ID:-}" in
	ubuntu|debian)
	echo "OS family OK: $ID"
	;;
	*)
	echo "WARNING: THIS SCRIPT IS FOR DEBIAN BASED LINUX. DETECTED: ${ID:-unknown}"
	echo "Continue only if you are sure this machine is compatible"
	;;
esac

#2. Hardware Info
CPU_CORES="$(nproc)"
RAM_GB="$(awk '/MemTotal/ {printf "%.0f", $2/1024/1024}' /proc/meminfo)"
DISK_AVAIL_GB="$(df -BG "$HOME" |awk 'NR==2 {gsub("G","",$4); print $4}')"

echo "CPU cores: $CPU_CORES"
echo "RAM:       ${RAM_GB} GB"
echo "DISK:      ${DISK_AVAIL_GB} at $HOME"

if (( RAM_GB < RECOMMENDED_RAM_GB )); then
    echo "WARNING: RAM is below ${RECOMMENDED_RAM_GB} GB. Yocto may build, but it will be slow or memory-constrained."
fi

if (( DISK_AVAIL_GB < MIN_DISK_GB )); then
    echo "WARNING: Free disk is below ${MIN_DISK_GB} GB. Large Yocto builds may fail or run out of space."
fi


# 3. Install required packages

echo "Installing Yocto host packages..."

sudo apt update

sudo apt install -y \
    build-essential \
    chrpath \
    cpio \
    debianutils \
    diffstat \
    file \
    gawk \
    gcc \
    git \
    iputils-ping \
    libacl1 \
    libcrypt-dev \
    locales \
    python3 \
    python3-git \
    python3-jinja2 \
    python3-pexpect \
    python3-pip \
    python3-subunit \
    socat \
    texinfo \
    unzip \
    wget \
    xz-utils \
    zstd

# python3-websockets is useful on newer supported Debian/Ubuntu hosts.
# On some older distro versions, the packaged version may be too old for some Yocto sstate mirror features.
if apt-cache show python3-websockets >/dev/null 2>&1; then
    sudo apt install -y python3-websockets || true
fi

# -----------------------------
# 4. Enable en_US.UTF-8 locale
# -----------------------------
echo "Checking en_US.UTF-8 locale..."

if locale -a | grep -qi '^en_US\.utf8$'; then
    echo "Locale already enabled: en_US.UTF-8"
else
    echo "Enabling en_US.UTF-8..."
    if ! grep -q '^en_US.UTF-8 UTF-8' /etc/locale.gen; then
        echo 'en_US.UTF-8 UTF-8' | sudo tee -a /etc/locale.gen >/dev/null
    else
        sudo sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
    fi
    sudo locale-gen en_US.UTF-8
fi


# 5. Create workspace/cache dirs

echo "Creating Yocto workspace/cache directories..."

mkdir -p "$YOCTO_WORKDIR"
mkdir -p "$YOCTO_CACHE_DIR/downloads"
mkdir -p "$YOCTO_CACHE_DIR/sstate-cache"

cat > "$YOCTO_WORKDIR/yocto-env-paths.sh" <<EOF
# Source this file before running your Genio-specific setup/build scripts if needed.
export YOCTO_WORKDIR="$YOCTO_WORKDIR"
export YOCTO_CACHE_DIR="$YOCTO_CACHE_DIR"
export DL_DIR="$YOCTO_CACHE_DIR/downloads"
export SSTATE_DIR="$YOCTO_CACHE_DIR/sstate-cache"
EOF


# 6. Final report

echo
echo "== Generic Yocto host setup complete =="
echo "Workspace:      $YOCTO_WORKDIR"
echo "Downloads:      $YOCTO_CACHE_DIR/downloads"
echo "Sstate cache:   $YOCTO_CACHE_DIR/sstate-cache"
echo
echo "Next step:"
echo "  source $YOCTO_WORKDIR/yocto-env-paths.sh"
echo "  then run the Genio 520-specific BSP/layer setup script."


	 
