javaBin="/usr/bin/java"
workingDir="/opt/circuit-breaker"
minHeap="4g"
maxHeap="4g"
maxMetaSize="512m"
hystrixConfigFile="${workingDir}/config/hystrix.properties"
externalConfigFile="${workingDir}/config/application.yaml"
verboseGC=false
timeStamp="$(date +%s)"

function echoError {
    echo -e "\033[31;1m"$1"\033[0m"
}

function echoWarning {
    echo -e "\033[33;1m"$1"\033[0m"
}

function echoSuccess {
    echo -e "\033[32;1m"$1"\033[0m"
}

if [ ! -d ${workingDir} ] || [ ! -d ${workingDir}/config ] || [ ! -d ${workingDir}/logs ]
then
    RC=0
    printf "Creating directories: "
    mkdir -p ${workingDir}
    RC=$(( $RC + $? ))
    mkdir -p ${workingDir}/config
    RC=$(( $RC + $? ))
    mkdir -p ${workingDir}/logs
    RC=$(( $RC + $? ))
    if [ "${RC}" == "0" ]
    then
        echoSuccess "DONE"
    else
        echoError "Failed"
        exit 11
    fi
fi

if [ -z ${hystrixConfigFile} ] && [ -z ${externalConfigFile} ]
then
    echoError "Necessário os arquivos de configuração ${hystrixConfigFile} e ${externalConfigFile}!"
    exit 10
fi

if [ "${verboseGC}" == "true" ]
then
    echoWarning "Ativando verbose GC..."
    gcInfo="-XX:+PrintGC -XX:+PrintGCDetails -XX:+PrintGCTimeStamps"
fi

printf "Iniciando CB: "
# set -x
nohup ${javaBin} \
    -Xms${minHeap} \
    -Xmx${maxHeap} \
    -XX:MaxMetaspaceSize=${maxMetaSize} \
    -XX:+UseG1GC \
    ${gcInfo} \
    -Darchaius.fixedDelayPollingScheduler.initialDelayMills=5000 \
    -Darchaius.fixedDelayPollingScheduler.delayMills=5000 \
    -Dserver.port=8080 \
    -Darchaius.configurationSource.additionalUrls=${hystrixConfigFile} \
    -Dspring.config.location=${externalConfigFile} \
    -jar ${workingDir}/csf-circuit-breaker.jar > ${workingDir}/logs/nohup.${timeStamp}.out

if [ "$?" == "0" ]
then
    echoSuccess "DONE"
else
    echoError "Failed"
    cat ${workingDir}/logs/nohup.${timeStamp}.out
fi