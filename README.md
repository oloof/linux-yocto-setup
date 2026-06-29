# Yocto Host Setup Scripts

This repository contains shell scripts for setting up a Linux host machine for Yocto Project builds.

The current focus is preparing a generic Yocto build environment. Board-specific setup, such as MediaTek Genio 520 BSP/layer configuration, should be handled separately.

The current build is an untested collection of shell command, run at your own risk

## Purpose

This repo is intended to make Yocto build-host setup repeatable across different machines, such as:

* office build server
* private Linux machine
* temporary test VM

The script installs required host packages, prepares locale settings, and creates reusable Yocto workspace/cache directories.

## Repository Structure

```text
.
├── yocto-host-install.sh      # Generic Yocto host dependency setup
├── README.md                     # Project documentation
├── LICENSE                     # LICENSE
└── .gitignore                    # Prevents build/cache artifacts from being committed
```

Future planned scripts:

```text
setup_genio520_build.sh        # Genio 520-specific BSP/layer setup
build.sh                       # BitBake build command wrapper
```

## Requirements

Recommended host system:

```text
OS:       Ubuntu 22.04 LTS or Ubuntu 24.04 LTS
RAM:      32 GB recommended
Disk:     140 GB minimum, 200+ GB preferred
Storage:  SSD/NVMe preferred
Network:  Internet access required
User:     Normal user with sudo permission
```

## Usage

Make the script executable:

```bash
chmod +x yocto-host-install.sh
```

Run the script:

```bash
./yocto-host-install.sh
```

Optional: specify custom workspace and cache locations:

```bash
YOCTO_WORKDIR="$HOME/yocto-work" \
YOCTO_CACHE_DIR="$HOME/yocto-cache" \
./yocto-host-install.sh
```
## What the Script Does

The script performs the following setup:

```text
1. Checks host OS information
2. Prints CPU, RAM, and disk availability
3. Installs required Yocto host packages
4. Enables en_US.UTF-8 locale
5. Creates Yocto workspace directory
6. Creates shared downloads and sstate-cache directories
7. Generates yocto-env-paths.sh for later scripts
```

## Important Notes

This script is board-agnostic.

It does not:

```text
- set MACHINE
- configure target device settings
- add meta-ros
- run BitBake
- flash a board
```

Those steps should be handled in a separate board-specific setup script.

## Yocto Cache Directories

The script creates reusable cache folders:

```text
downloads/       downloaded source archives and Git repositories
sstate-cache/    shared build cache for faster rebuilds
```

These folders should not be committed to Git.

## Git Ignore Policy

Do not commit Yocto build outputs or cache folders.

Ignored examples:

```text
build/
tmp/
downloads/
sstate-cache/
*.wic
*.img
*.rootfs.*
*.log
```

Only commit source files, scripts, recipes, configuration templates, and documentation.

## Planned Workflow

Expected full workflow:

```text
1. Run generic Yocto host setup
2. Run board-specific BSP/layer setup
3. Build target image with BitBake
4. Flash image to target board
5. Run board validation tests
```

## License

This project is licensed under the MIT License; see the separate LICENSE file for details.
