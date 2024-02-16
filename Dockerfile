ARG     PASTREE_BASE_IMAGE
FROM    ${PASTREE_BASE_IMAGE}

# APT-GET context
ARG     DEBIAN_FRONTEND=noninteractive
ARG     APTGET_OPTS="-y --no-install-recommends"

# Set preferences
ARG     DEFAULT_CC
ARG     DEFAULT_EDITOR
RUN     echo "export CC=\"${DEFAULT_CC}\"" >> /etc/bash.bashrc
RUN     DEFAULT_EDITOR_PATH=$(which ${DEFAULT_EDITOR}) \
        && update-alternatives --install /usr/bin/editor editor ${DEFAULT_EDITOR_PATH} 100 \
        && update-alternatives --set editor ${DEFAULT_EDITOR_PATH}

# Set 'root' password
ARG     ROOT_PWD
RUN     echo "root:${ROOT_PWD}" | chpasswd

# Groups
ARG     GID0
ARG     GID0_NAME
RUN     addgroup --gid ${GID0} ${GID0_NAME}

# Users
ARG     UID0
ARG     UID0_PWD
ARG     UID0_NAME
ARG     UID0_GECOS
RUN     adduser --uid ${UID0} --gid ${GID0} --gecos "${UID0_GECOS}" ${UID0_NAME} \
        && echo "${UID0_NAME}:${UID0_PWD}" | chpasswd \
        && apt-get install ${APTGET_OPTS} sudo \
        && echo "root ALL=(ALL) ALL" >> /etc/sudoers \
        && echo "${UID0_NAME} ALL=(ALL) ALL" >> /etc/sudoers

# Project files
ARG     PROJECT_DIR_PREFIX="/opt/pastree"
COPY    src ${PROJECT_DIR_PREFIX}

# Build project
# Subject to change. ${PROJECT_DIR_PREFIX}/client* -> ${PROJECT_DIR_PREFIX}/bin/client*
RUN     make -C ${PROJECT_DIR_PREFIX} \
        && echo "export PATH=\"${PROJECT_DIR_PREFIX}:\${PATH}\"" >> /etc/bash.bashrc

# Final clean up
RUN     apt-get ${APTGET_OPTS} clean \
        && apt-get ${APTGET_OPTS} autoremove

# Default user and working directory
USER    ${UID0_NAME}
WORKDIR /home/${UID0_NAME}
