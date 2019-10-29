# kcp-server & v2ray for Dockerfile
FROM alpine:3.4
MAINTAINER timidev

ENV V2RAY_URL=https://github.com/v2ray/v2ray-core/releases/download/v4.21.3/v2ray-linux-64.zip \
    V2RAY_DIR=/usr/local/v2ray \
    CONF_DIR="/usr/local/conf" \
    KCPTUN_URL="https://github.com/xtaci/kcptun/releases/download/v20190924/kcptun-linux-amd64-20190924.tar.gz" \
    KCPTUN_DIR=/usr/local/kcp-server

RUN set -ex && \
    apk add --no-cache pcre bash && \
    apk add --no-cache  wget tar zlib-dev && \
    mkdir -p ${V2RAY_DIR} && \
    mkdir -p ${KCPTUN_DIR} && \
    cd ${V2RAY_DIR} && \    
    wget --no-check-certificate ${V2RAY_URL}  && \
    unzip v2ray-linux-64.zip && \
    chown root:root ${V2RAY_DIR}/* && \
    chmod 755 ${V2RAY_DIR}/* && \
    ln -s ${V2RAY_DIR}/* /bin/ && \
    cd ${KCPTUN_DIR} && \    
    wget --no-check-certificate ${KCPTUN_URL} && \
    tar -xf kcptun-linux-amd64-20190924.tar.gz && \
    rm -f ${KCPTUN_DIR}/client_linux_amd64  && \
    chown root:root ${KCPTUN_DIR}/* && \
    chmod 755 ${KCPTUN_DIR}/* && \
    ln -s ${KCPTUN_DIR}/* /bin/ && \
    rm -rf /var/cache/apk/* ~/.cache 

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

