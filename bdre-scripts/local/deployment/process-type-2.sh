#!/bin/sh
. ../env.properties
. ../common.sh
cd $BDRE_APPS_HOME

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] ; then
        echo Insufficient parameters !
        exit 1
fi

busDomainId=$1
processTypeId=$2
processId=$3


#Generating workflow

java -cp "$BDRE_HOME/lib/*" com.wipro.ats.bdre.wgen.WorkflowGenerator --parent-process-id $processId --file-name workflow-$processId.xml
if [ $? -eq 1 ]
then exit 1
fi

#clean edgenode process directory, if exists
 rm -r -f $BDRE_APPS_HOME/$busDomainId/$processTypeId/$processId
if [ $? -eq 1 ]
then exit 1
fi

mkdir -p $BDRE_APPS_HOME/$busDomainId/$processTypeId/$processId
if [ $? -eq 1 ]
then exit 1
fi

mkdir -p $BDRE_APPS_HOME/$busDomainId/$processTypeId/$processId/lib
if [ $? -eq 1 ]
then exit 1
fi

mkdir -p $BDRE_APPS_HOME/$busDomainId/$processTypeId/$processId/hql
if [ $? -eq 1 ]
then exit 1
fi

mkdir -p $BDRE_APPS_HOME/$busDomainId/$processTypeId/$processId/spark
if [ $? -eq 1 ]
then exit 1
fi

#move generated workflow to edge node process dir
mv  workflow-$processId.xml $BDRE_APPS_HOME/$busDomainId/$processTypeId/$processId
if [ $? -eq 1 ]
then exit 1
fi

mv  workflow-$processId.xml.dot $BDRE_APPS_HOME/$busDomainId/$processTypeId/$processId/
if [ $? -eq 1 ]
then exit 1
fi

#create/clean hdfs process directory
hdfs dfs -mkdir -p $hdfsPath/wf/$busDomainId/$processTypeId/$processId
if [ $? -eq 1 ]
then exit 1
fi

