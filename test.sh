#!/bin/bash
fn="/backup/"
testfile="test.txt"


sudo rm -rf ${fn}
echo "フォルダが無い場合"
./rotate_mysqlbackup.sh

sudo mkdir ${fn}
echo "所有権・権限が無い場合"
./rotate_mysqlbackup.sh

sudo chmod -R 644 ${fn}
sudo chown -R ebara:netmarketing ${fn}
echo "所有権はあっても権限が無い場合"
./rotate_mysqlbackup.sh

sudo chmod -R 775 ${fn}
sudo chown -R root:root ${fn}
echo "権限はあっても所有権が無い場合"
./rotate_mysqlbackup.sh

sudo chmod -R 775 ${fn}
sudo chown -R ebara:netmarketing ${fn}
echo "所有権も権限もある場合"
./rotate_mysqlbackup.sh
