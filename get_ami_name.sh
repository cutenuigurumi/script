#!/bin/sh

#設定ファイル読み出し
. ./setting.sh

#amiを一覧表示
aws ec2 describe-images --owners self



:
