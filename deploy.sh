#!/bin/sh
#PRODUCTDIR="/www/symfony"
PRODUCTDIR="/www/test"
SOURCEDIR="/src"
#GITDIR="/workspace/symfony""${SOURCEDIR}"
GITDIR="/workspace/test"
LOGFILE="/tmp/deploy.log"

#以下chatwork api連携
# nm-botのtoken
TOKEN="ca89fefe62f2d5cd17da1e346a9961b3"
# Room ID ブラウザの#!rid... ...の部分
# ブランチ切り替えグループ
ROOM="28508316"
# API
API_URL="https://api.chatwork.com/v1/rooms/$ROOM/messages"

exec >> ${LOGFILE} 2>&1
echo "** `date '+%Y-%m-%d %H:%M:%S'` - START"
echo "** deploy script report**"

is_check_dir_exist(){
    #書き込み先、書き込みもとのフォルダがあるかを確認
    if [ ! -e $1 ]; then
        echo "this folder is not exists"
        sudo mkdir -p ${1}
        sudo chown ebara:netmarketing  ${1}
        sudo chmod 775  ${1}
        echo 1
    fi
}
#戻り値チェック
is_check_return_value(){
    if [[ $1 = 1 ]]; then
        echo "失敗しました。終了します"
        exit 1;
    fi
    return 0;
}
#ディレクトリチェック
is_check_dir_exist ${GITDIR}
is_check_dir_exist ${PRODUCTDIR}${SOURCEDIR}

#コピーもとのフォルダに移動できるか
cd ${GITDIR}
is_check_return_value $?

#最新をgithubから落としてくる
git fetch
git merge

#エラー時の処理
is_check_return_value $?

#ワークスペースから本番へコピーする
sudo rsync --exclude=".git" -ar ${GITDIR}/ ${PRODUCTDIR} 
#sudo cp -R ${GITDIR} ${PRODUCTDIR}
is_check_return_value $?

LOG_DETAIL=`cat ${LOGFILE}`
echo "** `date '+%Y-%m-%d %H:%M:%S'` - END"


#chatworkに結果を連携
RESULT=`curl -X POST -H "X-ChatWorkToken: $TOKEN" -d "body=${LOG_DETAIL}" $API_URL`
cat /dev/null > ${LOGFILE}

