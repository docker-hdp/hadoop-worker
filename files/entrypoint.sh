#!/bin/bash

sudo sed -i s/INFO/DEBUG/ $HADOOP_CONF_DIR/log4j.properties

# Get hostname/ip config
MY_HOSTNAME=`hostname`

echo "Current Hostname:" $MY_HOSTNAME
echo "Current Namenode Hostname:" $HDFS_NAMENODE_HOSTNAME
echo "Current Secondary Namenode Hostname:" $HDFS_SECONDARYNAMENODE_HOSTNAME

echo "Changing hostnames in core-site.xml"

echo "Configure core-site.xml"
# From run environment
sudo sed -i s~HDFS_NAMENODE_HOSTNAME~$HDFS_NAMENODE_HOSTNAME~g $HADOOP_CONF_DIR/core-site.xml
sudo sed -i s~HDFS_SECONDARYNAMENODE_HOSTNAME~$HDFS_SECONDARYNAMENODE_HOSTNAME~g $HADOOP_CONF_DIR/core-site.xml

# From dockerfile configuration
sudo sed -i s~HDFS_NAMENODE_CHECKPOINT_DIR~$FS_CHECKPOINT_DIR~g $HADOOP_CONF_DIR/core-site.xml
sudo sed -i s~HDFS_NAMENODE_EDITS_DIR~$FS_CHECKPOINT_DIR~g $HADOOP_CONF_DIR/core-site.xml

echo "Configure hdfs-site.xml"
# From run environment
sudo sed -i s~HDFS_NAMENODE_HOSTNAME~$HDFS_NAMENODE_HOSTNAME~g $HADOOP_CONF_DIR/hdfs-site.xml
sudo sed -i s~HDFS_SECONDARYNAMENODE_HOSTNAME~$HDFS_SECONDARYNAMENODE_HOSTNAME~g $HADOOP_CONF_DIR/hdfs-site.xml

# From dockerfile configuration
sudo sed -i s~HDFS_NAMENODE_NAME_DIR~$DFS_NAME_DIR~g $HADOOP_CONF_DIR/hdfs-site.xml
sudo sed -i s~HDFS_NAMENODE_CHECKPOINT_DIR~$FS_CHECKPOINT_DIR~g $HADOOP_CONF_DIR/hdfs-site.xml
sudo sed -i s~HDFS_DATANODE_DATA_DIR~$DFS_DATA_DIR~g $HADOOP_CONF_DIR/hdfs-site.xml

echo "Configure yarn-site.xml"
# From run environment
sudo sed -i s~YARN_RESOURCEMANAGER_HOSTNAME~$YARN_RESOURCEMANAGER_HOSTNAME~g $HADOOP_CONF_DIR/yarn-site.xml

# From dockerfile configuration
sudo sed -i s~YARN_NODEMANAGER_LOCAL_DIR~$YARN_LOCAL_DIR~g $HADOOP_CONF_DIR/yarn-site.xml
sudo sed -i s~YARN_NODEMANAGER_LOG_DIR~$YARN_LOG_DIR~g $HADOOP_CONF_DIR/yarn-site.xml

echo "Configure mapred-site.xml"
# From run environment (inherited)
sudo sed -i s~MAPRED_JOBHISTORY_HOSTNAME~$YARN_RESOURCEMANAGER_HOSTNAME~g $HADOOP_CONF_DIR/mapred-site.xml


echo "Configure container-executor.cfg"
# From dockerfile configuration
sudo sed -i s~YARN_NODEMANAGER_LOCAL_DIR~$YARN_LOCAL_DIR~g $HADOOP_CONF_DIR/container-executor.cfg
sudo sed -i s~YARN_NODEMANAGER_LOG_DIR~$YARN_LOG_DIR~g $HADOOP_CONF_DIR/container-executor.cfg


echo "Checking that namenode is up"


echo "Starting datanode"
su - $HDFS_USER -c "/usr/hdp/current/hadoop-hdfs-datanode/../hadoop/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR start datanode"

echo "Starting nodemanager"
su -l $YARN_USER -c "/usr/hdp/current/hadoop-yarn-nodemanager/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR start nodemanager"
