FROM openjdk:8u171-jre-alpine3.7

LABEL maintainer="foss@enkel.com.br"

USER root

ARG sb_jar

ENV jar_file=$sb_jar

RUN mkdir -p /opt/enkel/

COPY ${jar_file} /opt/enkel/enkel-circuit-breaker.jar

WORKDIR /opt/enkel/

USER nobody

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

EXPOSE 8080

CMD /bin/sh -l -c '/usr/bin/java -Xms${MIN_HEAP} -Xmx${MAX_HEAP} -XX:MaxMetaspaceSize=${MAX_META_SIZE} -XX:+UseG1GC -Darchaius.configurationSource.additionalUrls=${HYSTRIX_CONFIG_FILE} -Darchaius.fixedDelayPollingScheduler.initialDelayMills=5000 -Darchaius.fixedDelayPollingScheduler.delayMills=5000 -Dserver.port=8080 -Dspring.config.location=${EXT_CONFIG_FILE} -jar enkel-circuit-breaker.jar'
