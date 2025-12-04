# Testing Guide

This guide helps you test the Nix configuration before deploying.

## Prerequisites

Install Nix with flakes support:

```bash
# Install Nix
curl -L https://nixos.org/nix/install | sh

# Enable flakes
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

# Restart your shell
exec $SHELL
```

## Testing Checklist

### 1. Flake Validation

```bash
cd terminal-nix

# Check flake syntax and structure
nix flake check

# Show flake outputs
nix flake show

# Expected output:
# ├───devShells
# │   └───x86_64-linux
# │       └───default: development environment
# ├───nixosConfigurations
# │   └───wsl: NixOS configuration
# └───packages
#     ├───x86_64-linux
#     │   ├───docker: package 'docker-image-terminal-nix.tar.gz'
#     │   └───homeConfig: package 'home-manager-generation'
```

### 2. Development Shell Test

```bash
# Enter development shell
nix develop

# Test that all tools are available
echo "Testing tools..."

# Programming languages
node --version          # Should show v21.x.x
python --version        # Should show 3.10.x
java --version          # Should show 21.x.x
ghc --version           # Should show 9.x.x
perl --version          # Should show 5.38.x
ruby --version          # Should show 3.2.x
sbcl --version          # Should show 2.3.x

# Tools
git --version
vim --version | head -1
tmux -V
starship --version
btop --version
htop --version
jq --version
minikube version
k9s version
ttyd --version

# Exit shell
exit
```

### 3. Home Manager Test

```bash
# Build home-manager configuration
nix build .#homeConfig

# Check the result
ls -la result/

# Activate (dry-run first)
./result/activate --dry-run

# If dry-run looks good, activate for real
./result/activate

# Verify zsh configuration
zsh -c 'echo $ZSH'  # Should point to oh-my-zsh

# Verify starship
which starship

# Check tmux config
tmux -V
```

### 4. Docker Image Test

```bash
# Build Docker image
nix build .#docker

# Check the result
ls -lh result

# Load into Docker
docker load < result

# List images
docker images | grep terminal-nix

# Run the container
docker run -d -p 8080:8080 --name terminal-test terminal-nix:latest

# Wait a few seconds for startup
sleep 5

# Check if it's running
docker ps | grep terminal-test

# Test web terminal access
curl -I http://localhost:8080
# Should return HTTP 200

# Check logs
docker logs terminal-test

# Enter the container
docker exec -it terminal-test /bin/zsh

# Inside container, test tools
node --version
python --version
starship --version

# Exit container
exit

# Stop and remove
docker stop terminal-test
docker rm terminal-test
```

### 5. Package Availability Test

Create a test script:

```bash
cat > test-packages.sh << 'EOF'
#!/usr/bin/env bash

echo "Testing package availability..."

packages=(
  "gcc" "gnumake" "autoconf" "git" "vim" "emacs"
  "tmux" "zsh" "curl" "wget" "tree" "htop" "btop"
  "starship" "node" "python" "java" "ghc" "perl"
  "ruby" "jq" "sbcl" "minikube" "k9s" "ttyd"
)

failed=0
for pkg in "${packages[@]}"; do
  if command -v $pkg &> /dev/null; then
    echo "✓ $pkg"
  else
    echo "✗ $pkg NOT FOUND"
    ((failed++))
  fi
done

echo ""
if [ $failed -eq 0 ]; then
  echo "All packages available!"
  exit 0
else
  echo "$failed packages missing!"
  exit 1
fi
EOF

chmod +x test-packages.sh

# Run in development shell
nix develop -c ./test-packages.sh
```

### 6. Configuration Test

Test individual program configurations:

```bash
# Test zsh configuration
nix develop -c zsh -c 'echo $ZSH_VERSION'

# Test git configuration
nix develop -c git config --list | grep user

# Test tmux configuration
nix develop -c tmux -V

# Test vim configuration
nix develop -c vim --version | head -1

# Test starship configuration
nix develop -c starship config
```

### 7. WSL Configuration Test (Windows only)

```powershell
# On Windows, after importing NixOS-WSL

# Check configuration syntax
wsl -d NixOS -- nix flake check /path/to/terminal-nix

# Build configuration (don't apply yet)
wsl -d NixOS -- sudo nixos-rebuild build --flake /path/to/terminal-nix#wsl

# If build succeeds, apply
wsl -d NixOS -- sudo nixos-rebuild switch --flake /path/to/terminal-nix#wsl

# Test inside WSL
wsl -d NixOS -- node --version
wsl -d NixOS -- python --version
```

