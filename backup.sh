#!/bin/bash

# backup mariadb databases

# edit the following line to reflect where you want to keep the db backups.
cd /backups

date=$(date +%m%d%y) #used to label backups as "dbname.date.sql"

# Clearly, edit the following with your own mysql root password, instead of *******
dblist=`echo "show databases" | mysql -uroot -p$DB_PASSWORD | tail -n+3`;

for item in ${dblist[*]}
do
  backupfile=$item.$date.sql
  mysqldump -uroot -p$DB_PASSWORD --skip-lock-tables $item > $backupfile
  echo "$item backed up"
done

# following line is optional
# I use it to delete any backups older than 3 days
# keeps my server from filling up with backups.
# if you want to keep a week's worth, change +3 to +7, for instance

find . -maxdepth 1 -name '*.sql' -mtime +3 -exec rm -f {} \;


echo "db backups complete for $date"
exit
