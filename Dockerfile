ARG BASE_ARCH=amd64
FROM ${BASE_ARCH}/ubuntu:18.04
ARG TARGET_ARCH=x86_64
ARG USER=adam
ENV TZ=America/Chicago
COPY qemu-${TARGET_ARCH}-static /usr/bin/
RUN apt-get update && apt-get install -y --no-install-recommends sudo htop tmux nano git openssh-client zsh curl wget httpie stow
RUN groupadd docker \
&& useradd -m -G docker $USER \
&& echo "$USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USER

USER $USER
WORKDIR /home/$USER

RUN	git clone https://github.com/robbyrussell/oh-my-zsh.git .oh-my-zsh
RUN git clone https://github.com/ags131/dotfiles src/dotfiles --recurse-submodules  \
&& rm .bash* \
&& mkdir .zsh_custom bin \
&& cd src/dotfiles \
&& cp bin/\$ $HOME/bin/ \
&& stow -R -t $HOME bash zsh git shell tmux \
&& stow -R -t $HOME/.zsh_custom .zsh_custom

RUN cd bin \
&& curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/${TARGET_ARCH}/kubectl \
&& curl -LO https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx \
&& curl -LO https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens \
&& chmod +x kube*

CMD ["zsh"]%  