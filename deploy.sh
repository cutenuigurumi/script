#!/bin/sh
PRODUCTDIR="/www/symfony"
SOURCEDIR="/src"
GITDIR="/workspace/symfony""${SOURCEDIR}"

is_check_dir_exist(){
    #書き込み先、書き込みもとのフォルダがあるかを確認
    if [ ! -e $1 ]; then
        echo "$1フォルダは存在しません。終了します"
        exit 1
    fi
}
#戻り値チェック
is_check_return_value(){
    if [[ $? = 1 ]]; then
        echo "書き込めませんでした。終了します"
        exit 1;
    fi
    return 0;
}
echo ${GITDIR};
#ディレクトリチェック
is_check_dir_exist ${GITDIR}
is_check_dir_exist ${PRODUCTDIR}${SOURCEDIR}

#コピーもとのフォルダに移動できるか
cd ${GITDIR}
is_check_return_value

#pull
git pull origin master
#エラー時の処理
is_check_return_value
#コピー
echo "sudo cp -R ${GITDIR} ${PRODUCTDIR}"
sudo cp -R ${GITDIR} ${PRODUCTDIR}
