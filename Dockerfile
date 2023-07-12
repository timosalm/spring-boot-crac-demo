FROM ubuntu:22.04 AS build-app
WORKDIR /home/app

USER root

# Add required libraries
RUN apt-get update && apt-get install -y \
        curl \
        jq \
        libnl-3-200 \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME /azul-crac-jdk

RUN mkdir $JAVA_HOME \
  && curl https://cdn.azul.com/zulu/bin/zulu17.42.21-ca-crac-jdk17.0.7-linux_x64.tar.gz | tar -xz --strip-components 1 -C $JAVA_HOME

COPY mvnw mvnw.cmd pom.xml /home/app/
COPY .mvn/ /home/app/.mvn/
COPY src/ /home/app/src/
RUN ./mvnw package && mv target/spring-boot-crac-demo-1.0.0-SNAPSHOT.jar spring-boot-crac-demo.jar

FROM ubuntu:22.04

WORKDIR /home/app

USER root

ENV JAVA_HOME /azul-crac-jdk
ENV PATH $PATH:$JAVA_HOME/bin

# Add required libraries
RUN apt-get update && apt-get install -y \
        libnl-3-200 \
    && rm -rf /var/lib/apt/lists/*

# Copy CRaC JDK from the checkpoint image (to save a download)
COPY --from=build-app $JAVA_HOME $JAVA_HOME



# Copy layers
COPY --from=build-app /home/app/spring-boot-crac-demo.jar /home/app/spring-boot-crac-demo.jar
COPY src/scripts/entrypoint.sh /home/app/entrypoint.sh

ENTRYPOINT ["/home/app/entrypoint.sh"]
