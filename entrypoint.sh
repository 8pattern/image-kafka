#!/bin/bash

set -e

CONFIG_FILE=config/kraft/server.properties

echo ${KAFKA_BROKER_ID:=-1} > /dev/null
echo ${KAFKA_PORT:=9092} > /dev/null

# echo ${KAFKA_CLUSTER_ID:=`kafka-storage.sh random-uuid`}

if [[ -z "$KAFKA_CLUSTER_ID" ]]; then
    KAFKA_CLUSTER_ID=$(kafka-storage.sh random-uuid)
fi

if [[ -z "$KAFKA_ADVERTISED_PORT" ]]; then
    export KAFKA_ADVERTISED_PORT=$KAFKA_PORT
fi
if [[ -z "$KAFKA_ADVERTISED_HOST_NAME" ]]; then
    export KAFKA_ADVERTISED_HOST_NAME=localhost
fi
if [[ -z "$KAFKA_LISTENERS" ]]; then
    export KAFKA_LISTENERS=PLAINTEXT://0.0.0.0:$KAFKA_PORT,CONTROLLER://:9093
fi
if [[ -z "$KAFKA_ADVERTISED_LISTENERS" ]]; then
    export KAFKA_ADVERTISED_LISTENERS="PLAINTEXT://$KAFKA_ADVERTISED_HOST_NAME:$KAFKA_ADVERTISED_PORT"
fi

unset KAFKA_ADVERTISED_HOST_NAME
unset KAFKA_ADVERTISED_PORT

for VAR in `env`
do
  if [[ $VAR =~ ^KAFKA_ && ! $VAR =~ ^KAFKA_HOME ]]; then
    kafka_name=`echo "$VAR" | sed -r "s/KAFKA_(.*)=.*/\1/g" | tr '[:upper:]' '[:lower:]' | tr _ .`
    env_var=`echo "$VAR" | sed -r "s/(.*)=.*/\1/g"`
    echo "DYNAMTIC CONFIG========================================================================="
    echo "$kafka_name=${!env_var}"
    if egrep -q "(^|^#)$kafka_name=" $CONFIG_FILE; then
        sed -r -i "s@(^|^#)($kafka_name)=(.*)@\2=${!env_var}@g" $CONFIG_FILE
    # else
        # echo "$kafka_name=${!env_var}" >> $CONFIG_FILE
    fi
  fi
done


kafka-storage.sh format --config $CONFIG_FILE --cluster-id $KAFKA_CLUSTER_ID

kafka-server-start.sh $CONFIG_FILE
