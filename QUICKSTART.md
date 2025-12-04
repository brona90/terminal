# Quick Start Guide

Get up and running with the Nix terminal environment in minutes.

## Choose Your Path

### 🚀 Fastest: Development Shell (No Installation)

Perfect for trying out the environment without committing.

```bash
# Clone and enter
git clone <your-repo-url>
cd terminal-nix
nix develop

# You're in! All tools available immediately.
```

### 🐳 Docker: Containerized Environment

Best for consistent, isolated environments.

```bash
# Build with Nix
nix build .#docker
docker load < result

# Run
docker run -it -p 8080:8080 terminal-nix:latest

# Access web terminal at http://localhost:8080
```

### 🪟 WSL: Native Windows Integration

Best for Windows users wanting a full Linux environment.

```powershell
# Download NixOS-WSL from GitHub releases
# Import into WSL
wsl --import NixOS $env:USERPROFILE\NixOS nixos-wsl.tar.gz --version 2

# Start and configure
wsl -d NixOS
git clone <your-repo-url> ~/terminal-nix
cd ~/terminal-nix
sudo nixos-rebuild switch --flake .#wsl
```

### 🏠 Home Manager: User Environment Only

Best for adding to existing Linux/macOS systems.

```bash
# Install Nix first (if not already installed)
curl -L https://nixos.org/nix/install | sh

# Clone and activate
git clone <your-repo-url>
cd terminal-nix
nix build .#homeConfig
./result/activate
```

## What You Get

After setup, you'll have:

✅ **Languages**: Node.js, Python, Java, Haskell, Ruby, Perl, Common Lisp  
✅ **Tools**: Git, Vim, Emacs, Tmux, Docker tools (k9s, minikube)  
✅ **Shell**: Zsh with Oh-My-Zsh, syntax highlighting, autosuggestions  
✅ **Monitoring**: btop, htop  
✅ **Prompt**: Starship with git integration  

## First Steps

```bash
# Check versions
node --version
python --version
java --version

# Try the prompt
starship --version

# Open tmux
tmux

# Monitor system
btop
```

## Customization

Edit `home.nix` to add packages or change settings:

```nix
home.packages = with pkgs; [
  # Add your tools here
  ripgrep
  fd
  bat
];
```

Then rebuild:

```bash
# For development shell
nix develop

# For Docker
nix build .#docker

# For WSL
sudo nixos-rebuild switch --flake .#wsl

# For Home Manager
home-manager switch --flake .#homeConfig
```

## Common Commands

```bash
# Update dependencies
nix flake update

# Clean up old versions
nix-collect-garbage -d

# Search for packages
nix search nixpkgs <package-name>

# Check configuration
nix flake check
```

## Getting Help

- 📖 Read the full [README.md](README.md)
- 🪟 WSL users: See [wsl/README.md](wsl/README.md)
- 🐛 Issues: Open on GitHub
- 💬 Community: [NixOS Discourse](https://discourse.nixos.org/)

## Next Steps

1. ✅ Choose your installation method above
2. ✅ Verify tools work (`node --version`, etc.)
3. ✅ Customize `home.nix` for your needs
4. ✅ Commit your changes to git
5. ✅ Enjoy your reproducible environment!

---

**Pro Tip**: Use `nix develop` to test changes before committing. It's fast and doesn't affect your system!