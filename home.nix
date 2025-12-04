{ config, pkgs, lib, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = lib.mkDefault "gfoster";
  home.homeDirectory = lib.mkDefault "/home/gfoster";

  # This value determines the Home Manager release that your
  # configuration is compatible with.
  home.stateVersion = "23.11";

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
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
    emacs29
    
    # Terminal multiplexer
    tmux
    
    # System monitoring
    btop
    htop
    procps
    
    # File utilities
    tree
    fasd
    unzip
    
    # Network tools
    curl
    wget
    
    # Prompt
    starship
    
    # Programming languages and tools
    nodejs_21
    python310
    jdk21
    ghc
    perl538
    ruby_3_2
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
    dirmngr
  ];

  # Git configuration
  programs.git = {
    enable = true;
    userName = "gfoster";
    userEmail = "gfoster@example.com"; # Update with actual email
    
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      core.editor = "vim";
    };
    
    aliases = {
      co = "checkout";
      br = "branch";
      ci = "commit";
      st = "status";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
      visual = "log --graph --oneline --all";
    };
  };

  # Zsh configuration with oh-my-zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "vi-mode"
        "z"
      ];
    };
    
    plugins = [
      {
        name = "zsh-history-substring-search";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-history-substring-search";
          rev = "v1.1.0";
          sha256 = "sha256-4PZ8YKZX8kLSqh0bNQJzCqVaJJQJqvJJqKKLqJJqKKM=";
        };
      }
      {
        name = "fast-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zdharma-continuum";
          repo = "fast-syntax-highlighting";
          rev = "v1.55";
          sha256 = "sha256-DWVFBoICroKaKgByLmDEo4O+xo6eA8YO792g8t8R7kA=";
        };
      }
      {
        name = "zsh-alias-finder";
        src = pkgs.fetchFromGitHub {
          owner = "akash329d";
          repo = "zsh-alias-finder";
          rev = "1.0.0";
          sha256 = "sha256-6W3XQFZ0JqJXJKZZZJZZZJZZZJZZZJZZZJZZZJZZZJQ=";
        };
      }
    ];
    
    initExtra = ''
      # Enable correction
      setopt CORRECT
      setopt CORRECT_ALL
      
      # History substring search keybindings
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down
      bindkey "$terminfo[kcuu1]" history-substring-search-up
      bindkey "$terminfo[kcud1]" history-substring-search-down
      
      # Initialize starship prompt
      eval "$(starship init zsh)"
      
      # Load custom configurations
      if [ -d $HOME/.zsh.before/ ]; then
        if [ "$(ls -A $HOME/.zsh.before/)" ]; then
          for config_file ($HOME/.zsh.before/*.zsh) source $config_file
        fi
      fi
      
      if [ -d $HOME/.zsh.after/ ]; then
        if [ "$(ls -A $HOME/.zsh.after/)" ]; then
          for config_file ($HOME/.zsh.after/*.zsh) source $config_file
        fi
      fi
    '';
    
    shellAliases = {
      # Common aliases
      ll = "ls -lah";
      la = "ls -A";
      l = "ls -CF";
      
      # Git aliases
      g = "git";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      gd = "git diff";
      
      # Safety aliases
      rm = "rm -i";
      cp = "cp -i";
      mv = "mv -i";
      
      # Utility aliases
      grep = "grep --color=auto";
      fgrep = "fgrep --color=auto";
      egrep = "egrep --color=auto";
    };
    
    history = {
      size = 10000;
      save = 10000;
      path = "${config.home.homeDirectory}/.zsh_history";
      ignoreDups = true;
      share = true;
    };
  };

  # Tmux configuration
  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    historyLimit = 10000;
    keyMode = "vi";
    mouse = true;
    
    extraConfig = ''
      # Set prefix to Ctrl-a
      unbind C-b
      set -g prefix C-a
      bind C-a send-prefix
      
      # Split panes using | and -
      bind | split-window -h
      bind - split-window -v
      unbind '"'
      unbind %
      
      # Reload config
      bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"
      
      # Switch panes using Alt-arrow without prefix
      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D
      
      # Enable mouse mode
      set -g mouse on
      
      # Don't rename windows automatically
      set-option -g allow-rename off
      
      # Start windows and panes at 1, not 0
      set -g base-index 1
      setw -g pane-base-index 1
      
      # Status bar
      set -g status-position bottom
      set -g status-justify left
      set -g status-style 'bg=colour234 fg=colour137'
      set -g status-left ""
      set -g status-right '#[fg=colour233,bg=colour241,bold] %d/%m #[fg=colour233,bg=colour245,bold] %H:%M:%S '
      set -g status-right-length 50
      set -g status-left-length 20
      
      setw -g window-status-current-style 'fg=colour1 bg=colour19 bold'
      setw -g window-status-current-format ' #I#[fg=colour249]:#[fg=colour255]#W#[fg=colour249]#F '
      
      setw -g window-status-style 'fg=colour9 bg=colour18'
      setw -g window-status-format ' #I#[fg=colour237]:#[fg=colour250]#W#[fg=colour244]#F '
    '';
  };

  # Vim configuration
  programs.vim = {
    enable = true;
    defaultEditor = true;
    
    settings = {
      number = true;
      relativenumber = true;
      expandtab = true;
      tabstop = 2;
      shiftwidth = 2;
      smartindent = true;
      ignorecase = true;
      smartcase = true;
      hlsearch = true;
      incsearch = true;
    };
    
    extraConfig = ''
      " Enable syntax highlighting
      syntax on
      
      " Enable file type detection
      filetype plugin indent on
      
      " Set colorscheme
      colorscheme desert
      
      " Show matching brackets
      set showmatch
      
      " Enable mouse support
      set mouse=a
      
      " Set encoding
      set encoding=utf-8
      
      " Disable backup files
      set nobackup
      set nowritebackup
      set noswapfile
      
      " Better command-line completion
      set wildmenu
      set wildmode=longest:full,full
      
      " Show partial commands
      set showcmd
      
      " Highlight current line
      set cursorline
      
      " Keep cursor centered
      set scrolloff=8
      
      " Split windows below and right
      set splitbelow
      set splitright
    '';
  };

  # Starship prompt configuration
  programs.starship = {
    enable = true;
    
    settings = {
      add_newline = true;
      
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
      
      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
      };
      
      git_branch = {
        symbol = "🌱 ";
      };
      
      git_status = {
        ahead = "⇡\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        behind = "⇣\${count}";
      };
      
      nodejs = {
        symbol = "⬢ ";
      };
      
      python = {
        symbol = "🐍 ";
      };
      
      rust = {
        symbol = "🦀 ";
      };
    };
  };

  # Direnv for automatic environment loading
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # Btop configuration
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "Default";
      theme_background = false;
      update_ms = 2000;
      proc_sorting = "cpu lazy";
      proc_tree = false;
      proc_colors = true;
      proc_gradient = true;
      proc_per_core = false;
      proc_mem_bytes = true;
      cpu_graph_upper = "total";
      cpu_graph_lower = "total";
      cpu_single_graph = false;
      show_uptime = true;
      check_temp = true;
      show_coretemp = true;
      temp_scale = "celsius";
      show_cpu_freq = true;
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Environment variables
  home.sessionVariables = {
    EDITOR = "vim";
    VISUAL = "vim";
    TERM = "xterm-256color";
    LANGUAGE = "en_US.UTF-8";
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };

  # XDG directories
  xdg.enable = true;
  
  # Create necessary directories
  home.file.".zsh.before/.keep".text = "";
  home.file.".zsh.after/.keep".text = "";
}