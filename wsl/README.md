# NixOS WSL Setup Guide

This guide walks you through setting up your terminal environment as a NixOS WSL distribution.

## Prerequisites

- Windows 10 version 2004 or higher (Build 19041 or higher) or Windows 11
- WSL 2 enabled
- Administrator access

## Step 1: Enable WSL 2

If you haven't already enabled WSL:

```powershell
# Run in PowerShell as Administrator
wsl --install

# Restart your computer
```

## Step 2: Download NixOS-WSL

Download the latest NixOS-WSL tarball:

```powershell
# Visit the releases page
# https://github.com/nix-community/NixOS-WSL/releases

# Or download directly (replace VERSION with latest)
Invoke-WebRequest -Uri "https://github.com/nix-community/NixOS-WSL/releases/download/VERSION/nixos-wsl.tar.gz" -OutFile "$env:USERPROFILE\Downloads\nixos-wsl.tar.gz"
```

## Step 3: Import NixOS into WSL

```powershell
# Create a directory for NixOS
New-Item -ItemType Directory -Path "$env:USERPROFILE\NixOS" -Force

# Import the tarball
wsl --import NixOS "$env:USERPROFILE\NixOS" "$env:USERPROFILE\Downloads\nixos-wsl.tar.gz" --version 2

# Set as default (optional)
wsl --set-default NixOS
```

## Step 4: Initial Setup

```powershell
# Start NixOS
wsl -d NixOS

# You should now be in a NixOS shell
```

Inside the NixOS shell:

```bash
# Update the channel
sudo nix-channel --update

# Install git (if not already available)
nix-shell -p git

# Clone this repository
git clone <your-repo-url> ~/terminal-nix
cd ~/terminal-nix
```

## Step 5: Apply Configuration

```bash
# Build the configuration
sudo nixos-rebuild switch --flake .#wsl

# This will:
# - Set up the gfoster user
# - Install all packages
# - Configure zsh, tmux, vim, etc.
# - Enable home-manager
```

## Step 6: Set Up User

```bash
# Exit and restart WSL
exit
wsl -d NixOS

# You should now be logged in as gfoster
# Change the password
passwd

# Verify everything is working
starship --version
node --version
python --version
```

## Step 7: Configure Windows Terminal (Optional)

Add a profile for NixOS in Windows Terminal:

1. Open Windows Terminal Settings (Ctrl+,)
2. Click "Add a new profile"
3. Configure:
   - Name: NixOS Terminal
   - Command line: `wsl -d NixOS`
   - Starting directory: `\\wsl$\NixOS\home\gfoster`
   - Icon: (optional) Use a Nix logo

Or add this JSON to your settings:

```json
{
  "guid": "{YOUR-GUID-HERE}",
  "name": "NixOS Terminal",
  "commandline": "wsl.exe -d NixOS",
  "startingDirectory": "\\\\wsl$\\NixOS\\home\\gfoster",
  "icon": "https://nixos.org/logo/nixos-logo-only-hires.png",
  "hidden": false
}
```

## Customization

### Changing User Configuration

Edit `~/terminal-nix/home.nix` and rebuild:

```bash
cd ~/terminal-nix

# Edit configuration
vim home.nix

# Apply changes
home-manager switch --flake .#homeConfig
```

### Changing System Configuration

Edit `~/terminal-nix/wsl/configuration.nix` and rebuild:

```bash
cd ~/terminal-nix

# Edit configuration
vim wsl/configuration.nix

# Apply changes
sudo nixos-rebuild switch --flake .#wsl
```

### Adding Packages

Add packages to either `home.nix` (user packages) or `wsl/configuration.nix` (system packages):

```nix
# In home.nix
home.packages = with pkgs; [
  # Add your packages here
  ripgrep
  fd
  bat
];
```

Then rebuild:

```bash
home-manager switch --flake .#homeConfig
```

## Updating

### Update Flake Inputs

```bash
cd ~/terminal-nix

# Update all inputs
nix flake update

# Or update specific input
nix flake lock --update-input nixpkgs

# Apply updates
sudo nixos-rebuild switch --flake .#wsl
```

