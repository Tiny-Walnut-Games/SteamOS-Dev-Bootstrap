FROM archlinux:base

# Install minimal dependencies for testing (including Flatpak and dbus)
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm bash sudo git curl wget ca-certificates flatpak dbus && \
    pacman -Scc --noconfirm

# Create test user with sudo access
RUN useradd -m testuser && \
    echo "testuser ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/testuser && \
    chmod 440 /etc/sudoers.d/testuser

# Copy bootstrap script and catalog with proper permissions
COPY --chown=testuser:testuser bootstrap-steamos.sh /home/testuser/bootstrap-steamos.sh
COPY --chown=testuser:testuser flatpak-apps.conf /home/testuser/flatpak-apps.conf
COPY --chown=testuser:testuser scripts/ /home/testuser/scripts/
RUN chmod +x /home/testuser/bootstrap-steamos.sh

# Create mock SteamOS environment
RUN mkdir -p /etc && \
    echo 'NAME="SteamOS"' > /etc/os-release && \
    echo 'ID="steamos"' >> /etc/os-release && \
    echo 'VERSION_ID="3.0"' >> /etc/os-release && \
    echo 'PRETTY_NAME="SteamOS 3.0 (Holo)"' >> /etc/os-release

# Add mock kernel cmdline for SteamOS detection
# We can't write to /proc/cmdline directly, so create a mock file
RUN mkdir -p /etc/steamos && \
    echo 'BOOT_IMAGE=/boot/vmlinuz-linux root=UUID=xxx ro quiet splash steamos_cmdline=1' > /etc/steamos/mock_cmdline

# Initialize Flatpak in the container (add Flathub repo)
RUN flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true

# Switch to test user
USER testuser
WORKDIR /home/testuser

# Set secure environment defaults
ENV CURL_OPTIONS="--proto =https --tlsv1.2"

# Start dbus daemon and run interactive shell
CMD ["bash", "-c", "sudo mkdir -p /run/dbus && sudo dbus-daemon --system --print-address &> /dev/null; bash"]
