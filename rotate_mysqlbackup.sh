#!/bin/sh
BACKUPDIR="/backup/"
CURRENTTIME=`date '+%Y%m%d%H%M'`
TIME_LIMIT=2
EXPIRATIONDATE=`date "-d${TIME_LIMIT} days ago" '+%Y%m%d%H'`
USER="root"
PASSWORD="ned5725"
DATABASE="symfony"
FILENAME="${PREFIX}${CURRENTTIME}.sql"
LOG_DIR="/var/log/rotate.log"
PREFIX="ebachannel_"

#戻り値のチェック
is_check_return_value(){
if [ $? = 1 ]; then
    echo "書き込めませんでした。終了します"
    exit 1;
fi
    return 0;
}

#バックアップフォルダがあるかの確認
if [ ! -e ${BACKUPDIR} ]; then
    echo "${BACKUPDIR}フォルダは存在しません。終了します"
    exit 1
fi

cd ${BACKUPDIR}
is_check_return_value;

echo "${FILENAME}"
#バックアップファイルの作成
mysqldump -u ${USER} -p${PASSWORD} ${DATABASE} > ${FILENAME}
is_check_return_value;

#圧縮
tar zcvf  ${PREFIX}${CURRENTTIME}.tar.gz ${FILENAME}
is_check_return_value;
#圧縮前のバックアップファイル元の削除
sudo rm -f ${FILENAME}

#保存期間を過ぎたバックアップファイルの削除
for BACKUP_FILE in `find ${BACKUPDIR} -name "*.tar.gz"`;do
    BACKUP_DATE=`echo ${BACKUP_FILE} | sed "s/\/backup\/ebachannel_//g" |  sed "s/.tar.gz//g" | sed "s/\([0-9]{10}\)//g"`

	echo ${BACKUP_DATE}
    #入力チェック
    if [[ ! ${BACKUP_DATE} =~ [0-9]{10} ]]; then
        continue;
    fi
    echo "if [ ${BACKUP_DATE} -le ${EXPIRATIONDATE} ]; then"
    if [ ${BACKUP_DATE} -le ${EXPIRATIONDATE} ]; then
		delete ${BACKUP_DATE}
        sudo rm -f ${BACKUP_FILE}
    fi
done