### 8. Performance Test

```bash
# Measure build time
time nix build .#docker --rebuild

# Measure with cache (should be much faster)
nix-collect-garbage -d
time nix build .#docker

# Measure development shell startup
time nix develop -c echo "Ready"
```

### 9. Integration Test

Full end-to-end test:

```bash
#!/usr/bin/env bash

echo "=== Full Integration Test ==="

# 1. Flake check
echo "1. Checking flake..."
nix flake check || exit 1

# 2. Build all outputs
echo "2. Building development shell..."
nix build .#devShells.x86_64-linux.default || exit 1

echo "3. Building Docker image..."
nix build .#docker || exit 1

echo "4. Building home-manager config..."
nix build .#homeConfig || exit 1

# 3. Test development shell
echo "5. Testing development shell..."
nix develop -c bash -c '
  node --version &&
  python --version &&
  java --version &&
  git --version &&
  tmux -V &&
  starship --version
' || exit 1

# 4. Test Docker image
echo "6. Testing Docker image..."
docker load < result
docker run --rm terminal-nix:latest /bin/sh -c "node --version" || exit 1

echo ""
echo "=== All Tests Passed! ==="
```

## Troubleshooting

### Flake Check Fails

```bash
# Show detailed error
nix flake check --show-trace

# Common issues:
# - Syntax errors in .nix files
# - Missing packages in nixpkgs
# - Incorrect attribute paths
```

### Build Fails

```bash
# Build with verbose output
nix build .#docker --print-build-logs

# Check for:
# - Network issues (can't download)
# - Hash mismatches
# - Missing dependencies
```

### Docker Image Won't Load

```bash
# Check image size
ls -lh result

# Verify it's a valid tar.gz
file result

# Try loading with verbose output
docker load < result --verbose
```

### Tools Not Available in Container

```bash
# Enter container
docker run -it terminal-nix:latest /bin/sh

# Check PATH
echo $PATH

# List available binaries
ls /nix/store/*/bin/

# Check if package is in the image
docker run terminal-nix:latest find /nix/store -name "node"
```

### Home Manager Activation Fails

```bash
# Check for conflicts
./result/activate --dry-run

# Common issues:
# - Existing dotfiles conflict
# - Permission issues
# - Missing directories

# Backup existing configs
mkdir -p ~/backup
cp ~/.zshrc ~/backup/ 2>/dev/null || true
cp ~/.tmux.conf ~/backup/ 2>/dev/null || true

# Try again
./result/activate
```

## Continuous Testing

### Pre-commit Hook

Create `.git/hooks/pre-commit`:

```bash
#!/usr/bin/env bash

echo "Running Nix flake check..."
cd terminal-nix
nix flake check

if [ $? -ne 0 ]; then
  echo "Flake check failed! Fix errors before committing."
  exit 1
fi

echo "Flake check passed!"
```

### GitHub Actions

The `.github/workflows/build.yml` automatically tests:
- Flake validation
- Development shell build
- Docker image build
- Home-manager configuration build

## Performance Benchmarks

Expected build times (with binary cache):

| Operation | Time | Notes |
|-----------|------|-------|
| `nix flake check` | 5-10s | Validates configuration |
| `nix develop` | 1-2s | Enters shell |
| `nix build .#docker` | 2-5min | First time |
| `nix build .#docker` | 10-30s | With cache |
| `nix build .#homeConfig` | 30-60s | First time |
| Docker load | 30-60s | Depends on image size |

## Success Criteria

All tests pass when:

- ✅ `nix flake check` succeeds
- ✅ All tools available in development shell
- ✅ Docker image builds and loads
- ✅ Container runs and exposes port 8080
- ✅ Web terminal accessible at http://localhost:8080
- ✅ Home-manager configuration activates
- ✅ All programming languages work
- ✅ Zsh, tmux, vim configurations apply
- ✅ Starship prompt displays correctly

## Next Steps

After all tests pass:

1. Commit the configuration
2. Push to GitHub
3. GitHub Actions will build automatically
4. Docker image will be pushed to registry
5. Share with team or deploy

## Getting Help

If tests fail:

1. Check error messages carefully
2. Review [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
3. Search [NixOS Discourse](https://discourse.nixos.org/)
4. Open an issue on GitHub