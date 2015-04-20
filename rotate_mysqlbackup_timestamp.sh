#!/bin/sh
BACKUPDIR="/backup/"
CURRENTTIME=`date '+%Y%m%d%H%M'`
TIME_LIMIT=2
EXPIRATIONDATE=`date "-d${TIME_LIMIT} days ago" '+%Y/%m/%d %H:%M:%S'`
USER="root"
PASSWORD="ned5725"
DATABASE="symfony"
FILENAME="${CURRENTTIME}"".sql"

#バックアップフォルダがあるかの確認
if [ ! -e ${BACKUPDIR} ]; then
    echo "${BACKUPDIR}フォルダは存在しません。終了します"
    exit 1
fi

#書き込み,日付チェックのため一時ファイルを作成
sudo touch -d "$EXPIRATIONDATE" ${BACKUPDIR}tmp.txt
if [ $? -eq "1" ]; then
    echo "書き込めませんでした。終了します。"
    exit 1
fi
cd ${BACKUPDIR}

#バックアップファイルの作成
mysqldump -u ${USER} -p${PASSWORD} ${DATABASE} > ${FILENAME}
#圧縮
tar zcvf  ${CURRENTTIME}.tar.gz ${FILENAME}
#圧縮前のバックアップファイル元の削除
sudo rm -f ${FILENAME}

#保存期間を過ぎたバックアップファイルの削除
for BACKUP_FILE in `find ${BACKUPDIR} -name "*.tar.gz"`;do
	#一時ファイルとファイルのリストを比較
    if [[  ${BACKUP_FILE} -ot ${BACKUPDIR}tmp.txt ]]; then
		sudo rm -f ${BACKUP_FILE}
		echo "delete"${BACKUP_FILE}
    fi
done

#一時ファイルを削除
rm -f ${BACKUPDIR}/tmp.txt
