#!/bin/sh
INSTANCE_ID="i-ca2a79d3"
PREFIX="ebaraEC2-"
CURRENTTIME=`date '+%Y%m%d%H%M'`
LOGFILE="/tmp/create_ami.log"

exec >> ${LOGFILE} 2>&1

#以下chatwork api連携
# nm-botのtoken
TOKEN="ca89fefe62f2d5cd17da1e346a9961b3"
# Room ID ブラウザの#!rid... ...の部分
# ブランチ切り替えグループ
ROOM="28508316"
# API
API_URL="https://api.chatwork.com/v1/rooms/$ROOM/messages"


#戻り値のチェック
is_check_return_value(){
   if [ $? = 1 ]; then
        echo "** `date '+%Y-%m-%d %H:%M:%S'` - START"
        echo "** Create ami backup and rotate backup**"
        echo "書き込めませんでした。終了します"
        exit 1
   fi
return 0
}

RETURN=`aws ec2 create-image  --instance-id ${INSTANCE_ID} --name "${PREFIX}${CURRENTTIME}" --no-reboot`
is_check_return_value

echo "** `date '+%Y-%m-%d %H:%M:%S'` - END"

LOG_DETAIL=`cat ${LOGFILE}`

#chatworkに結果を連携
RESULT=`curl -X POST -H "X-ChatWorkToken: $TOKEN" -d "body=${LOG_DETAIL}" $API_URL`
cat /dev/null > ${LOGFILE}
