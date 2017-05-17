FROM docker-hdp/centos-base:1.0
MAINTAINER Arturo Bayo <arturo.bayo@gmail.com>
USER root

ENV HADOOP_CONF_DIR /etc/hadoop/conf

# Configure environment variables for hdfs
ENV DFS_DATA_DIR /grid/hadoop/hdfs/dn
ENV HDFS_USER hdfs
ENV HDFS_LOG_DIR /var/log/hadoop/$HDFS_USER
ENV HDFS_PID_DIR /var/run/hadoop/$HDFS_USER

# Configure environment variables for yarn
ENV YARN_LOCAL_DIR /grid/hadoop/yarn/local
ENV YARN_USER yarn
ENV YARN_LOG_DIR /var/log/hadoop/$YARN_USER
ENV YARN_PID_DIR /var/run/hadoop/$YARN_USER

# Install software
RUN yum clean all
RUN yum -y install hadoop hadoop-hdfs hadoop-libhdfs hadoop-yarn hadoop-mapreduce hadoop-client openssl

# Install compression libraries
RUN yum -y install snappy snappy-devel lzo lzo-devel hadooplzo hadooplzo-native

# Configure hadoop directories

# Datanode
RUN mkdir -p $DFS_DATA_DIR && chown -R $HDFS_USER:$HADOOP_GROUP $DFS_DATA_DIR && chmod -R 755 $DFS_DATA_DIR

# HDFS Logs
RUN mkdir -p $HDFS_LOG_DIR && chown -R $HDFS_USER:$HADOOP_GROUP $HDFS_LOG_DIR && chmod -R 755 $HDFS_LOG_DIR

# HDFS Process
RUN mkdir -p $HDFS_PID_DIR && chown -R $HDFS_USER:$HADOOP_GROUP $HDFS_PID_DIR && chmod -R 755 $HDFS_PID_DIR

# YARN Logs
RUN mkdir -p $YARN_LOG_DIR && chown -R $YARN_USER:$HADOOP_GROUP $YARN_LOG_DIR && chmod -R 755 $YARN_LOG_DIR

# YARN Process
RUN mkdir -p $YARN_PID_DIR && chown -R $YARN_USER:$HADOOP_GROUP $YARN_PID_DIR && chmod -R 755 $YARN_PID_DIR

# Symlinks directories to hdp-current and modifies paths for configuration directories running hdp-select
RUN hdp-select set all $HDP_VERSION

# Copy configuration files
RUN mkdir -p $HADOOP_CONF_DIR
COPY tmp/conf/ $HADOOP_CONF_DIR/
RUN chown -R $HDFS_USER:$HADOOP_GROUP $HADOOP_CONF_DIR/../ && chmod -R 755 $HADOOP_CONF_DIR/../

RUN echo "export JAVA_HOME=$JAVA_HOME" >> /etc/profile
RUN echo "export HADOOP_CONF_DIR=$HADOOP_CONF_DIR" >> /etc/profile
RUN echo "export PATH=$PATH:$JAVA_HOME:$HADOOP_CONF_DIR" >> /etc/profile

# Expose volumes
VOLUME $HDFS_LOG_DIR
VOLUME $YARN_LOG_DIR

# Expose ports
EXPOSE 50010
EXPOSE 50020
EXPOSE 50075

# Deploy entrypoint
COPY files/entrypoint.sh /opt/run/00_hadoop-datanode.sh
RUN chmod +x /opt/run/*.sh

# Execute entrypoint
ENTRYPOINT ["/opt/bin/run_all.sh"]

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --retries=5 \
  CMD curl -f http://localhost:50075/ || exit 1