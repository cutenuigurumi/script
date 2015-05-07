#!/bin/sh
BACKUPDIR="/backup/"
CURRENTTIME=`date '+%Y%m%d%H%M'`
TIME_LIMIT=2
EXPIRATIONDATE=`date "-d${TIME_LIMIT} days ago" '+%Y%m%d%H'`
FILENAME="${PREFIX}${CURRENTTIME}.sql"
LOGFILE="/tmp/rotate.log"
PREFIX="/backup/ebachannel_"

cd /usr/local/aws/bin/
#設定ファイル読み出し
. ./setting.sh

exec >> ${LOGFILE} 2>&1
echo "** `date '+%Y-%m-%d %H:%M:%S'` - START"
echo "** Create  mysqldump backup and rotate backup script**"

# API
API_URL="https://api.chatwork.com/v1/rooms/$ROOM/messages"


#戻り値のチェック
is_check_return_value(){
   if [ $? = 1 ]; then
        echo "書き込めませんでした。終了します"
        exit 1
    fi
    return 0
}
#バックアップフォルダがあるかの確認
if [ ! -e ${BACKUPDIR} ]; then
    echo "${BACKUPDIR}フォルダは存在しません。終了します"
    exit 1
fi
	
echo "${BACKUPDIR}に移動"
cd ${BACKUPDIR}
is_check_return_value
	

#バックアップファイルの作成
mysqldump -u ${DB_USER} -p${PASSWORD} ${DATABASE} > ${FILENAME}
is_check_return_value

#圧縮
tar zcvf  ${PREFIX}${CURRENTTIME}.tar.gz ${FILENAME}
is_check_return_value
#圧縮前のバックアップファイル元の削除
sudo rm -f ${FILENAME}
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
        echo "delete ${BACKUP_FILE}"
        sudo rm -f ${BACKUP_FILE}
    fi
done
echo "** `date '+%Y-%m-%d %H:%M:%S'` - END"

LOG_DETAIL=`cat ${LOGFILE}`

#chatworkに結果を連携
RESULT=`curl -X POST -H "X-ChatWorkToken: $TOKEN" -d "body=${LOG_DETAIL}" $API_URL`
cat /dev/null > ${LOGFILE}

