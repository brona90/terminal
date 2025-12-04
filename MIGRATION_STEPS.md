# Step-by-Step Migration Guide

This guide walks you through migrating from the original Debian/Docker setup to Nix.

## Overview

The migration will happen in phases:
1. **Parallel Development**: Create Nix version alongside original
2. **Testing**: Validate Nix implementation
3. **Gradual Rollout**: Switch users incrementally
4. **Deprecation**: Archive old setup

## Phase 1: Preparation (Day 1)

### 1.1 Create Migration Branch

```bash
cd terminal
git checkout -b nix-migration
```

### 1.2 Copy Nix Implementation

```bash
# Copy the terminal-nix directory into your repo
cp -r /path/to/terminal-nix/* .

# Or create from scratch following the structure
mkdir -p nix
cd nix
# Copy flake.nix, home.nix, etc.
```

### 1.3 Update Repository Structure

```
terminal/
├── Dockerfile              # Keep original
├── *.sh                    # Keep original scripts
├── nix/                    # New Nix implementation
│   ├── flake.nix
│   ├── flake.lock
│   ├── home.nix
│   ├── docker/
│   ├── wsl/
│   └── README.md
├── README.md               # Update with both options
└── .github/workflows/
    ├── docker-image.yml    # Keep original
    └── nix-build.yml       # Add new workflow
```

### 1.4 Update Main README

Add a section about Nix:

```markdown
# Terminal Environment

## Two Implementations Available

### Original (Debian + Docker)
See [Dockerfile](Dockerfile) and [original README](README.original.md)

### Nix (Recommended)
See [nix/README.md](nix/README.md) for the new Nix-based implementation.

**Benefits of Nix version:**
- 5-10x faster builds
- Reproducible environments
- Easy rollbacks
- Works on Docker, WSL, Linux, macOS
```

## Phase 2: Testing (Days 2-3)

### 2.1 Local Testing

```bash
cd nix

# Test flake
nix flake check

# Test development shell
nix develop

# Test Docker build
nix build .#docker
docker load < result
docker run -it -p 8080:8080 terminal-nix:latest
```

### 2.2 Comparison Testing

Create a comparison script:

```bash
#!/usr/bin/env bash

echo "=== Comparing Original vs Nix ==="

# Build original
echo "Building original Docker image..."
time docker build -t terminal-original:test -f ../Dockerfile ..

# Build Nix
echo "Building Nix Docker image..."
time nix build .#docker
docker load < result

# Compare sizes
echo ""
echo "Image sizes:"
docker images | grep -E "terminal-(original|nix)"

# Compare tool versions
echo ""
echo "Tool versions (Original):"
docker run --rm terminal-original:test bash -c "
  node --version
  python --version
  java --version
"

echo ""
echo "Tool versions (Nix):"
docker run --rm terminal-nix:latest sh -c "
  node --version
  python --version
  java --version
"
```

### 2.3 User Acceptance Testing

Ask team members to test:

```bash
# Give them access to both versions
docker pull your-registry/terminal:original
docker pull your-registry/terminal:nix

# Collect feedback on:
# - Build time
# - Tool availability
# - Configuration
# - Ease of use
```

## Phase 3: CI/CD Integration (Day 4)

### 3.1 Add Nix Build Workflow

Create `.github/workflows/nix-build.yml`:

```yaml
name: Build Nix Version

on:
  push:
    branches: [ "nix-migration" ]
    paths:
      - 'nix/**'
  pull_request:
    branches: [ "master" ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Install Nix
        uses: cachix/install-nix-action@v22
        with:
          extra_nix_config: |
            experimental-features = nix-command flakes
      
      - name: Build
        run: |
          cd nix
          nix flake check
          nix build .#docker
      
      - name: Test
        run: |
          cd nix
          docker load < result
          docker run --rm terminal-nix:latest node --version
```

### 3.2 Parallel Builds

Keep both workflows running:
- Original: `docker-image.yml` → `your-registry/terminal:latest`
- Nix: `nix-build.yml` → `your-registry/terminal:nix`

## Phase 4: Documentation (Day 5)

### 4.1 Create Migration Guide for Users

```markdown
# Migrating to Nix Version

## For Docker Users

### Old way:
docker pull your-registry/terminal:latest

### New way:
docker pull your-registry/terminal:nix

## For WSL Users

### Old way:
Not supported

### New way:
Follow [nix/wsl/README.md](nix/wsl/README.md)

## For Local Development

### Old way:
Clone repo, run scripts manually

### New way:
nix develop
```

### 4.2 Create FAQ

```markdown
# Migration FAQ

**Q: Do I need to migrate immediately?**
A: No, both versions will be supported for 3 months.

**Q: What if I encounter issues?**
A: Report on GitHub, we'll help troubleshoot.

**Q: Can I switch back?**
A: Yes, both versions available during transition.

**Q: Will my configs work?**
A: Most configs compatible, some adjustments needed.
```

## Phase 5: Gradual Rollout (Weeks 2-4)

### Week 2: Early Adopters

