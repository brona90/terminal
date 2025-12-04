# Terminal Environment with Nix

A fully reproducible terminal environment using Nix, providing a consistent development setup across Docker containers and WSL.

## Features

- **Reproducible**: All dependencies pinned with Nix flakes
- **Declarative**: Configuration as code
- **Cross-platform**: Same config for Docker and WSL
- **Fast**: Binary cache for quick builds
- **Rollback**: Easy to revert changes

## What's Included

### Development Tools
- GCC, Make, Autoconf, Binutils
- Git with sensible defaults
- Vim and Emacs 29

### Programming Languages
- Node.js 21
- Python 3.10
- Java 21 (OpenJDK)
- Haskell (GHC)
- Perl 5.38
- Ruby 3.2
- Common Lisp (SBCL)

### Kubernetes Tools
- Minikube
- K9s

### Terminal Environment
- Zsh with Oh-My-Zsh
- Tmux with custom configuration
- Starship prompt
- Syntax highlighting and autosuggestions

### System Utilities
- btop (system monitor)
- htop
- tree
- fasd
- jq
- ttyd (web-based terminal)

## Quick Start

### Prerequisites

Install Nix with flakes support:

```bash
# Install Nix
curl -L https://nixos.org/nix/install | sh

# Enable flakes (add to ~/.config/nix/nix.conf or /etc/nix/nix.conf)
experimental-features = nix-command flakes
```

### Option 1: Development Shell

Test the environment without installing:

```bash
# Clone the repository
git clone <your-repo-url>
cd terminal-nix

# Enter the development shell
nix develop

# All tools are now available!
starship --version
node --version
python --version
```

### Option 2: Docker Container

Build and run as a Docker container:

```bash
# Build the Docker image using Nix
nix build .#docker

# Load the image
docker load < result

# Run the container
docker run -it -p 8080:8080 terminal-nix:latest

# Or use docker-compose
cd docker
docker-compose up -d

# Access the web terminal at http://localhost:8080
```

### Option 3: WSL Installation

Install as a NixOS WSL distribution:

#### Step 1: Install NixOS-WSL

```powershell
# Download NixOS-WSL tarball
# Visit: https://github.com/nix-community/NixOS-WSL/releases

# Import into WSL
wsl --import NixOS $env:USERPROFILE\NixOS nixos-wsl.tar.gz --version 2

# Start NixOS
wsl -d NixOS
```

#### Step 2: Apply Configuration

```bash
# Inside WSL, clone this repository
git clone <your-repo-url> ~/terminal-nix
cd ~/terminal-nix

# Build and switch to the configuration
sudo nixos-rebuild switch --flake .#wsl

# Restart WSL
exit
wsl -d NixOS
```

### Option 4: Home Manager (Standalone)

Install just the user environment without NixOS:

```bash
# Clone the repository
git clone <your-repo-url>
cd terminal-nix

# Build the home-manager configuration
nix build .#homeConfig

# Activate the configuration
./result/activate
```

## Configuration

### Customizing the Environment

Edit `home.nix` to customize your environment:

```nix
# Add more packages
home.packages = with pkgs; [
  # Your additional packages here
  ripgrep
  fd
  bat
];

# Modify shell aliases
programs.zsh.shellAliases = {
  # Your custom aliases
  myalias = "echo 'Hello World'";
};
```

### Updating Dependencies

```bash
# Update flake inputs
nix flake update

# Rebuild with new dependencies
nix build .#docker
# or
sudo nixos-rebuild switch --flake .#wsl
```

### Adding New Tools

1. Edit `flake.nix` to add the package to `commonPackages`
2. Rebuild the configuration
3. The tool is now available everywhere

## Project Structure

```
terminal-nix/
├── flake.nix              # Main flake definition
├── flake.lock             # Locked dependencies
├── home.nix               # Home-manager configuration
├── docker/
│   ├── Dockerfile.nix     # Nix-based Dockerfile
│   └── docker-compose.yml # Docker Compose configuration
├── wsl/
│   └── configuration.nix  # NixOS WSL configuration
└── README.md              # This file
```

## Common Tasks

### Building the Docker Image

```bash
# Build with Nix
nix build .#docker

# Load into Docker
docker load < result

# Tag the image
docker tag terminal-nix:latest your-registry/terminal-nix:latest

# Push to registry
docker push your-registry/terminal-nix:latest
```

### Testing Changes Locally

```bash
# Enter development shell
nix develop

# Test your changes
# All packages and configurations are available

# Exit when done
exit
```

### Updating a Single Package

```bash
# Update a specific input
nix flake lock --update-input nixpkgs

# Rebuild
nix build .#docker
```

### Garbage Collection

```bash
# Remove old generations
nix-collect-garbage -d

# Or keep last 30 days
nix-collect-garbage --delete-older-than 30d
```

## Troubleshooting

### Flakes Not Enabled

If you get an error about experimental features:

```bash
# Add to ~/.config/nix/nix.conf
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### Docker Build Fails

```bash
# Clear Nix cache
nix-collect-garbage -d

# Rebuild
nix build .#docker --rebuild
```

### WSL Configuration Issues

```bash
# Check system logs
journalctl -xe

# Rebuild with verbose output
sudo nixos-rebuild switch --flake .#wsl --show-trace
```

### Package Not Found

```bash
# Search for packages
nix search nixpkgs <package-name>

# Check package availability
nix-env -qaP | grep <package-name>
```

## Migration from Original Setup

This Nix implementation replaces:

- **apt packages** → Nix packages (pinned versions)
- **asdf** → Nix (native version management)
- **oh-my-zsh install script** → home-manager zsh module
- **config bare repo** → home-manager dotfile management
- **Individual .sh scripts** → Declarative Nix configuration

### Benefits Over Original

1. **Reproducibility**: Exact same environment every time
2. **Speed**: Binary cache instead of compiling
3. **Simplicity**: One configuration file instead of multiple scripts
4. **Rollback**: Easy to revert to previous configurations
5. **Cross-platform**: Same config for Docker and WSL

## Advanced Usage

### Creating a Custom Overlay

```nix
# In flake.nix, add an overlay
overlays = [
  (final: prev: {
    myCustomPackage = prev.callPackage ./packages/my-package.nix {};
  })
];
```

### Using with direnv

```bash
# Create .envrc in your project
echo "use flake" > .envrc
direnv allow

# Environment automatically loads when you cd into the directory
```

### Sharing Configurations

```bash
# Export your configuration
nix flake show

# Others can use it directly
nix develop github:yourusername/terminal-nix
```

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `nix flake check`
5. Submit a pull request

## Resources

- [Nix Manual](https://nixos.org/manual/nix/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [NixOS WSL](https://github.com/nix-community/NixOS-WSL)
- [Nix Pills](https://nixos.org/guides/nix-pills/)

## License

MIT License - See LICENSE file for details

## Support

For issues and questions:
- Open an issue on GitHub
- Check the [Nix Discourse](https://discourse.nixos.org/)
- Join the [NixOS Matrix channel](https://matrix.to/#/#nixos:nixos.org)