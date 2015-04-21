#!/bin/sh
BACKUPDIR="/backup/"
CURRENTTIME=`date '+%Y%m%d%H%M'`
TIME_LIMIT=2
EXPIRATIONDATE=`date "-d${TIME_LIMIT} days ago" '+%Y/%m/%d %H:%M:%S'`
USER="root"
PASSWORD="ned5725"
DATABASE="symfony"
FILENAME="${CURRENTTIME}"".sql"

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

#書き込み,日付チェックのため一時ファイルを作成
cd ${BACKUPDIR}
is_check_return_value;

#バックアップファイルの作成
mysqldump -u ${USER} -p${PASSWORD} ${DATABASE} > ${FILENAME}
is_check_return_value;

#圧縮
tar zcvf  ${CURRENTTIME}.tar.gz ${FILENAME}
is_check_return_value;

#圧縮前のバックアップファイル元の削除
sudo rm -f ${FILENAME}

#保存期間を過ぎたバックアップファイルの削除
for BACKUP_FILE in `find ${BACKUPDIR} -mtime +${TIME_LIMIT} -name "*.tar.gz"`;do
    #一時ファイルとファイルのリストを比較
#    sudo rm -f ${BACKUP_FILE}
    echo "delete"${BACKUP_FILE}
done

