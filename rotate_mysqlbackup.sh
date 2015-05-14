#!/bin/sh
BACKUPDIR="/backup/"
CURRENTTIME=`date '+%Y%m%d%H%M'`
TIME_LIMIT=2
EXPIRATIONDATE=`date "-d${TIME_LIMIT} days ago" '+%Y%m%d%H'`
FILENAME="${PREFIX}${CURRENTTIME}.sql"
HEAD_LOGFILE="/tmp/head.log"
BODY_LOGFILE="/tmp/body.log"
END_LOGFILE="/tmp/end.log"
PREFIX="/backup/ebachannel_"

#設定ファイル読み出し
. /usr/local/aws/bin/setting.sh
# API
REGULAR_API_URL="https://api.chatwork.com/v1/rooms/${REGULAR_ROOM}/messages"
ERROR_API_URL="https://api.chatwork.com/v1/rooms/${ERROR_ROOM}/messages"

echo -e "** `date '+%Y-%m-%d %H:%M:%S'` - START
** Create  mysqldump backup and rotate backup script**" >>  ${HEAD_LOGFILE} 2>&1

#戻り値のチェック
is_check_return_value(){
   if [ $? = 1 ]; then
        echo -e "Error! 終了します。\n** `date '+%Y-%m-%d %H:%M:%S'` - END" >> ${END_LOGFILE} 2>&1
        LOG_DETAIL=`cat ${HEAD_LOGFILE} ${BODY_LOGFILE} ${END_LOGFILE}`
        echo ${LOG_DETAIL}
        #異常ログをchatworkに連携
        RESULT=`curl -X POST -H "X-ChatWorkToken: $TOKEN" -d "body=${LOG_DETAIL}" $ERROR_API_URL`
        delete_logfile
        exit 1
    fi
    return 0
}
delete_logfile(){
    cat /dev/null > ${HEAD_LOGFILE}
    cat /dev/null > ${BODY_LOGFILE}
    cat /dev/null > ${END_LOGFILE}
}
#バックアップフォルダがあるかの確認
if [ ! -e ${BACKUPDIR} ]; then
    echo "${BACKUPDIR}フォルダは存在しません。終了します\n
    ** `date '+%Y-%m-%d %H:%M:%S'` - END" >> ${END_LOGFILE} 2>&1
    LOG_DETAIL=`cat ${HEAD_LOGFILE}  ${BODY_LOGFILE} ${END_LOGFILE}`
    #異常ログをchatworkに連携
    RESULT=`curl -X POST -H "X-ChatWorkToken: $TOKEN" -d "body=${LOG_DETAIL}" $ERROR_API_URL`
    exit 1
fi
	
cd ${BACKUPDIR} >> ${BODY_LOGFILE} 2>&1
is_check_return_value
	
#バックアップファイルの作成
mysqldump --defaults-group-suffix=_host1 ${DATABASE} >> ${FILENAME} >>  ${BODY_LOGFILE} >2
is_check_return_value

#圧縮
tar zcvf  ${PREFIX}${CURRENTTIME}.tar.gz ${FILENAME} >>  ${BODY_LOGFILE} >2
is_check_return_value
echo "create backup file->${PREFIX}${CURRENTTIME}.tar.gz"  >>  ${BODY_LOGFILE} 2>&1


#圧縮前のバックアップファイル元の削除
sudo rm -f ${FILENAME} >> ${BODY_LOGFILE} 2>&1
#保存期間を過ぎたバックアップファイルの削除
for BACKUP_FILE in `find ${BACKUPDIR} -name "*.tar.gz"`;do
    #prefix文字カウント
    COUNT=`echo ${PREFIX} | wc -c`
    BACKUP_DATE=`echo ${BACKUP_FILE:${COUNT}-1:10}`
    #入力チェック
    if [[ ! ${BACKUP_DATE} =~ [0-9]{10} ]]; then
        continue
    fi
    if [ ${BACKUP_DATE} -le ${EXPIRATIONDATE} ]; then
        echo "deleted-> ${BACKUP_FILE}" >> ${BODY_LOGFILE} 2>&1
        sudo rm -f ${BACKUP_FILE} >> ${BODY_LOGFILE} 2>&1
    fi
done

echo "SUCCESS!** `date '+%Y-%m-%d %H:%M:%S'` - END" >> ${END_LOGFILE} 2>&1

LOG_DETAIL=`cat ${HEAD_LOGFILE} ${BODY_LOGFILE} ${END_LOGFILE}`

#正常ログをchatworkに連携
RESULT=`curl -X POST -H "X-ChatWorkToken: $TOKEN" -d "body=${LOG_DETAIL}" ${REGULAR_API_URL}` > ${END_LOGFILE} 2>&1
delete_logfile
