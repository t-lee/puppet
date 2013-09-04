#!/bin/bash

max_backups=30
backup_dir=/mnt/gvh_config/backup
if [ ! -d $backup_dir ];then
    echo missing directory $backup_dir >&2
    exit 1
fi

d=$(date +%Y-%m-%d_%H%M%S)

mysqldump gvh_wordpress | gzip -c > $backup_dir/gvh_wordpress.dump.sql.$d.$(hostname).gz

cd /var/www
tar cfz $backup_dir/gvh_wordpress.$d.$(hostname).tar.gz wordpress

# removing old backups
for i in $(/bin/ls -1 $backup_dir/gvh_wordpress.dump.sql.*.$(hostname).gz | head -n -${max_backups});do
    rm -f $i
done

for i in $(/bin/ls -1 $backup_dir/gvh_wordpress.*.$(hostname).tar.gz | head -n -${max_backups});do
    rm -f $i
done

