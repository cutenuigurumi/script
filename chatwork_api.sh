#!/bin/sh

# token by bot
TOKEN="ca89fefe62f2d5cd17da1e346a9961b3"
# Room ID ブラウザの#!rid... ...の部分
ROOM="32158598"
# API
API_URL="https://api.chatwork.com/v1/rooms/$ROOM/messages"


BODY="[To:470134] 久松　剛さん
昨日ですが、安永さんよりlets noteのバッテリーが全然もたないというお話がありました
フル充電の状態から１時間程度でバッテリーの容量がなくなってしまうとのことです。
節電モードにはしている、とのことなのですが、今日様子をみてバッテリーを前使っていた太いものに変えたいとのことです。"

RESULT=`curl -X POST -H "X-ChatWorkToken: $TOKEN" -d "body=$BODY" $API_URL`
