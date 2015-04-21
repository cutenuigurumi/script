#!/bin/sh
BACKUPDIR="/backup/"
CURRENTTIME=`date '+%Y%m%d%H%M'`
TIME_LIMIT=2
EXPIRATIONDATE=`date "-d${TIME_LIMIT} days ago" '+%Y%m%d%H'`
USER="root"
PASSWORD="ned5725"
DATABASE="symfony"
FILENAME="BACKUPDIR""${CURRENTTIME}"".sql"
LOG_DIR="/var/log/rotate.log"

#バックアップフォルダがあるかの確認
if [ ! -e ${BACKUPDIR} ]; then
    echo "${BACKUPDIR}フォルダは存在しません。終了します"
    exit 1
fi

#書き込みチェック
if [ -w ${BACKUPDIR} ]; then
    echo "書き込めませんでした。終了します。"
    exit 1
fi

#バックアップファイルの作成
mysqldump -u ${USER} -p${PASSWORD} ${DATABASE} > ${FILENAME}
#戻り値のチェック
if [$? = 1]; then
	echo "書き込めませんでした。終了します。" 
	exit 1
fi

cd ${BACKUPDIR}
#圧縮
tar zcvf  ${CURRENTTIME}.tar.gz ${FILENAME}
#圧縮前のバックアップファイル元の削除
sudo rm -f ${FILENAME}

#保存期間を過ぎたバックアップファイルの削除
for BACKUP_FILE in `find ${BACKUPDIR} -name "*.tar.gz"`;do
    BACKUP_DATE=`cut -c 9-18 ${BACKUP_FILE}`
    #入力チェック
    if [[ ! ${BACKUP_DATE} =~ [0-9]{10} ]]; then
        continue;
    fi
    if [ ${BACKUP_DATE} -le ${EXPIRATIONDATE} ]; then
        sudo rm -f ${BACKUP_FILE}
    fi
done
