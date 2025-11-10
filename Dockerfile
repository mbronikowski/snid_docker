FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies and tools
RUN echo "deb http://deb.debian.org/debian bookworm main contrib non-free" > /etc/apt/sources.list && \
    echo "deb http://deb.debian.org/debian bookworm-updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb http://security.debian.org/debian-security bookworm-security main contrib non-free" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential gfortran ca-certificates wget tar unzip \
        libx11-dev libxext-dev libxrender-dev libxt-dev \
        pgplot5 && \
    update-ca-certificates && \
    rm -rf /var/lib/apt/lists/*

ARG USER_ID=1000
ARG GROUP_ID=1000
ARG USER_NAME=sniduser
ARG GROUP_NAME=snidgroup

RUN if ! getent group ${GROUP_ID} >/dev/null; then \
        groupadd -g ${GROUP_ID} ${GROUP_NAME}; \
    else \
        GROUP_NAME=$(getent group ${GROUP_ID} | cut -d: -f1); \
    fi && \
    useradd -m -u ${USER_ID} -g ${GROUP_ID} ${USER_NAME}

ENV HOME_DIR=/home/${USER_NAME}

WORKDIR /opt/
ENV SNID_DIR=/opt/snid-5.0

RUN wget 'https://people.lam.fr/blondin.stephane/software/snid/snid-5.0.tar.gz' && \
    tar -xvf snid-5.0.tar.gz && \
    rm snid-5.0.tar.gz

# Add Super-SNID templates
RUN rm -rf ${SNID_DIR}/template* && \
    wget -O $SNID_DIR/source/snid.inc \
       https://raw.githubusercontent.com/dkjmagill/QUB-SNID-Templates/main/snid.inc && \
    wget -O $SNID_DIR/source/typeinfo.f \
       https://raw.githubusercontent.com/dkjmagill/QUB-SNID-Templates/main/typeinfo.f && \ 
    wget -O templates.zip \
       https://raw.githubusercontent.com/dkjmagill/QUB-SNID-Templates/main/templates.zip && \
    unzip templates.zip && \
    mv templates ${SNID_DIR}/ && \ 
    rm -rf templates.zip templates __MACOSX

ENV LD_LIBRARY_PATH="/usr/lib"
ENV PGPLOT_DIR="/usr/lib/pgplot5"

RUN sed -i \
        -e '140s|.*|FC= gfortran|' \
        -e '141s|.*|FFLAGS= -O -fno-automatic  -fallow-argument-mismatch|' \
        -e '142s|.*|XLIBS = -L/usr/lib/x86_64-linux-gnu -lX11|' \
        -e '143s|.*|PGLIBS = -L/usr/lib -lpgplot -lcpgplot|' ${SNID_DIR}/Makefile && \
    sed -i "52s|.*|      tempdir='${SNID_DIR}/templates/'|" "${SNID_DIR}/source/snidmore.f"

WORKDIR ${SNID_DIR}
RUN make && \
    make install && \
    cp snid plotlnw logwave /usr/local/bin/ && \
    chown -R ${USER_NAME}:${GROUP_NAME} ${SNID_DIR}
USER ${USER_NAME}
WORKDIR ${HOME_DIR}/workdir

CMD [ "snid" ]
