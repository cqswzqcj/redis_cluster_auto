#!/bin/bash
WORKHOME=$(pwd)
SRCHOME=${WORKHOME}/redis-3.0.4/src
WORKBIN=${WORKHOME}/redis-3.0.4/bin
CLUSTERHOME=${WORKHOME}/cluster
function checkPort()
{
grep -P "[0-9]{4,6}"
}
echo -n "please input master or slave port: "
read PORT1
PORT1_RETURN=`netstat -an | grep -P "\b${PORT1}\b"`
while [ -n "$PORT1_RETURN" ]
do
    echo -n "port be used,please input master or slave port: "
    read PORT1
    PORT1_RETURN=`netstat -an | grep -P "\b${PORT1}\b"`
done

echo "please input master or slave port: "
read PORT2
PORT2_RETURN=`netstat -an | grep -P "\b${PORT2}\b"`
while [ -n "$PORT2_RETURN" ]
do
    echo -n "port be used,please input master or slave port: "
    read PORT2
    PORT2_RETURN=`netstat -an | grep -P "\b${PORT2}\b"`
done

tar -xzvf redis-3.0.4.tar.gz 1>/dev/null
tar -xzvf redis-rb-3.2.1.tar.gz 1>/dev/null
if [ $? -ne 0 ]
then
fi

cd ${WORKHOME}/redis-3.0.4/
$(make clean) 1>/dev/null
COM_RETURN=$(make) 1>/dev/null
if [ -n ${COM_RETURN}]
then
    echo "compile error"
    exit 0
fi

cd ${WORKHOME}
mkdir -p ${WORKBIN}

cp -rf ${SRCHOME}/mkreleasehdr.sh ${WORKBIN}
cp -rf ${SRCHOME}/redis-benchmark ${WORKBIN}
cp -rf ${SRCHOME}/redis-check-aof ${WORKBIN}
cp -rf ${SRCHOME}/redis-check-dump ${WORKBIN}
cp -rf ${SRCHOME}/redis-cli ${WORKBIN}
cp -rf ${SRCHOME}/redis-sentinel ${WORKBIN}
cp -rf ${SRCHOME}/redis-server ${WORKBIN}
cp -rf ${SRCHOME}/redis-trib.rb ${WORKBIN}
cp -rf ${WORKHOME}/redis-rb-3.2.1/lib/* ${WORKHOME}/redis-3.0.4/bin/

mkdir -p ${CLUSTERHOME}
mkdir -p ${CLUSTERHOME}/${PORT1}
mkdir -p ${CLUSTERHOME}/${PORT2}

cp -f ${WORKHOME}/redis-3.0.4/redis.conf ${CLUSTERHOME}/${PORT1}/redis.conf
cp -f ${WORKHOME}/redis-3.0.4/redis.conf ${CLUSTERHOME}/${PORT2}/redis.conf

sed -i "s/port 6379/port ${PORT1}/g"  ${CLUSTERHOME}/${PORT1}/redis.conf
sed -i "s/daemonize no/daemonize yes/g"  ${CLUSTERHOME}/${PORT1}/redis.conf
sed -i "s/# cluster-config-file nodes-6379.conf/cluster-config-file nodes.conf/g" \
        ${CLUSTERHOME}/${PORT1}/redis.conf
sed -i "s/# cluster-node-timeout 15000/cluster-node-timeout 5000/g"  \
        ${CLUSTERHOME}/${PORT1}/redis.conf
sed -i "s/appendonly no/appendonly yes/g"  ${CLUSTERHOME}/${PORT1}/redis.conf


sed -i "s/port 6379/port ${PORT2}/g"  ${CLUSTERHOME}/${PORT2}/redis.conf
sed -i "s/daemonize no/daemonize yes/g"  ${CLUSTERHOME}/${PORT2}/redis.conf
sed -i "s/# cluster-config-file nodes-6379.conf/cluster-config-file nodes.conf/g" \
        ${CLUSTERHOME}/${PORT2}/redis.conf
sed -i "s/# cluster-node-timeout 15000/cluster-node-timeout 5000/g"  \
        ${CLUSTERHOME}/${PORT2}/redis.conf
sed -i "s/appendonly no/appendonly yes/g"  ${CLUSTERHOME}/${PORT2}/redis.conf
cd ${CLUSTERHOME}/${PORT1}
${WORKBIN}/redis-server redis.conf
cd ${CLUSTERHOME}/${PORT2}
${WORKBIN}/redis-server redis.conf
cd ${WORKHOME}
