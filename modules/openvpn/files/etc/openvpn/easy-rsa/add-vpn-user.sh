#!/bin/bash


die() {
    local m="$1"

    echo "$m" >&2
    exit 1
}

usage() {
    echo "Usage: add-vpn-user.sh [options...] [common-name]"
    echo "Options:"
    echo "  --key-expire  : number of days until the cert will expire"
    echo "      days      : days (default=182)"
    echo "  --renew       : create a new cert for existing private key and mail it to the user"
    echo "  --print-cert  : print user certificate to STDOUT"
    echo "  --help        : print this help message"
}

# Process options
while [ $# -gt 0 ]; do
    case "$1" in
        --renew        ) renew=1;mailcert=1;;
        --print-cert   ) printcert=1;;
        --key-expire   ) key_expire=$(echo -n $2|sed 's/[^0-9]//g')
                         shift;;
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

# convert all email addresses to lowers string to prevent doubles
name=$(echo $1 | tr '[A-Z]' '[a-z]')
domain=$(echo $name|cut -f 2 -d '@')

if [ -z "$domain" ];then die "ERROR: common name is expected to be an email address" ; fi

if [ "$domain" == "devbliss.com" ];then
    trust=devbliss
    specific_rules='$IPTABLES -A fwd_!!IP!!_tun_eth -j ACCEPT'
    default_expires=365
else
    trust=other
    specific_rules=''
    default_expires=182
fi

if [ -z "$key_expire" ];then
    key_expire=$default_expires
fi

tmpdir=/tmp/tmp.$name
confdir=/etc/openvpn
ccd=$confdir/ccd
fw_rules=$confdir/iptables.rules.d

###########################################################
function create_fw_rules {

    ip=$1
    if [ -z "$ip" ];then die "ERROR: there is no ip given as arg1 in create_fw_rules" ; fi

    fw_file=$fw_rules/$ip.fw
    if [ -f $fw_file ];then
         echo "INFO: firewall rules for ip $ip already found in $fw_file. Keeping untouched."
    else
        echo "INFO: creating fw rules for ip: $ip"
        tpl=$fw_rules/.forward_chain.tpl
        if [ ! -f $tpl ];then die "ERROR: file $tpl does not exist" ; fi

        rules=$(echo ${specific_rules} | sed "s/!!IP!!/$ip/g")
        sed "s/!!IP!!/$ip/g" $tpl | sed "s/!!specific_rules!!/$rules/" > $fw_file
    fi

    ln -sf $ccd/$name ${fw_file}.link

    # apply our new rules
    echo "INFO: applying firewall rules ...."
    /etc/init.d/firewall start
}

function create_config {

    if [ -e $ccd/$name ];then
        echo "INFO: Using existing ccd file $ccd/$name"

        create_fw_rules $(grep 'ifconfig-push' $ccd/${name}|awk '{print $2}')

        return
    fi

    ip_range=$(grep -v '^#' $ccd/.${trust}.ip-ranges|head -1)
    if [ -z "$ip_range" ];then die "ERROR: there is no ip-range left for use in $ccd/.${trust}.ip-ranges" ; fi

    echo "INFO: creating config file $ccd/$name"
    sed -i "s/^${ip_range}$/#${ip_range}/" $ccd/.${trust}.ip-ranges
    echo "ifconfig-push $ip_range" > $ccd/$name
    cat $ccd/.${trust}.routes >> $ccd/$name

    create_fw_rules $(echo $ip_range|awk '{print $1}')
}
###########################################################

if [ "$renew" == "1" ];then
    if [ ! -f $confdir/keys/$name.key ];then die "ERROR: cannot find $confdir/keys/$name.key" ;fi
    echo "INFO: found private key $confdir/keys/$name.key"
    echo "INFO: revoking old cert"
    $confdir/easy-rsa/remove-vpn-user.sh --keep-config --keep-key $name
    echo "INFO: generating new cert"
    . $confdir/easy-rsa/vars
    cd $KEY_DIR
    KEY_CN=$name
    export KEY_CN
    openssl req -batch -days ${key_expire} -new -key $name.key -out $name.csr -config $KEY_CONFIG
    openssl ca -batch -days ${key_expire} -out $name.crt -in $name.csr -md sha1 -config $KEY_CONFIG
else
    count=$(find $confdir/keys/ -name "$name*"|wc -l)
    if [ "$count" != "0" ];then
        echo "INFO: there is already some stuff avilable for $name. I'll use this."
        if [ ! -f $confdir/keys/$name.key ];then die "ERROR: cannot find $confdir/keys/$name.key" ;fi
        if [ ! -f $confdir/keys/$name.crt ];then die "ERROR: cannot find $confdir/keys/$name.crt" ;fi
    else
        echo "INFO: creating cert for $name."
        cd $confdir/easy-rsa
        . vars
        export KEY_EXPIRE=${key_expire}
        ./pkitool $name
    fi
fi

create_config $name

rm -rf $tmpdir
mkdir -m 0700 -p $tmpdir

if [ "$mailcert" == "1" ];then
    echo "INFO: sending email with new cert to $name"
    cd $tmpdir
    cp $confdir/keys/$name.crt ./$name.crt.txt
    $confdir/easy-rsa/mail-file.pl --to $name --file $tmpdir/$name.crt.txt
else
    mkdir -m 0700 -p $tmpdir/devbliss.tblk

    cd $confdir
    cat client.ovpn.tpl | sed 's/USERNAME/'$name'/' > $tmpdir/devbliss.tblk/client.ovpn
    cp keys/ca.crt keys/ta.key keys/$name.crt keys/$name.key $tmpdir/devbliss.tblk/

    pass=$(pwgen -1)

    if [ -z "$pass" ];then die "ERROR: command pwgen is missing"; fi

    cd $tmpdir
    echo "INFO: zipping to devbliss.tblk.zip with password '$pass'"
    zip -P $pass -r devbliss.tblk.zip devbliss.tblk
    cd devbliss.tblk
    echo "INFO: zipping to devbliss.zip with password '$pass'"
    zip -P $pass ../devbliss.zip *



    echo "
    INFO: please provide OSX users with file $tmpdir/devbliss.tblk.zip
          or everyone else with $tmpdir/devbliss.zip
          and remember to remove $tmpdir/
    "
fi


if [ "$printcert" == "1" ];then
    echo "#####################################################################"
    echo "#### BEGIN: cert for $name"
    cat $confdir/keys/$name.crt
    echo "#### END: cert for $name"
    echo "#####################################################################"
fi


