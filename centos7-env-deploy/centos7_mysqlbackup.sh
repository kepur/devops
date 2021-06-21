#!/bin/bash
db="
self_app_pay_zf2860
self_pay_zf2860
self_qrpay_zf2860"
for aff in $db;
do
cd /home/mysql/backup
/usr/bin/mysqldump -udianjin898 -h127.0.0.1 -psolarisdianjinof13dsf\#s7 $aff --ignore-table=sincai_passport.adminlog --ignore-table=sincai_passport.userlog  --ignore-table=sincai_hgame.issuehistory  --ignore-table=sincai_hgame.userlog  > /home/mysql/backup/$aff$(date +%m_%d_%H).sql
        if  [[ $? == 0 ]]
                then
tar zcvf $aff$(date +%m_%d_%H).tar.gz $aff$(date +%m_%d_*).sql
#rm -rf /home/mysql/backup/*.sql
#find /home/mysql/backup -ctime +5|xargs -i  rm -rf {}
fi
done

