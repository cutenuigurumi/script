#!/bin/sh
PREFIX="ebaraEC2-"
CURRENTTIME=`date '+%Y%m%d%H%M'`
EXPIRATIONDATE=`date "-d${TIME_LIMIT} days ago" '+%Y%m%d%H%M'`
LOGFILE="/tmp/create_ami.log"

cd /usr/local/aws/bin/
#設定ファイル読み出し
. ./setting.sh

exec >> ${LOGFILE} 2>&1

echo "** `date '+%Y-%m-%d %H:%M:%S'` - START"
# CHAT WORK API
API_URL="https://api.chatwork.com/v1/rooms/$ROOM/messages"


#戻り値のチェック
is_check_return_value(){
   if [ $? = 1 ]; then
        echo "エラーが発生しました。終了します"
        exit 1
   fi
return 0
}

#amiを作成
echo "amiを作成"
aws ec2 create-image  --instance-id ${INSTANCE_ID} --name "${PREFIX}${CURRENTTIME}" --no-reboot
is_check_return_value

#amiの一覧を取得
AMI_ID=`aws ec2 describe-images --owners self --filters "Name=name,Values=${PREFIX}${EXPIRATIONDATE}" | jq '.Images[]' | jq -r '.ImageId'`
echo ${AMI_ID}
if [ -z ${AMI_ID} ]; then
    echo "削除するものはありませんでした。"
else
    #削除
    aws ec2 deregister-image --image-id ${AMI_ID}
    is_check_return_value
    echo "delete ami ${AMI_ID}"
fi

#chatworkに結果を連携
RESULT=`curl -X POST -H "X-ChatWorkToken: $TOKEN" -d "body=${LOG_DETAIL}" $API_URL`
cat /dev/null > ${LOGFILE}
