# FROM ubuntu:18.04
FROM debian

ARG USERNAME=gdfoster
ARG TTYPORT=8080

ENV TERM xterm-256color

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

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
  # add-apt-repository ppa:aacebedo/fasd && \
  apt-get update && \
  apt-get -yqq install \
    autoconf \
    build-essential \
    curl \
    tree \
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
    procps \
    zsh && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN wget https://golang.org/dl/go1.15.8.linux-amd64.tar.gz && \
  tar -C /usr/local -xzf go1.15.8.linux-amd64.tar.gz && \
  rm -f go1.15.8.linux-amd64.tar.gz

RUN useradd -ms /bin/zsh $USERNAME

USER $USERNAME

COPY config_setup.sh /home/$USERNAME

RUN cd ${HOME} && bash config_setup.sh

ENV USERNAME ${USERNAME}
ENV TTYPORT ${TTYPORT}

EXPOSE ${TTYPORT}

WORKDIR $HOME

CMD /home/${USERNAME}/go/bin/gotty -w -p ${TTYPORT} zsh