```bash
# Announce to team
# Ask for volunteers to test Nix version
# Provide support channel (Slack, Discord, etc.)

# Collect feedback
# Fix issues
# Update documentation
```

### Week 3: Wider Rollout

```bash
# Make Nix version the default in docs
# Update README to recommend Nix
# Keep original as fallback

# Update CI/CD to build both
# Tag Nix version as "latest"
# Tag original as "legacy"
```

### Week 4: Full Migration

```bash
# Announce deprecation timeline for original
# Provide migration deadline (e.g., 3 months)
# Offer migration support

# Update all documentation
# Update examples to use Nix
# Archive original scripts
```

## Phase 6: Cleanup (Month 2-3)

### Month 2: Deprecation Notice

```markdown
# ⚠️ DEPRECATION NOTICE

The original Debian/Docker implementation is deprecated.

- **Current**: Both versions supported
- **End of support**: [DATE]
- **Action required**: Migrate to Nix version

See [MIGRATION.md](MIGRATION.md) for help.
```

### Month 3: Archive Original

```bash
# Move original files to archive/
mkdir -p archive/original
mv Dockerfile archive/original/
mv *.sh archive/original/

# Update README
# Remove original CI/CD workflow
# Keep only Nix implementation

# Tag final original version
git tag -a original-final -m "Final version of original implementation"
```

## Rollback Plan

If critical issues arise:

### Immediate Rollback

```bash
# Revert to original in CI/CD
# Update Docker tags
docker tag your-registry/terminal:original your-registry/terminal:latest
docker push your-registry/terminal:latest

# Announce rollback
# Investigate issues
# Fix and retry
```

### Partial Rollback

```bash
# Keep Nix for new users
# Allow existing users to stay on original
# Fix issues before wider rollout
```

## Success Metrics

Track these metrics during migration:

### Build Performance
- Original build time: ~20 minutes
- Nix build time: ~5 minutes
- **Target**: 75% reduction

### Adoption Rate
- Week 1: 10% of users
- Week 2: 30% of users
- Week 3: 60% of users
- Week 4: 90% of users

### Issue Reports
- Track issues per version
- Response time
- Resolution time
- **Target**: <5 issues per week

### User Satisfaction
- Survey users
- Collect feedback
- **Target**: >80% satisfaction

## Communication Plan

### Week 1: Announcement

```
Subject: New Nix-based Terminal Environment Available

We're excited to announce a new Nix-based implementation of our terminal environment!

Benefits:
- 5-10x faster builds
- Reproducible environments
- Works on Docker, WSL, Linux, macOS

Try it out: [link to docs]
Feedback: [link to feedback form]
```

### Week 2: Update

```
Subject: Nix Migration Update - Early Results

Thanks to our early adopters! Here's what we've learned:
- Average build time reduced from 20min to 5min
- 95% of tools work identically
- Minor config adjustments needed for [specific cases]

Next steps: [...]
```

### Week 3: Recommendation

```
Subject: Nix Version Now Recommended

Based on positive feedback, we now recommend the Nix version for all users.

The original version will be supported until [DATE].
Migration guide: [link]
```

### Month 2: Deprecation

```
Subject: Original Version Deprecation Timeline

The original Debian/Docker version will be deprecated on [DATE].

Please migrate to the Nix version by then.
Need help? [support channel]
```

## Troubleshooting Common Migration Issues

### Issue: "Nix not installed"

```bash
# Install Nix
curl -L https://nixos.org/nix/install | sh

# Enable flakes
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### Issue: "Build fails with hash mismatch"

```bash
# Update flake lock
nix flake update

# Rebuild
nix build .#docker
```

### Issue: "Tool X not available"

```bash
# Check if package exists
nix search nixpkgs tool-name

# Add to flake.nix or home.nix
# Rebuild
```

### Issue: "Config not applied"

```bash
# For home-manager
home-manager switch --flake .#homeConfig

# For NixOS
sudo nixos-rebuild switch --flake .#wsl
```

## Post-Migration

After successful migration:

1. **Archive original**: Move to `archive/` directory
2. **Update documentation**: Remove references to original
3. **Celebrate**: Share success metrics with team
4. **Iterate**: Continue improving Nix configuration
5. **Share**: Write blog post about migration experience

## Resources

- [Nix Manual](https://nixos.org/manual/nix/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [NixOS Discourse](https://discourse.nixos.org/)
- [Migration Support Channel](your-support-channel)

## Timeline Summary

| Phase | Duration | Key Activities |
|-------|----------|----------------|
| Preparation | Day 1 | Create branch, copy files |
| Testing | Days 2-3 | Local testing, comparison |
| CI/CD | Day 4 | Add workflows |
| Documentation | Day 5 | Write guides |
| Early Adopters | Week 2 | Volunteer testing |
| Wider Rollout | Week 3 | Make default |
| Full Migration | Week 4 | All users |
| Deprecation | Month 2 | Announce timeline |
| Cleanup | Month 3 | Archive original |

Total timeline: **3 months** from start to complete migration.