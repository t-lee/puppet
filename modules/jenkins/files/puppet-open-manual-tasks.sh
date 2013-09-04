#!/bin/bash

id_rsa=/home/jenkins/.ssh/id_rsa

if [ ! -f $id_rsa ];then
    echo "
    The jenkins slave on $(hostname) is not yet ready.
    Please perform the following tasks:
    
    - $id_rsa is missing. Please copy from jenkins.devbliss.com
    
    The Puppet Deployment
    " | /usr/bin/mail -s "Jenkins Slave $(hostname) needs more actions" root
fi

touch /etc/puppet/locks/puppet-open-manual-tasks.lock
