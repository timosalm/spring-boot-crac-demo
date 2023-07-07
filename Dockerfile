FROM ubuntu:22.04 AS crac-checkpoint

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

# Add build scripts
COPY src/scripts/checkpoint.sh /home/app/checkpoint.sh
COPY src/scripts/warmup.sh /home/app/warmup.sh

RUN /home/app/checkpoint.sh

FROM ubuntu:22.04

WORKDIR /home/app

# Add required libraries
RUN apt-get update && apt-get install -y \
        libnl-3-200 \
    && rm -rf /var/lib/apt/lists/*

# Copy CRaC JDK from the checkpoint image (to save a download)
COPY --chown=1000 --from=crac-checkpoint /azul-crac-jdk /azul-crac-jdk

# Copy layers
COPY --chown=1000 --from=crac-checkpoint /home/app/cr/ /home/app/cr/
COPY --chown=1000 --from=crac-checkpoint /home/app/spring-boot-crac-demo.jar /home/app/spring-boot-crac-demo.jar
COPY --chown=1000 src/scripts/run.sh /home/app/run.sh

RUN chown -R 1000:1000 /tmp

ENTRYPOINT ["/home/app/run.sh"]
