#!/bin/bash
HOST_INFO=host.info
rm -f mail.txt
for IP in $(awk '/^[^#]/{print $1}' $HOST_INFO); do
    USER=$(awk -v ip=$IP 'ip==$1{print $2}' $HOST_INFO)
    PORT=$(awk -v ip=$IP 'ip==$1{print $3}' $HOST_INFO)
    TMP_FILE=/tmp/disk.tmp
    ssh -p $PORT $USER@$IP 'df -h' > $TMP_FILE
    USE_RATE_LIST=$(awk 'BEGIN{OFS="="}/^\/dev/{print $NF,int($5)}' $TMP_FILE)
    for USE_RATE in $USE_RATE_LIST; do
        PART_NAME=${USE_RATE%=*}  
        USE_RATE=${USE_RATE#*=}
        if [ $USE_RATE -lt 80 ]; then
            echo "Warning: $PART_NAME Partition usage $USE_RATE%!" >> mail.txt
        else
	    echo "ip:$IP  disk:$PART_NAME is ok"
        fi
    done
    cat mail.txt | mail -s "so hight" sunhuijiang@cdeledu.com
done
