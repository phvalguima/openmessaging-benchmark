#!/bin/sh

# Simple override build script

set -e

curl -o /tmp/apache-maven-3.9.6-bin.tar.gz https://dlcdn.apache.org/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz
tar xf /tmp/apache-maven-3.9.6-bin.tar.gz -C /tmp

# Skipping license checks because of debian/ contents
JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 /tmp/apache-maven-3.9.6/bin/mvn clean package -DskipTests  -Djacoco.skip -Dcheckstyle.skip  -Dspotless.check.skip -Dlicense.skip

# TODO: Move this to a patch
# We skip the CLASSPATH setup and instead set it up manually
cat<<EOF >bin/benchmark
#!/bin/bash
if [ -z "\$HEAP_OPTS" ]
then
    HEAP_OPTS="-Xms4G -Xmx4G"
fi

CLASSPATH=:/var/lib/opensearch-benchmark/lib/*
JVM_MEM="\${HEAP_OPTS} -XX:+UseG1GC"
JVM_GC_LOG=" -XX:+PrintGCDetails -XX:+PrintGCApplicationStoppedTime  -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=5 -XX:GCLogFileSize=64m  -Xloggc:/dev/shm/benchmark-client-gc_%p.log"
java -server -cp \$CLASSPATH \$JVM_MEM io.openmessaging.benchmark.Benchmark "\$@"
EOF
