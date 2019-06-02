javaBin=""
workingDir=""
minHeap=""
maxHeap=""
maxMetaSize=""
hystrixConfigFile=""
externalConfigFile=""
verboseGC=true

if [ "${verboseGC}" == "true" ]
then
    gcInfo="-XX:+PrintGC -XX:+PrintGCDetails -XX:+PrintGCTimeStamps"

${javaBin} \
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
    -jar ${workingDir}/csf-circuit-breaker.jar
