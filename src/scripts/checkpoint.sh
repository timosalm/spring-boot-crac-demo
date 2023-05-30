#!/bin/bash
set -x

echo "JAVA HOME is " +  $JAVA_HOME

# Bump pid to avoid pid conflicts when restoring
echo 599 > /proc/sys/kernel/ns_last_pid

# Set a trap to close the app once the script finishes
#trap 'echo "Killing $PROCESS" && kill -0 $PROCESS 2>/dev/null && kill $PROCESS' EXIT

echo "Starting application"

# Fix for WSL and OS X Docker Kernels
GLIBC_TUNABLES=glibc.pthread.rseq=0

# Run the app in the background
${JAVA_HOME}/bin/java \
  -XX:CRaCCheckpointTo=cr \
  -XX:+UnlockDiagnosticVMOptions \
  -XX:+CRTraceStartupTime \
  -Djdk.crac.trace-startup-time=true \
  -jar /home/app/spring-boot-crac-demo.jar &
PROCESS=$!
echo "Started application as process $PROCESS"

# Wait for the app to be started
echo "Waiting 10s for application to start"
retries=5
until $(curl --output /dev/null --silent --head http://localhost:8080); do
  if [ $retries -le 0 ]; then
    echo "failed"
    exit 1
  fi
  echo -n '.'
  sleep 2
  retries=$((retries - 1))
done

# Warm up the app.
echo "Warming up application"
./warmup.sh

# Take a snapshot
echo "Sending checkpoint signal to process $PROCESS"
${JAVA_HOME}/bin/jcmd $PROCESS JDK.checkpoint

sleep 30
kill -TERM $PROCESS 2>/dev/null
echo "Snapshotting complete"
sleep 30
chmod 666 cr/*