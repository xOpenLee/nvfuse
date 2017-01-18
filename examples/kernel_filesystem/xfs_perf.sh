#!/bin/sh
FIO_PERF_PATH=fio
SPDK_RESET_PATH=/root/spdk/scripts/setup.sh
OUTPUT_PATH=output

if [ ! -d $OUTPUT_PATH ] ; then
    mkdir $OUTPUT_PATH
fi

$SPDK_RESET_PATH reset
DEV_NAME=/dev/nvme0n1
MOUNT_PATH=/media/xfs
RUNTIME=300

mkfs.xfs $DEV_NAME -f -K

if [ ! -d $MOUNT_PATH ] ; then
    mkdir $MOUNT_PATH
fi
mount $DEV_NAME $MOUNT_PATH

#for workload in read randread
for workload in randread randwrite
do
    for qdepth in 1 2 4 8 16 32 64 128 256
    do
		for block_size in 4 8 16 32 64 128
		do
		    block_size=$((block_size*1024))
	
		    echo $FIO_PERF_PATH --name=test --filename=${MOUNT_PATH}/test.dat --direct=1 --size=128G --ioengine=libaio --iodepth=$qdepth --bs=$block_size --rw=$workload --runtime=${RUNTIME}
		    $FIO_PERF_PATH --name=test --filename=${MOUNT_PATH}/test.dat --direct=1 --size=128G --ioengine=libaio --iodepth=$qdepth --bs=$block_size --rw=$workload --runtime=${RUNTIME} --minimal --output=${OUTPUT_PATH}/kernel_xfs_q_${qdepth}_block_${block_size}_workload_${workload}.log
		done
    done
done

umount $MOUNT_PATH
