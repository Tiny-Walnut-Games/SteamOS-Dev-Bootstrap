FROM archlinux:base

# Install minimal dependencies for testing
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm bash sudo git curl wget ca-certificates && \
    pacman -Scc --noconfirm

# Create test user with sudo access
RUN useradd -m testuser && \
    echo "testuser ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/testuser && \
    chmod 440 /etc/sudoers.d/testuser

# Copy bootstrap script with proper permissions
COPY --chown=testuser:testuser bootstrap-steamos.sh /home/testuser/bootstrap-steamos.sh
COPY --chown=testuser:testuser scripts/ /home/testuser/scripts/
RUN chmod +x /home/testuser/bootstrap-steamos.sh

# Create mock SteamOS environment
RUN mkdir -p /etc && \
    echo 'NAME="SteamOS"' > /etc/os-release && \
    echo 'ID="steamos"' >> /etc/os-release && \
    echo 'VERSION_ID="3.0"' >> /etc/os-release && \
    echo 'PRETTY_NAME="SteamOS 3.0 (Holo)"' >> /etc/os-release

# Add mock kernel cmdline for SteamOS detection
RUN mkdir -p /proc && \
    echo 'BOOT_IMAGE=/boot/vmlinuz-linux root=UUID=xxx ro quiet splash steamos_neptune=1' > /proc/cmdline

# Switch to test user
USER testuser
WORKDIR /home/testuser

# Set secure environment defaults
ENV CURL_OPTIONS="--proto =https --tlsv1.2"

# Interactive shell by default
CMD ["/bin/bash"]
