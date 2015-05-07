#!/bin/bash
fn="/backup/test.txt"
testfile="test.txt"

func() {
if [ -w $fn ] ; then
    echo "書き込みOK"
else
    echo "書き込みNG"
fi
touch ${fn}
echo ""
}


sudo rm -rf ${fn}
echo "フォルダが無い場合"
func

sudo mkdir ${fn}
echo "所有権・権限が無い場合"
func

sudo chmod -R 644 ${fn}
sudo chown -R ebara:netmarketing ${fn}
echo "所有権はあっても権限が無い場合"
func

sudo chmod -R 775 ${fn}
sudo chown -R root:root ${fn}
echo "権限はあっても所有権が無い場合"
func

sudo chmod -R 775 ${fn}
sudo chown -R ebara:netmarketing ${fn}
echo "所有権も権限もある場合"
func

