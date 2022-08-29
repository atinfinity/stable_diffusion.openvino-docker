FROM ubuntu:20.04

ARG UID=1000
ARG GID=1000

# add new sudo user
ENV USERNAME stable_diffusion
ENV HOME /home/$USERNAME
RUN useradd -m $USERNAME && \
        echo "$USERNAME:$USERNAME" | chpasswd && \
        usermod --shell /bin/bash $USERNAME && \
        usermod -aG sudo $USERNAME && \
        mkdir /etc/sudoers.d && \
        echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME && \
        chmod 0440 /etc/sudoers.d/$USERNAME && \
        usermod  --uid $UID $USERNAME && \
        groupmod --gid $GID $USERNAME

# install package
RUN echo "Acquire::GzipIndexes \"false\"; Acquire::CompressionTypes::Order:: \"gz\";" > /etc/apt/apt.conf.d/docker-gzip-indexes
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
        sudo \
        less \
        emacs \
        tmux \
        bash-completion \
        command-not-found \
        software-properties-common \
        curl \
        wget \
        build-essential \
        git \
        libgl1-mesa-dev \
        python3-pip \
        python3-venv \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER $USERNAME
WORKDIR /home/$USERNAME
SHELL ["/bin/bash", "-l", "-c"]
RUN python3 -m venv openvino_env &&\
    source openvino_env/bin/activate && \
    python -m pip install --upgrade pip && \
    pip install openvino==2022.1.0 && \
    git clone https://github.com/bes-dev/stable_diffusion.openvino.git && \
    cd stable_diffusion.openvino && \
    pip install -r requirements.txt
RUN echo "source ~/openvino_env/bin/activate" >> ~/.bashrc
WORKDIR /home/$USERNAME/stable_diffusion.openvino

