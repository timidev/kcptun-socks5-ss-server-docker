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
V2RAY_PORT=${V2RAY_PORT:-300}      
V2RAY_ID=${V2RAY_ID:-f8fd62f9-236e-4c9b-9cd4-5133cbea3d52}      
V2RAY_ALTERID=${V2RAY_ALTERID:-64}
# ======= KCPTUN CONFIG ======
KCPTUN_LISTEN=${KCPTUN_LISTEN:-301}                         #"listen": ":301",
KCPTUN_KEY=${KCPTUN_KEY:-bovi123}                            
KCPTUN_CRYPT=${KCPTUN_CRYPT:-aes-192}                             #"crypt": "aes",
KCPTUN_MODE=${KCPTUN_MODE:-fast3}                             #"mode": "fast2",
KCPTUN_MTU=${KCPTUN_MTU:-1000}                                #"mtu": 1350,
KCPTUN_SNDWND=${KCPTUN_SNDWND:-4096}                          #"sndwnd": 1024,
KCPTUN_RCVWND=${KCPTUN_RCVWND:-1024}                          #"rcvwnd": 1024,
KCPTUN_NOCOMP=${KCPTUN_NOCOMP:-false}                         #"nocomp": false

[ ! -f ${V2RAY_CONF} ] && cat > ${V2RAY_CONF}<<-EOF
{
"log": {
    "access": "/etc/v2ray/log/access.log",
    "error": "/etc/v2ray/log/error.log",
    "loglevel": "error"
  },
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
      },
      {
        "port": 301, // Vmess 协议服务器监听端口
        "protocol": "vmess",
        "settings": {
          "clients": [
            {
              "alterId": ${V2RAY_ALTERID},
              "id": "${V2RAY_ID}"
            }
          ]
        },
        "streamSettings": {
          "network": "mkcp", //此处的 mkcp 也可写成 kcp，两种写法是起同样的效果
          "kcpSettings": {
            "uplinkCapacity": 5,
            "downlinkCapacity": 100,
            "congestion": true,
            "header": {
              "type": "none"
            }
          }
        }
      },
      {
        "port": 302, // SS 协议服务端监听端口
        "protocol": "shadowsocks",
        "settings": {
          "method": "aes-128-gcm", // 加密方式
          "password": "bovi123" //密码
        }
      }
    ],
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
nohup v2ray -config ${V2RAY_CONF}  >/dev/null 2>&1 &
sleep 0.5
echo "v2ray (pid `pidof v2ray`)is running."
netstat -ntlup | grep v2ray
echo "Starting Kcptun for v2ray..."
server_linux_amd64 -c ${KCPTUN_CONF}  

echo "Kcptun for v2ray (pid `pidof server_linux_amd64`)is running."
netstat -ntlup | grep server_linux_amd64
    

