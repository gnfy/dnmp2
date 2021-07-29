#!/bin/bash

# 数据库备份文件保存的目录
basedir='/www/backup/data'

# 最多保留的日志数量
maxLog=5

# docker镜像地址
host='php-mysql-5-7'

# 用户名
user='root'

# 密码
password='root'

doBackup () {
    db=$1
    # docker备份数据
    docker exec $host mysqldump --add-drop-table --add-drop-database -u"$user" -p"$password" "$db" | gzip > "$basedir"/"$db"_$(date +%Y%m%d_%H%M%S).sql.gz
    # 删除过期的文件
    doDelBackupFile $db 
}

doDelBackupFile () {
    num=`ls $basedir | grep $1 | wc -l`;
    if [ $num -gt $maxLog ];then
        index=0
        dir=`ls -rt $basedir | grep $1`;
        delnum=$(($num-$maxLog))
        for file in $dir 
        do  
            index=$((index+1))
            if [ $index -gt $delnum ];then
                break
            fi  
            rm $basedir/$file -rf 
        done 
    fi
}

#subscription数据备份
doBackup 'subscription'

# 广告的备份
doBackup 'advertise'


#upsell的备份
doBackup 'upsell'
