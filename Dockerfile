FROM docker.io/openjdk:8-jre-alpine

ENV KAFKA_VERSION 3.3.2
ENV SCALA_VERSION 2.13

LABEL name="kafka" version=${KAFKA_VERSION}

RUN apk add --no-cache bash && \
  apk add --no-cache -t .build-deps curl && \
  mkdir -p /opt && \
  curl -sSL "https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz" | tar -xzf - -C /opt && \
  mv /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} /opt/kafka && \
  # adduser -DH -s /sbin/nologin kafka && \
  # chown -R kafka: /opt/kafka && \
  rm -rf /tmp/* && \
  apk del --purge .build-deps

ENV PATH /sbin:/opt/kafka/bin/:$PATH
WORKDIR /opt/kafka

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 9092
EXPOSE 9093
