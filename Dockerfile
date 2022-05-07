FROM debian:latest

ARG USERNAME=gdfoster

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
    hugo                            \
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

RUN curl -s https://api.github.com/repos/starship/starship/releases/latest \
  | grep browser_download_url       \
  | grep x86_64-unknown-linux-gnu   \
  | cut -d '"' -f 4                 \
  | wget -qi - &&                   \
  tar xvf starship-*.tar.gz &&      \
  mv starship /usr/local/bin &&     \
  rm -rf starship*

RUN useradd -ms /bin/zsh ${USERNAME}  && \
      usermod -aG sudo ${USERNAME}    && \
      echo "${USERNAME}:password" | chpasswd

USER ${USERNAME}

RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.10.0

COPY *.sh /home/${USERNAME}

COPY --chown=${USERNAME}:${USERNAME} .tool-versions /home/${USERNAME}

RUN /home/${USERNAME}/asdf.sh

RUN /home/${USERNAME}/config_setup.sh 

ENV USERNAME ${USERNAME}
ENV TTYPORT ${TTYPORT}

EXPOSE ${TTYPORT}

# CMD /home/${USERNAME}/go/bin/gotty -w -p ${TTYPORT} zsh
CMD zsh