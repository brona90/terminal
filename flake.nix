{
  description = "Terminal environment with Nix - migrated from Debian/Docker setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    flake-utils.url = "github:numtide/flake-utils";
    
    # For NixOS WSL
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, nixos-wsl }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        
        # User configuration
        username = "gfoster";
        homeDirectory = "/home/${username}";
        
        # Common packages used across all configurations
        commonPackages = with pkgs; [
          # Development tools
          gcc
          gnumake
          binutils
          autoconf
          gettext
          
          # Version control
          git
          
          # Editors
          vim
          emacs
          
          # Terminal multiplexer
          tmux
          
          # Shell
          zsh
          oh-my-zsh
          
          # System monitoring
          btop
          htop
          procps
          
          # File utilities
          tree
          unzip
          
          # Network tools
          curl
          wget
          
          # Prompt
          starship
          
          # Programming languages and tools
          nodejs
          python3
          openjdk
          ghc
          perl
          ruby
          jq
          sbcl
          
          # Kubernetes tools
          minikube
          k9s
          
          # Terminal utilities
          ttyd
          rlwrap
          
          # Build dependencies
          openssl
          zlib
          fontconfig
          
          # Additional utilities
          gawk
          gnupg
          sudo
        ];
        
      in
      {
        # Development shell for testing
        devShells.default = pkgs.mkShell {
          buildInputs = commonPackages;
          
          shellHook = ''
            echo "Terminal Nix Environment"
            echo "========================"
            echo "All tools are available in this shell"
            echo ""
            echo "Try: starship --version"
            echo "     node --version"
            echo "     python --version"
          '';
        };
        
        # Docker image output
        packages.docker = pkgs.dockerTools.buildLayeredImage {
          name = "terminal-nix";
          tag = "latest";
          
          contents = commonPackages ++ [
            # Add a basic filesystem structure
            pkgs.dockerTools.usrBinEnv
            pkgs.dockerTools.binSh
            pkgs.dockerTools.caCertificates
            pkgs.dockerTools.fakeNss
          ];
          
          extraCommands = ''
            # Create necessary directories
            mkdir -p tmp
            mkdir -p home/${username}
            
            # Set up user
            echo "${username}:x:1000:1000:${username}:/home/${username}:/bin/zsh" > etc/passwd
            echo "${username}:x:1000:" > etc/group
            echo "${username}:password" > etc/shadow
          '';
          
          config = {
            Cmd = [ 
              "${pkgs.ttyd}/bin/ttyd" 
              "-p" "8080" 
              "${pkgs.tmux}/bin/tmux" 
              "new" 
              "-As0" 
            ];
            ExposedPorts = {
              "8080/tcp" = {};
            };
            Env = [
              "TERM=xterm-256color"
              "LANGUAGE=en_US.UTF-8"
              "LANG=en_US.UTF-8"
              "USERNAME=${username}"
              "TTYPORT=8080"
              "PATH=/usr/bin:/bin"
            ];
            User = username;
            WorkingDir = "/home/${username}";
          };
        };
        
        # Standalone home-manager configuration
        packages.homeConfig = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          
          modules = [
            ./home.nix
            {
              home = {
                inherit username homeDirectory;
                stateVersion = "23.11";
              };
            }
          ];
        };
      }
    ) // {
      # NixOS WSL configuration
      nixosConfigurations.wsl = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-wsl.nixosModules.wsl
          ./wsl/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.gfoster = import ./home.nix;
          }
        ];
      };
    };
}