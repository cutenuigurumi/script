#!/bin/sh
PREFIX="ebaraEC2-"
CURRENTTIME=`date '+%Y%m%d%H%M'`
EXPIRATIONDATE=`date "-d${TIME_LIMIT} days ago" '+%Y%m%d%H%M'`
HEAD_LOGFILE="/tmp/head_create_ami.log"
BODY_LOGFILE="/tmp/body_create_ami.log"
END_LOGFILE="/tmp/end_create_ami.log"
PREFIX="/backup/ebachannel_"

cd /usr/local/aws/bin/ > ${BODY_LOGFILE} 2>&1
#設定ファイル読み出し
. ./setting.sh

#ログのヘッダ部分作成
echo "create ami backup and delete old ami" >> ${HEAD_LOGFILE} 2>&1
echo "** `date '+%Y-%m-%d %H:%M:%S'` - START"  >> ${HEAD_LOGFILE} 2>&1

# API
REGULAR_API_URL="https://api.chatwork.com/v1/rooms/${REGULAR_ROOM}/messages"
ERROR_API_URL="https://api.chatwork.com/v1/rooms/${ERROR_ROOM}/messages"

#戻り値のチェック
is_check_return_value(){
   if [ $? = 1 ]; then
        echo "エラーが発生しました。終了します" >> ${BODY_LOGFILE} 2>&1
        LOG_DETAIL=`cat ${HEAD_LOGFILE} ${BODY_LOGFILE} ${END_LOGFILE}`
        #異常ログをchatworkに連携
        RESULT=`curl -X POST -H "X-ChatWorkToken: $TOKEN" -d "body=${LOG_DETAIL}" $ERROR_API_URL`
        delete_logfile
        exit 1
   fi
return 0
}
delete_logfile(){
    cat /dev/null > ${HEAD_LOGFILE}
    cat /dev/null > ${BODY_LOGFILE}
    cat /dev/null > ${END_LOGFILE}
}

#amiを作成
echo "amiを作成" >> ${BODY_LOGFILE} 2>&1
aws ec2 create-image  --instance-id ${INSTANCE_ID} --name "${PREFIX}${CURRENTTIME}" --no-reboot >> ${BODY_LOGFILE} 2>&1

#amiの一覧を取得
AMI_ID=`aws ec2 describe-images --owners self --filters "Name=name,Values=${PREFIX}${EXPIRATIONDATE}" | jq '.Images[]' | jq -r '.ImageId'`
echo ${AMI_ID}
if [ -z ${AMI_ID} ]; then
    echo "削除するものはありませんでした。" >> ${BODY_LOGFILE} 2>&1
else
    #削除
    aws ec2 deregister-image --image-id ${AMI_ID} >> ${BODY_LOGFILE} 2>&1
    is_check_return_value
    echo "deleted-> ${AMI_ID}" > ${BODY_LOGFILE} 2>&1
fi
LOG_DETAIL=`cat ${HEAD_LOGFILE} ${BODY_LOGFILE}`

#chatworkに結果を連携
RESULT=`curl -X POST -H "X-ChatWorkToken: $TOKEN" -d "body=${LOG_DETAIL}" $REGULAR_API_URL`
delete_logfile