hdfs dfs -rm -r -f $hdfsPath/wf/$busDomainId/$processTypeId/$processId/*
if [ $? -eq 1 ]
then exit 1
fi

#copying hive-plugin jar
cp $BDRE_HOME/lib/hive-plugin-$bdreVersion-jar-with-dependencies.jar $BDRE_APPS_HOME/$busDomainId/$processTypeId/$processId/lib
if [ $? -eq 1 ]
    then exit 1
fi

#copying spark-core jar
cp $BDRE_HOME/lib/spark-core-$bdreVersion.jar $BDRE_APPS_HOME/$busDomainId/$processTypeId/$processId/lib
if [ $? -eq 1 ]
    then exit 1
fi


# copying metadata jars
cp $BDRE_HOME/lib/md_api-$bdreVersion.jar $BDRE_APPS_HOME/$busDomainId/$processTypeId/$processId/lib

#copying jars to hdfs
hdfs dfs -put BDRE/$busDomainId/$processTypeId/$processId/lib/data-lineage-$bdreVersion.jar $hdfsPath/wf/$busDomainId/$processTypeId/$processId/lib
if [ $? -eq 1 ]
    then exit 1
fi
hdfs dfs -put BDRE/$busDomainId/$processTypeId/$processId/lib/mysql-connector-java-5.1.34.jar $hdfsPath/wf/$busDomainId/$processTypeId/$processId/lib
if [ $? -eq 1 ]
    then exit 1
fi
hdfs dfs -put BDRE/$busDomainId/$processTypeId/$processId/lib/mybatis-3.2.8.jar $hdfsPath/wf/$busDomainId/$processTypeId/$processId/lib
if [ $? -eq 1 ]
    then exit 1
fi
hdfs dfs -put BDRE/$busDomainId/$processTypeId/$processId/lib/md-commons-$bdreVersion.jar $hdfsPath/wf/$busDomainId/$processTypeId/$processId/lib
if [ $? -eq 1 ]
    then exit 1
fi
hdfs dfs -put BDRE/$busDomainId/$processTypeId/$processId/lib/md_api-$bdreVersion.jar $hdfsPath/wf/$busDomainId/$processTypeId/$processId/lib
if [ $? -eq 1 ]
    then exit 1
fi
hdfs dfs -put BDRE/$busDomainId/$processTypeId/$processId/lib/login-module-$bdreVersion.jar $hdfsPath/wf/$busDomainId/$processTypeId/$processId/lib
if [ $? -eq 1 ]
    then exit 1
fi
hdfs dfs -put BDRE/$busDomainId/$processTypeId/$processId/lib/log4j-1.2.17.jar $hdfsPath/wf/$busDomainId/$processTypeId/$processId/lib
if [ $? -eq 1 ]
    then exit 1
fi
hdfs dfs -put BDRE/$busDomainId/$processTypeId/$processId/lib/hive-plugin-$bdreVersion-jar-with-dependencies.jar $hdfsPath/wf/$busDomainId/$processTypeId/$processId/lib
if [ $? -eq 1 ]
    then exit 1
fi
hdfs dfs -put BDRE/$busDomainId/$processTypeId/$processId/lib/spark-core-$bdreVersion.jar $hdfsPath/wf/$busDomainId/$processTypeId/$processId/lib
if [ $? -eq 1 ]
    then exit 1
fi


#copy hive-site.xml to hdfs process dir
hdfs dfs -put $hadoopConfDir/hive-site.xml $hdfsPath/wf/$busDomainId/$processTypeId/$processId
if [ $? -eq 1 ]
then exit 1
fi
#copy all developer checked in files to hdfs process dir
if ssh $remoteUserName@$remoteHostPublicIp "test -e '$localPathForHQL/$processId/hql/'";
then
    if [ hostname = $remoteUserName ]
    then
        cp $localPathForHQL/$processId/hql/* BDRE/$busDomainId/$processTypeId/$processId/hql
        if [ $? -eq 1 ]
            then exit 1
        fi
        echo "file(s) copied"
    else
        scp $remoteUserName@$remoteHostPublicIp:$localPathForHQL/$processId/hql/* BDRE/$busDomainId/$processTypeId/$processId/hql
        if [ $? -eq 1 ]
          then exit 1
        fi
        echo "file(s) copied"
    fi
else
  echo "empty (or does not exist)"
fi

#copy all developer checked in files to hdfs process dir
if ssh $remoteUserName@$remoteHostPublicIp "test -e '$localPathForHQL/$processId/spark/'";
then
    if [ hostname = $remoteUserName ]
    then
        cp $localPathForHQL/$processId/spark/* BDRE/$busDomainId/$processTypeId/$processId/spark
        if [ $? -eq 1 ]
            then exit 1
        fi
        echo "file(s) copied"
    else
        scp $remoteUserName@$remoteHostPublicIp:$localPathForHQL/$processId/spark/* BDRE/$busDomainId/$processTypeId/$processId/spark
        if [ $? -eq 1 ]
          then exit 1
        fi
        echo "file(s) copied"
    fi
else
  echo "empty (or does not exist)"
fi

# hdfs dfs -put developer-apps/busDomainId-$busDomainId/processTypeId-$processTypeId/processId-$processId/* $hdfsPath/wf/$busDomainId/$processTypeId/$processId/
files=(BDRE/$busDomainId/$processTypeId/$processId/hql/*)
if [ ${#files[@]} -gt 0 ];
then
    hdfs dfs -put BDRE/$busDomainId/$processTypeId/$processId/hql/* $hdfsPath/wf/$busDomainId/$processTypeId/$processId/hql
    if [ $? -eq 1 ]
    then exit 1
    fi
fi

sparkfiles=(BDRE/$busDomainId/$processTypeId/$processId/spark/*)
if [ ${#sparkfiles[@]} -gt 0 ];
then
    hdfs dfs -put BDRE/$busDomainId/$processTypeId/$processId/spark/* $hdfsPath/wf/$busDomainId/$processTypeId/$processId/spark
    if [ $? -eq 1 ]
    then exit 1
    fi
fi
#List HDFS process dir structure

hdfs dfs -ls -R $hdfsPath/wf/$busDomainId/$processTypeId/$processId/
if [ $? -eq 1 ]
then exit 1
fi

#Create job.properties
echo nameNode=$nameNode > BDRE/$busDomainId/$processTypeId/$processId/job-$processId.properties
echo jobTracker=$jobTracker >> BDRE/$busDomainId/$processTypeId/$processId/job-$processId.properties
echo oozie.use.system.libpath=true >> BDRE/$busDomainId/$processTypeId/$processId/job-$processId.properties
echo queueName=default >> BDRE/$busDomainId/$processTypeId/$processId/job-$processId.properties
echo examplesRoot=example >> BDRE/$busDomainId/$processTypeId/$processId/job-$processId.properties
echo oozie.wf.application.path=$hdfsPath/wf/$busDomainId/$processTypeId/$processId/workflow-$processId.xml >> BDRE/$busDomainId/$processTypeId/$processId/job-$processId.properties
echo oozie.wf.validate.ForkJoin=false >> BDRE/$busDomainId/$processTypeId/$processId/job-$processId.properties