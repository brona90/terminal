FROM debian:latest

ARG USERNAME=gfoster
ARG TTYPORT=8080

ENV TERM xterm-256color

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Bootstrapping packages needed for installation
RUN                                           \
  apt-get update &&                           \
    apt-get install -yqq                      \
        locales                               \
            lsb-release                       \
                software-properties-common && \
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

# install starship
RUN curl -s https://api.github.com/repos/starship/starship/releases/latest \
  | grep browser_download_url       \
  | grep x86_64-unknown-linux-gnu   \
  | cut -d '"' -f 4                 \
  | wget -qi - &&                   \
  tar xvf starship-*.tar.gz &&      \
  mv starship /usr/local/bin &&     \
  rm -rf starship*

# add user and set password to password
RUN useradd -ms /bin/zsh ${USERNAME}                  && \
      usermod -aG sudo ${USERNAME}                    && \
      chown ${USERNAME}:${USERNAME} /home/${USERNAME} && \
      echo "${USERNAME}:password" | chpasswd

# copy all shell scripts 
COPY *.sh /home/${USERNAME}

# Install cheat.sh
RUN /home/${USERNAME}/cheat.sh

USER ${USERNAME}

COPY --chown=${USERNAME}:${USERNAME} .tool-versions /home/${USERNAME}

# Install asdf and tools from tool-versions
RUN /home/${USERNAME}/asdf.sh

# Install config dot files
RUN /home/${USERNAME}/config_setup.sh

# Install spacemaces
RUN /home/${USERNAME}/emacs.sh

# Install yadr
RUN /home/${USERNAME}/yadr.sh

# Install tmux config
RUN /home/${USERNAME}/tmux.sh

# Install gotty
RUN /home/${USERNAME}/gotty.sh

ENV USERNAME ${USERNAME}
ENV TTYPORT ${TTYPORT}

EXPOSE ${TTYPORT}

CMD /home/${USERNAME}/.asdf/shims/gotty -w -p ${TTYPORT} tmux
# CMD zsh