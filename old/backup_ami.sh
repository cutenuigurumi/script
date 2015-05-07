#!/bin/sh
INSTANCE_ID="i-ca2a79d3"
PREFIX="ebaraEC2-"
CURRENTTIME=`date '+%Y%m%d%H%M'`
LOGFILE="/tmp/create_ami.log"
ACCOUNT_ID="206815170296"

cd /usr/local/aws/bin/
#設定ファイル読み出し
. ./setting.sh

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
sudo rm -rf /mnt/*

sudo su -
#イメージの作成
ec2-bundle-vol -d /mnt --privatekey /tmp/pk-2UBLCC5KBK66AYSKXV2NN7IEED33NI3G-1.pem --cert /tmp/cert-2UBLCC5KBK66AYSKXV2NN7IEED33NI3G-1.pem --user ${ACCOUNT_ID} -r x86_64

#S3にアップロード
ec2-upload-bundle -b ${BUCKET}/${PREFIX}/${CURRENTTIME} -m /mnt/${PREFIX}.manifest.xml -a ${ACCESS_KEY_ID} -s ${SECRET} --location ${LOCATION}

is_check_return_value


echo "** `date '+%Y-%m-%d %H:%M:%S'` - END"
LOG_DETAIL=`cat ${LOGFILE}`

#chatworkに結果を連携
RESULT=`curl -X POST -H "X-ChatWorkToken: $TOKEN" -d "body=${LOG_DETAIL}" $API_URL`
cat /dev/null > ${LOGFILE}
