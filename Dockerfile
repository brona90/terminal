FROM debian:latest

ENV TERM xterm-256color

# only use bash for bootstrap
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Bootstrapping packages needed for installation
RUN                                           \
  apt-get update &&                           \
  apt-get install -yqq                        \
        locales                               \
        lsb-release                           \
        software-properties-common &&         \
  apt-get clean

# Set locale to UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
RUN localedef -i en_US -f UTF-8 en_US.UTF-8 && \
  /usr/sbin/update-locale LANG=$LANG

# Install dependencies
RUN DEBIAN_FRONTEND=noninteractive  \
  apt-get update &&                 \
  apt-get -yqq install              \
    autoconf                        \
    make                            \
    rlwrap                          \
    build-essential                 \
    curl                            \
    tree                            \
    fasd                            \
    fontconfig                      \
    git                             \
    sudo                            \
    tmux                            \
    vim                             \
    emacs                           \
    wget                            \
    procps                          \
    htop                            \
    dirmngr                         \
    gpg                             \
    gawk                            \
    autoconf                        \
    gettext                         \
    libssl-dev                      \
    zlib1g-dev                      \
    zsh &&                          \
  apt-get clean &&                  \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG USERNAME=gfoster
ARG TTYPORT=8080

# add user and set password to password
RUN useradd -ms /bin/zsh ${USERNAME}                  && \
      usermod -aG sudo ${USERNAME}                    && \
      chown -R ${USERNAME} /usr/local/bin             && \
      echo "${USERNAME}:password" | chpasswd

# copy all shell scripts
COPY *.sh /home/${USERNAME}

# Install btop
Run /home/${USERNAME}/btop.sh

# Install cheat.sh
RUN /home/${USERNAME}/cheat.sh

USER ${USERNAME}

# Install oh-my-zsh before adding config
RUN /home/${USERNAME}/oh-my-zsh.sh

# Install config dot files
RUN /home/${USERNAME}/config_setup.sh

# Install asdf and tools from tool-versions
RUN /home/${USERNAME}/asdf.sh

# Install doom emacs
RUN /home/${USERNAME}/emacs.sh

# Install tmux config
RUN /home/${USERNAME}/tmux.sh

# Install ttyd
RUN /home/${USERNAME}/ttyd.sh

ENV USERNAME ${USERNAME}
ENV TTYPORT ${TTYPORT}

EXPOSE ${TTYPORT}

CMD /usr/local/bin/ttyd -p ${TTYPORT} tmux new -As0
