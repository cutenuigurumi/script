#!/bin/sh
CURRENTTIME=`date '+%Y%m%d%H%M'`
DELETE_LIMIT=`date --date '2 day ago' +%Y%m%d%H%M`
BACKUPDIR="/backup/"
for file in `find ${BACKUPDIR} -name "*.tar.gz"`;do
	echo "$file"
done

# sudo rm -rf ${BACKUPDIR}/${DELETE_LIMIT}*