### Update Packages

```bash
# Update system
sudo nixos-rebuild switch --flake .#wsl --upgrade

# Update home-manager
home-manager switch --flake .#homeConfig
```

## Maintenance

### Garbage Collection

```bash
# Remove old generations (system)
sudo nix-collect-garbage -d

# Remove old generations (user)
nix-collect-garbage -d

# Or keep last 30 days
sudo nix-collect-garbage --delete-older-than 30d
```

### List Generations

```bash
# System generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Home-manager generations
home-manager generations
```

### Rollback

```bash
# Rollback system to previous generation
sudo nixos-rebuild switch --rollback

# Rollback home-manager
home-manager switch --rollback
```

## Troubleshooting

### WSL Won't Start

```powershell
# Check WSL status
wsl --list --verbose

# Restart WSL
wsl --shutdown
wsl -d NixOS
```

### Configuration Build Fails

```bash
# Check for syntax errors
nix flake check

# Build with verbose output
sudo nixos-rebuild switch --flake .#wsl --show-trace
```

### Network Issues

```bash
# Check DNS
cat /etc/resolv.conf

# Regenerate network config
sudo nixos-rebuild switch --flake .#wsl
```

### Permission Issues

```bash
# Fix ownership
sudo chown -R gfoster:users /home/gfoster

# Fix permissions
chmod 755 /home/gfoster
```

## Advanced Configuration

### Enable Docker in WSL

Already configured in `wsl/configuration.nix`:

```bash
# Start Docker daemon
sudo systemctl start docker

# Enable on boot
sudo systemctl enable docker

# Add user to docker group (already done in config)
# Test Docker
docker run hello-world
```

### Mount Windows Drives

Windows drives are automatically mounted at `/mnt/c`, `/mnt/d`, etc.

```bash
# Access Windows files
cd /mnt/c/Users/YourUsername

# Create symlink for easy access
ln -s /mnt/c/Users/YourUsername ~/windows-home
```

### VS Code Integration

Install "Remote - WSL" extension in VS Code:

```bash
# Open current directory in VS Code
code .

# Or open VS Code from Windows and select WSL
```

### X11 Applications

Install an X server on Windows (e.g., VcXsrv, X410):

```bash
# Add to home.nix
home.sessionVariables = {
  DISPLAY = ":0";
};

# Install X11 apps
home.packages = with pkgs; [
  firefox
  xterm
];
```

## Backup and Restore

### Export Configuration

```bash
# Your configuration is in ~/terminal-nix
# Commit and push to git
cd ~/terminal-nix
git add .
git commit -m "Update configuration"
git push
```

### Export WSL Distribution

```powershell
# Export to tarball
wsl --export NixOS "$env:USERPROFILE\Backups\nixos-backup.tar"

# Import on another machine
wsl --import NixOS "$env:USERPROFILE\NixOS" "$env:USERPROFILE\Backups\nixos-backup.tar" --version 2
```

## Performance Tips

1. **Use Windows Terminal**: Better performance than cmd/PowerShell
2. **Store projects in WSL**: Faster than accessing Windows filesystem
3. **Enable systemd**: Already configured in `wsl/configuration.nix`
4. **Increase memory**: Edit `.wslconfig` in Windows home directory

```ini
# %USERPROFILE%\.wslconfig
[wsl2]
memory=8GB
processors=4
swap=2GB
```

## Uninstallation

```powershell
# Unregister the distribution
wsl --unregister NixOS

# Remove files
Remove-Item -Recurse -Force "$env:USERPROFILE\NixOS"
```

## Resources

- [NixOS-WSL Documentation](https://github.com/nix-community/NixOS-WSL)
- [WSL Documentation](https://docs.microsoft.com/en-us/windows/wsl/)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)

## Getting Help

- [NixOS Discourse](https://discourse.nixos.org/)
- [NixOS Matrix Channel](https://matrix.to/#/#nixos:nixos.org)
- [WSL GitHub Issues](https://github.com/microsoft/WSL/issues)