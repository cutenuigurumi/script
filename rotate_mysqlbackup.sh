#!/bin/sh
BACKUPDIR="/backup/"
CURRENTTIME=`date '+%Y%m%d%H%M'`
TIME_LIMIT=2
EXPIRATIONDATE=`date "-d${TIME_LIMIT} days ago" '+%Y%m%d%H'`
USER="root"
PASSWORD="ned5725"
DATABASE="symfony"
FILENAME="${BACKUPDIR}${CURRENTTIME}"

#書き込みチェック
touch ${BACKUPDIR}test.sql
if [ $? -eq "1" ]; then
	echo "書き込めませんでした。終了します。error1"
	exit 1
else
	sudo rm -f ${BACKUPDIR}test.sql
fi
#バックアップフォルダがあるかの確認
if [ ! -e ${BACKUPDIR} ]; then
	echo "${BACKUPDIR}フォルダは存在しません。終了しますerror2"
	exit 1
fi
#バックアップフォルダに書き込み権限があるかの確認
if [ -w ${BACKUPDIR} ]; then
	echo "write OK"
else
	echo "${BACKUPDIR}への書き込み権限がありません。終了しますerror3"
	exit 1
fi

#バックアップファイルの作成
mysqldump -u ${USER} -p${PASSWORD} ${DATABASE} > ${FILENAME}.sql
#圧縮
tar zcvf  ${FILENAME}.tar.gz ${FILENAME}.sql


#バックアップファイル元の削除
sudo rm -f ${FILENAME}.sql

#保存期間を過ぎたバックアップファイルの削除
for BACKUP_FILE in `find ${BACKUPDIR} -name "*.sql"`;do
    BACKUP_DATE=`echo ${BACKUP_FILE} | cut -c 9-18`
    #入力チェック
    if [[ ! ${BACKUP_DATE} =~ [0-9]{10} ]]; then
        continue;
    fi
    if [ ${BACKUP_DATE} -le ${EXPIRATIONDATE} ]; then
        sudo rm -f ${BACKUP_FILE}
    fi
done

