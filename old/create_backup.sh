#!/bin/sh
BACKUPDIR="/backup"
CURRENTTIME=`date '+%Y%m%d%H%M'`
WORKSPACE="/www/ebatan"

mkdir ${BACKUPDIR}/tmp
sudo rsync -az ${WORKSPACE} ${BACKUPDIR}/tmp
sudo tar zcvf  ${BACKUPDIR}/${CURRENTTIME}.tar.gz ${BACKUPDIR}/tmp
sudo rm -rf ${BACKUPDIR}/tmp

