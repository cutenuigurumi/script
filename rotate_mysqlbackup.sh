#!/bin/sh
BACKUPDIR="/backup/"
CURRENTTIME=`date '+%Y%m%d%H%M'`
TIME_LIMIT=2
EXPIRATIONDATE=`date "-d${TIME_LIMIT} days ago" '+%Y%m%d%H'`
WORKSPACE="/www/ebatan"
USER="root"
PASSWORD="ned5725"
DATABASE="symfony"

#バックアップファイルの作成
mysqldump -u ${USER} -p${PASSWORD} ${DATABASE} > ${BACKUPDIR}${CURRENTTIME}.sql
#echo "debug".${EXPIRATIONDATE}
#保存期間を過ぎたバックアップファイルの削除
for BACKUP_FILE in `find ${BACKUPDIR} -name "*.sql"`;do
	BACKUP_DATE=`echo ${BACKUP_FILE} | cut -c 9-18`
	#入力チェック
	if [[ ! ${BACKUP_DATE} =~ [0-9]{10} ]]; then
#echo "debug:"/${BACKUP_DATE}
#echo "debug:unmatched"
		continue;
	fi
	if [ ${BACKUP_DATE} -le ${EXPIRATIONDATE} ]; then
		sudo rm -rf ${BACKUP_FILE}
#echo "debug:削除しました".${BACKUP_FILE}
	fi
done

