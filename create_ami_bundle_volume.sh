#!/bin/sh
INSTANCE_ID="i-ca2a79d3"
PREFIX="ebaraEC2-"
CURRENTTIME=`date '+%Y%m%d%H%M'`
LOGFILE="/tmp/create_ami.log"
ACCOUNT_ID="206815170296"
#ACCESS_KEY_ID="AKIAIYJNPZ57YIUUCDQA"
ACCESS_KEY_ID="AKIAJYRUWJN62GRMLZFQ"
SECRET="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"
#SECRET="0ln6AHkhsmEqztCvMaqcEKmLIMvmz/QgpNFFoNHw"
LOCATION="ap-northeast-1"
BUCKET="scd-education-backup"



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
sudo rm -rf /mnt/*

#RETURN=`ec2-bundle-vol -d /mnt -u ${ACCOUNT_ID} -r x86_64 -p ${PREFIX} -c /tmp/cert-2UBLCC5KBK66AYSKXV2NN7IEED33NI3G-1.pem -k ~/tmp/pk-2UBLCC5KBK66AYSKXV2NN7IEED33NI3G-1.pem`
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
