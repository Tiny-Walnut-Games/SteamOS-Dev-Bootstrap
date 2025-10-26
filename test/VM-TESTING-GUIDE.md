# 🖥️ Virtual Machine Testing Guide

This guide helps you test the SteamOS bootstrap script in a VM before switching your main system.

## Prerequisites

- **Hypervisor**: VMware Workstation, VirtualBox, or Hyper-V
- **SteamOS ISO**: Download from [store.steampowered.com](https://store.steampowered.com/steamos)
- **System Resources**: 
  - 8GB+ RAM allocated to VM
  - 64GB+ disk space
  - Hardware virtualization enabled

## Method 1: VirtualBox Setup

### Download & Install
```bash
# Download VirtualBox from virtualbox.org
# Download SteamOS ISO (steamdeck-recovery-4.img or similar)
```

### VM Configuration
1. **Create New VM**:
   - Type: Linux
   - Version: Arch Linux (64-bit)
   - RAM: 8192 MB (8GB)
   - Storage: 64GB VDI (dynamically allocated)

2. **VM Settings**:
   - **System > Processor**: 4+ cores
   - **Display > Video Memory**: 128MB
   - **Storage**: Mount SteamOS ISO
   - **Network**: NAT or Bridged (for internet access)

3. **Boot & Install SteamOS**:
   - Follow SteamOS installation prompts
   - Create user account (equivalent to 'deck' user)
   - Enable desktop mode after installation

### Testing Process
```bash
# Inside SteamOS VM:
# 1. Switch to desktop mode
# 2. Open terminal (Konsole)
# 3. Download bootstrap script:
curl -fsSL https://raw.githubusercontent.com/[your-username]/[your-repo]/main/bootstrap-steamos.sh -o bootstrap-steamos.sh
chmod +x bootstrap-steamos.sh

# 4. Run the bootstrap script:
./bootstrap-steamos.sh
```

## Method 2: Docker Testing (Faster)

Since you have Docker in your bootstrap script, test using the containers we created:

```bash
# From your Windows machine:
cd C:/Users/Jerry/RiderProjects/SteamOS-Dev-Bootstrap

# Build and test with Arch (closest to SteamOS):
docker build -f test/docker/Dockerfile.arch -t steamos-test .
docker run -it steamos-test

# Inside container:
./bootstrap-steamos.sh

# Test individual phases:
# (You can modify the script to accept --phase arguments)
```

## Method 3: WSL2 + Arch Testing

If you have WSL2, you can test with Arch Linux:

```bash
# Install Arch on WSL2:
wsl --install -d ArchLinux

# Inside Arch WSL:
sudo pacman -Syu
# Copy your bootstrap script
./bootstrap-steamos.sh
```

## Testing Checklist

### Phase 1: System Verification ✅
- [ ] SteamOS detection works
- [ ] pacman availability check
- [ ] sudo access verification

### Phase 2: System Update ✅
- [ ] pacman sync successful  
- [ ] Essential packages install
- [ ] No package conflicts

### Phase 3: Development Toolchains ✅
- [ ] Python ecosystem (python, pip, virtualenv)
- [ ] Node.js & npm installation
- [ ] Java (OpenJDK) installation
- [ ] Rust & Cargo installation  
- [ ] Go installation
- [ ] .NET SDK installation
- [ ] Build tools (gcc, clang, cmake)

### Phase 4: Git & SSH ✅
- [ ] Git identity configuration prompts
- [ ] SSH key generation
- [ ] GitHub CLI installation

### Phase 5: Flatpak Applications ✅
- [ ] Flatpak installation
- [ ] Flathub repository addition
- [ ] Development apps install:
  - [ ] Unity Hub
  - [ ] JetBrains Rider
  - [ ] VS Code
  - [ ] Godot Engine

### Phase 6: Containers ✅
- [ ] Docker installation
- [ ] Docker service enablement
- [ ] User added to docker group
- [ ] Podman installation

### Phase 7: Shell Environment ✅
- [ ] PATH modifications
- [ ] Environment variable setup
- [ ] Shell customizations

## Common Issues & Solutions

### Issue: pacman Key Errors
```bash
# Solution:
sudo pacman-key --init
sudo pacman-key --populate archlinux
sudo pacman -Sy archlinux-keyring
```

### Issue: Flatpak Permission Errors
```bash
# Solution:
flatpak remote-add --user flathub https://flathub.org/repo/flathub.flatpakrepo
```

### Issue: Docker Group Not Applied
```bash
# Solution (requires logout/login):
newgrp docker
# Or just note that reboot will be required
```

## Success Criteria

Your bootstrap script is ready for production when:

- ✅ All phases complete without errors in VM
- ✅ All expected tools are installed and functional
- ✅ Development workflow can be performed (git clone, build, run)
- ✅ IDE/editors launch correctly from desktop
- ✅ No manual intervention required during installation

## Backup Strategy Before Switching

Before switching your main system:

1. **Create System Image**: Use tools like Clonezilla
2. **Export Windows Development Settings**: 
   - VS Code settings sync
   - Git configuration
   - SSH keys backup
   - Browser bookmarks/passwords
3. **Document Current Workflow**: Note any Windows-specific tools you rely on
4. **Test Data Migration**: Ensure project files work on Linux

## Post-Switch Validation

After switching to SteamOS, validate:
- All development tools work as expected
- Performance meets your needs  
- Hardware compatibility (drivers, peripherals)
- Workflow efficiency compared to Windows

---

💡 **Pro Tip**: Run the VM test multiple times with different configurations to catch edge cases!