FROM ubuntu:18.04
#
# ENV DEBIAN_FRONTEND=noninteractive
#
# RUN apt update &&                 \
# apt install -y                    \
#   fonts-powerline                 \
#   zsh                             \
#   tmux                            \
#   vim                             \
#   emacs                           \
#   htop                            \
#   git                             \
#   curl                            \
#   wget                            \
#   tree                            \
#   ruby
#
ENV TERM xterm-256color

# Bootstrapping packages needed for installation
RUN \
  apt-get update && \
    apt-get install -yqq \
        locales \
            lsb-release \
                software-properties-common && \
                  apt-get clean

# Set locale to UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
RUN localedef -i en_US -f UTF-8 en_US.UTF-8 && \
  /usr/sbin/update-locale LANG=$LANG

# Install dependencies
# `universe` is needed for ruby
# `security` is needed for fontconfig and fc-cache
# Let the container know that there is no tty
RUN DEBIAN_FRONTEND=noninteractive \
  add-apt-repository ppa:aacebedo/fasd && \
  apt-get update && \
  apt-get -yqq install \
    autoconf \
    build-essential \
    curl \
    fasd \
    fontconfig \
    git \
    python \
    python-setuptools \
    python-dev \
    ruby-full \
    sudo \
    tmux \
    vim \
    emacs \
    wget \
    zsh && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN useradd -ms /bin/zsh gdfoster

USER gdfoster

RUN  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash

ARG commit=f881a0bf6ceda11f8e85afce959621d2861ed476

RUN curl -o ${HOME}/config_setup.sh \
  https://gist.githubusercontent.com/brona90/4e70d4cab20ebf910870f2b3242a25b6/raw/$commit/config_setup.sh && \
  cd ${HOME} && bash config_setup.sh && \
  zsh && \
  nvm install --lts


CMD ["/bin/zsh"]
