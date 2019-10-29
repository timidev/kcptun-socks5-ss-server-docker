#!/bin/bash
#########################################################################
# File Name: kcptun-v2ray-server.sh
# Version:1.0.20191029
# Created Time: 2019-10-29
#########################################################################

set -e
KCPTUN_CONF="/usr/local/conf/kcptun_server_config.json"
V2RAY_CONF="/usr/local/conf/v2ray_server_config.json"
# ======= V2RAY CONFIG ======
V2RAY_PORT=${V2RAY_PORT:-301}      
V2RAY_ID=${V2RAY_ID:-f8fd62f9-236e-4c9b-9cd4-5133cbea3d52}      
V2RAY_ALTERID=${V2RAY_ALTERID:-64}
# ======= KCPTUN CONFIG ======
KCPTUN_LISTEN=${KCPTUN_LISTEN:-300}                         #"listen": ":301",
KCPTUN_KEY=${KCPTUN_KEY:-bovi123}                            
KCPTUN_CRYPT=${KCPTUN_CRYPT:-aes-192}                             #"crypt": "aes",
KCPTUN_MODE=${KCPTUN_MODE:-fast3}                             #"mode": "fast2",
KCPTUN_MTU=${KCPTUN_MTU:-1000}                                #"mtu": 1350,
KCPTUN_SNDWND=${KCPTUN_SNDWND:-4096}                          #"sndwnd": 1024,
KCPTUN_RCVWND=${KCPTUN_RCVWND:-1024}                          #"rcvwnd": 1024,
KCPTUN_NOCOMP=${KCPTUN_NOCOMP:-false}                         #"nocomp": false
mkdir -p /usr/local/conf/
[ ! -f ${V2RAY_CONF} ] && cat > ${V2RAY_CONF}<<-EOF
{
    "inbounds": [
      {
        "port": ${V2RAY_PORT},
        "protocol": "vmess",
        "settings": {
          "clients": [
            {
              "alterId": ${V2RAY_ALTERID},
              "id": "${V2RAY_ID}"
            }
          ]
        }      
      }],
    "outbounds": [
        {
            "protocol": "freedom",
            "settings": {}
        }
    ]
}

EOF


[ ! -f ${KCPTUN_CONF} ] && cat > ${KCPTUN_CONF}<<-EOF
{
    "listen": ":${KCPTUN_LISTEN}",
    "target": "127.0.0.1:${V2RAY_PORT}",
    "key": "${KCPTUN_KEY}",
    "crypt": "${KCPTUN_CRYPT}",
    "mode": "${KCPTUN_MODE}",
    "mtu": ${KCPTUN_MTU},
    "sndwnd": ${KCPTUN_SNDWND},
    "rcvwnd": ${KCPTUN_RCVWND},
    "nocomp": ${KCPTUN_NOCOMP}
}
EOF



echo "+---------------------------------------------------------+"
echo "|   Manager for Kcptun-V2ray  |"
echo "+---------------------------------------------------------+"
echo "|     Images: timidev/kcptunv2ray "
echo "+---------------------------------------------------------+"
echo "|      Intro: timidev/kcptunv2ray                         |"
echo "+---------------------------------------------------------+"
echo ""


echo "Starting v2ray..."
#exec v2ray -config ${V2RAY_CONF}
nohup v2ray -config ${V2RAY_CONF}  >/dev/null 2>&1 &
sleep 0.5
echo "v2ray is running."
echo "alterId: ${V2RAY_ALTERID}"
echo "id: ${V2RAY_ID}"

echo "Starting Kcptun for v2ray..."
exec server_linux_amd64 -c ${KCPTUN_CONF}  

    

