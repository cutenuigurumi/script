#!/bin/sh
#PRODUCTDIR="/www/symfony${SOURCEDIR}"
#SOURCEDIR="/src"
#GITDIR="/workspace/symfony${SOURCEDIR}"
LOGFILE="/tmp/deploy.log"
#debug用ディレクトリ
PRODUCTDIR="/www/test"
GITDIR="/workspace/test"
HEAD_LOGFILE="/tmp/head_deploy.log"
BODY_LOGFILE="/tmp/body_deploy.log"

# API
REGULAR_API_URL="https://api.chatwork.com/v1/rooms/${REGULAR_ROOM}/messages"
ERROR_API_URL="https://api.chatwork.com/v1/rooms/${ERROR_ROOM}/messages"

#設定ファイル読み出し
. /usr/local/aws/bin/setting.sh

#ヘッダー部作成
echo "** `date '+%Y-%m-%d %H:%M:%S'` - START\n
echo ** deploy script report**" >>  ${HEAD_LOGFILE} 2>&1

delete_logfile(){
    cat /dev/null > ${HEAD_LOGFILE}
    cat /dev/null > ${BODY_LOGFILE}
    cat /dev/null > ${END_LOGFILE}
}
is_check_dir_exist(){
    #書き込み先、書き込みもとのフォルダがあるかを確認
    if [ ! -e $1 ]; then
        echo "directory is not exists" >>  ${BODY_LOGFILE} 2>&1
        sudo mkdir -p ${1}
        echo "Create ${1}" >>  ${BODY_LOGFILE} 2>&1
        sudo chown ebara:netmarketing  ${1}
        sudo chmod 775  ${1}
        echo 1
    fi
}
#戻り値チェック
is_check_return_value(){
    if [[ $1 = 1 ]]; then
        echo "faild " >>  ${BODY_LOGFILE} 2>&1
        exit 1;
    fi
    return 0;
}
#ディレクトリチェック
is_check_dir_exist ${GITDIR}
is_check_dir_exist ${PRODUCTDIR}

#コピーもとのフォルダに移動できるか
cd ${GITDIR} >>  ${BODY_LOGFILE} 2>&1
is_check_return_value $?

#最新をgithubから落としてくる
sudo git fetch >>  ${BODY_LOGFILE} >&2
#エラー時の処理
is_check_return_value $?
git merge origin/master >>  ${BODY_LOGFILE} >&2
#エラー時の処理
is_check_return_value $?

#ワークスペースから本番へコピーする
echo "デプロイ開始します" >>  ${BODY_LOGFILE} 2>&1
sudo rsync --exclude=".git" -ar ${GITDIR}/ ${PRODUCTDIR}${SOURCEDIR} >>  ${BODY_LOGFILE} >&2
echo "${GITDIR}フォルダから${PRODUCTDIR}${SOURCEDIR}へコピーしています"
is_check_return_value $?

LOG_DETAIL=`cat ${HEAD_LOGFILE} ${BODY_LOGFILE} ${END_LOGFILE}`

#正常ログをchatworkに連携
RESULT=`curl -X POST -H "X-ChatWorkToken: $TOKEN" -d "body=${LOG_DETAIL}" ${REGULAR_API_URL}` > ${END_LOGFILE} 2>&1
delete_logfile

