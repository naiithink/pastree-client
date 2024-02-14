FROM    ubuntu:jammy

# Build Arguments
ARG     LIBDXP_GIT_REMOTE_URL
ARG     LIBDXP_GIT_REF
ARG     DEFAULT_CC
ARG     DEFAULT_EDITOR
ARG     ROOT_PWD
ARG     GID0
ARG     GID0_NAME
ARG     UID0
ARG     UID0_PWD
ARG     UID0_NAME
ARG     UID0_GECOS

# Set 'root' password
RUN     echo "root:${ROOT_PWD}" | chpasswd

# APT-GET options
ARG     APTGET_OPTS="-y --no-install-recommends"
ARG     APTGET_INSTALL="apt-get install ${APTGET_OPTS}"

# Update APT-GET package lists
RUN     export DEBIAN_FRONTEND=noninteractive \
        && apt-get update ${APTGET_OPTS} \
        && apt-get upgrade ${APTGET_OPTS}

# Users & groups
RUN     addgroup --gid ${GID0} ${GID0_NAME} \
        && adduser --uid ${UID0} --gid ${GID0} --gecos "${UID0_GECOS}" ${UID0_NAME} \
        && echo "${UID0_NAME}:${UID0_PWD}" | chpasswd \
        && apt-get install ${APTGET_OPTS} sudo \
        && echo "${UID0_NAME} ALL=(${UID0_NAME}:ALL) ALL" >> /etc/sudoers

# Essential packages
RUN     apt-get install ${APTGET_OPTS} build-essential clang emacs-nox git network-manager vim

# Libraries & other packages
RUN     apt-get ${APTGET_OPTS} clean \
        && apt-get ${APTGET_OPTS} autoremove

RUN     apt-get install ${APTGET_OPTS} libmagic-dev libssl-dev \
        && apt-get install ${APTGET_OPTS} curl wget \
        && apt-get install ${APTGET_OPTS} python3 python3-pip

# Set preferences
RUN     echo "export CC=\"${DEFAULT_CC}\"" >> /etc/bash.bashrc

RUN     DEFAULT_EDITOR_PATH=$(which ${DEFAULT_EDITOR}) \
        && update-alternatives --install /usr/bin/editor editor ${DEFAULT_EDITOR_PATH} 100 \
        && update-alternatives --set editor ${DEFAULT_EDITOR_PATH}

# Clone, build, and install libdxp
ENV     LIBDXP_PREFIX="/usr/local"
ENV     LIBDXP_PATH="${LIBDXP_PREFIX}/lib/libdxp"
RUN     git clone --recurse-submodules ${LIBDXP_GIT_REMOTE_URL} ${LIBDXP_PATH} \
        && cd ${LIBDXP_PATH} \
        && git checkout ${LIBDXP_GIT_REF} \
        && make \
        && ln -s ./lib/* ${LIBDXP_PREFIX} \
        && ln -s ./include ${LIBDXP_PREFIX}/include

# Project files
COPY    --chown=${UID0_NAME}:${GID0_NAME} --chmod=775 src /home/${UID0_NAME}/programs/pastree

# Build project
RUN     make -C /home/${UID0_NAME}/programs/pastree \
        && ln -s /home/${UID0_NAME}/programs/pastree/client /usr/local/bin/client

# Default user and working directory
USER    ${UID0_NAME}
WORKDIR /home/${UID0_NAME}
