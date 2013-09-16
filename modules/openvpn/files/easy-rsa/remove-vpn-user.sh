#!/bin/bash


die() {
    local m="$1"

    echo "$m" >&2
    exit 1
}

usage() {
    echo "Usage: remove-vpn-user.sh [options...] [common-name]"
    echo "Options:"
    echo "  --keep-config : don't remove ip or firewall settings"
    echo "  --keep-key    : don't remove users private key"
    echo "  --help        : print this help message"
}

keep_cfg=0
keep_key=0

# Process options
while [ $# -gt 0 ]; do
    case "$1" in
        --keep-config  ) keep_cfg=1;;
        --keep-key     ) keep_key=1;;
        --help)
                    usage
                    exit ;;
        # errors
        --*        ) die "ERROR: unknown option: $1" ;;
        *          ) break ;;
    esac
    shift
done

if [ $# -ne 1 ]; then
    usage
    exit 1
fi

name=$(echo $1 | tr '[A-Z]' '[a-z]')
domain=$(echo $name|cut -f 2 -d '@')

if [ -z "$domain" ];then die "ERROR: common name is expected to be an email address" ; fi

if [ "$domain" == "devbliss.com" ];then
    trust=devbliss
else
    trust=other
fi

confdir=/etc/openvpn
ccd=$confdir/ccd
fw_rules=$confdir/iptables.rules.d

echo "INFO: revoking certificate for $name"
cd $confdir/easy-rsa
. vars
./revoke-full $name

if [ "$keep_key" == "0" ];then
    rm -f $confdir/keys/$name.key
fi
rm -f $confdir/keys/$name.crt
rm -f $confdir/keys/$name.csr

echo "kill $name"|nc 127.0.0.1 2010

if [ "$keep_cfg" == "0" ];then
    echo "INFO: removing client configuration and firewall settings"
    if [ ! -f $ccd/$name ];then
        echo "WARN: Cannot find client configuration $ccd/$name, please check." >&2
        exit 1
    fi

    ip_range=$(grep 'ifconfig-push' $ccd/$name | sed 's/ifconfig-push //')
    sed -i "s/^#${ip_range}$/${ip_range}/" $ccd/.${trust}.ip-ranges

    rm -f $ccd/$name
    ip=$(echo $ip_range|awk '{print $1}')
    rm -f $fw_rules/$ip.fw
    rm -f $fw_rules/$ip.fw.link
    /etc/init.d/firewall start
fi

