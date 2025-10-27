# Flatpak Applications Catalog

## Overview

The SteamOS Bootstrap now uses a centralized **Flatpak application catalog** (`flatpak-apps.conf`) to manage optional GUI applications that are installed via Flatpak. This makes it easy to add, remove, or customize which applications get installed without editing the bash script.

## Catalog File Location

```
flatpak-apps.conf
```

Located in the project root directory.

## Adding Applications

### 1. Find the Flatpak App ID

Visit [Flathub](https://flathub.org/) and search for your desired application. The app ID is typically shown in the installation instructions.

Example: For VS Code, the app ID is `com.visualstudio.code`

### 2. Add to the Catalog

Open `flatpak-apps.conf` and add your app under the appropriate category section:

```ini
[development-ides]
com.jetbrains.Rider=JetBrains Rider IDE
com.jetbrains.IntelliJ-IDEA-Community=IntelliJ IDEA Community Edition
com.visualstudio.code=Visual Studio Code
```

### 3. Category Reference

- **[development-ides]** - IDEs and code editors
- **[game-development]** - Game engines and development tools
- **[graphics-design]** - Image editors, design tools
- **[productivity]** - Office, text editors, document tools
- **[gaming-entertainment]** - Games and entertainment apps
- **[media-streaming]** - Media players, streaming services
- **[dev-tools]** - Development utilities and CLIs
- **[communication]** - Chat, messaging, calls
- **[experimental]** - Beta/experimental applications

## Removing Applications

Simply comment out or delete the line in `flatpak-apps.conf`:

```ini
# com.example.AppID=Application Name  # Commented out
# com.spotify.Client=Spotify Music Streaming  # Disabled
```

## Format Rules

- **One app per line** in the format: `app_id=Display Name`
- **No spaces around the equals sign** in app lines (display names can have spaces)
- **Comments** start with `#`
- **Section headers** are in `[brackets]`
- Lines starting with `#` or `[` are automatically skipped by the bootstrap script

## Example Catalog Structure

```ini
# ============================================================================
# Flatpak Application Catalog
# ============================================================================
# Format: app_id=Display Name

[development-ides]
com.jetbrains.Rider=JetBrains Rider IDE
com.visualstudio.code=Visual Studio Code

[graphics-design]
org.gimp.GIMP=GIMP Image Editor

[gaming-entertainment]
com.lutris.Lutris=Lutris Gaming Platform
```

## Enabling/Disabling Sections

To disable all apps in a category, prefix each line with `#`:

```ini
# [gaming-entertainment]
# com.lutris.Lutris=Lutris Gaming Platform
```

Or simply comment out individual apps while keeping the section enabled for organization:

```ini
[gaming-entertainment]
# com.lutris.Lutris=Lutris Gaming Platform  # Not needed for this deployment
com.github.Fausto2.Lichess-GTK=Lichess GTK Chess
```

## Testing Flatpak Installation Locally

```bash
# Run full bootstrap with Flatpak apps
bash bootstrap-steamos.sh --auto-yes

# Verify Flatpak apps are installed
flatpak list --app
```

## Common Issues

### "Failed to install [app]"

**Possible causes:**
- App not available for your system architecture (ARM vs x86_64)
- Network connectivity issues
- Missing Flathub repository configuration

**Solution:** 
```bash
# Ensure Flathub is properly configured
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

### Catalog file not found

The bootstrap script looks for `flatpak-apps.conf` in the current working directory. Ensure:
1. The file exists in the root project directory
2. You're running the script from the correct location
3. The file has proper read permissions

### Flatpak skipped in test environment

In Docker/container testing, Flatpak is intentionally skipped due to system bus limitations. This is expected behavior. The catalog is primarily for production SteamOS systems.

## Popular Applications by Category

### Development IDEs
- `com.jetbrains.Rider` - JetBrains Rider
- `com.jetbrains.IntelliJ-IDEA-Community` - IntelliJ IDEA (Free)
- `com.jetbrains.IntelliJ-IDEA` - IntelliJ IDEA (Full)
- `com.jetbrains.PyCharm-Community` - PyCharm (Free)
- `com.visualstudio.code` - Visual Studio Code
- `com.github.sharkdp.bat` - Syntax highlighting for terminal

### Game Development
- `io.github.GodotEngine.Godot` - Godot Game Engine
- `com.unity.UnityHub` - Unity Hub
- `org.blender.Blender` - Blender 3D

### Graphics & Design
- `org.gimp.GIMP` - GIMP Image Editor
- `com.krita.Krita` - Krita Digital Painting
- `org.inkscape.Inkscape` - Inkscape Vector Graphics
- `com.github.PintaProject.Pinta` - Pinta Paint Program

### Productivity
- `org.libreoffice.LibreOffice` - LibreOffice Suite
- `com.github.mjakeman.text-pieces` - Text Pieces (lightweight text editor)
- `com.github.marktext.marktext` - MarkText Markdown Editor

### Gaming & Entertainment
- `com.lutris.Lutris` - Lutris Gaming Platform
- `com.github.Fausto2.Lichess-GTK` - Lichess Chess
- `org.telegram.desktop` - Telegram Desktop

### Media
- `com.spotify.Client` - Spotify
- `org.videolan.VLC` - VLC Media Player

## Advanced Usage

### Selectively Install Apps

You can temporarily disable apps by commenting them out:

```bash
# Only install code editors and IDEs for this system
# Comment out all graphics and gaming apps
```

Or create a script to run bootstrap with a modified catalog:

```bash
#!/bin/bash
# Install minimal development environment

# Copy catalog
cp flatpak-apps.conf flatpak-apps-minimal.conf

# Remove non-essential sections
sed -i '/^\[graphics-design\]/,/^\[/s/^com\./#com\./' flatpak-apps-minimal.conf
sed -i '/^\[gaming-entertainment\]/,/^\[/s/^com\./#com\./' flatpak-apps-minimal.conf

# Run with minimal apps
bash bootstrap-steamos.sh --auto-yes
```

## Contributing New Applications

If you have a useful Flatpak application to suggest:

1. Test it on SteamOS 3.x
2. Verify the app ID from Flathub
3. Submit a PR to add it to the appropriate category
4. Include a brief description of why it's useful for SteamOS development

## See Also

- [Flathub](https://flathub.org/) - Browse available Flatpak applications
- [Flatpak Documentation](https://docs.flatpak.org/) - Official Flatpak docs
- [Bootstrap Script](../bootstrap-steamos.sh) - Main bootstrap script