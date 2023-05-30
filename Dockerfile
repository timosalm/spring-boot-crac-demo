FROM ubuntu:22.04 AS crac-checkpoint

WORKDIR /home/app

# Add required libraries
RUN apt-get update && apt-get install -y \
        curl \
        jq \
        libnl-3-200 \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME /azul-crac-jdk

# Install latest CRaC OpenJDK
RUN release="$(curl -sL https://api.github.com/repos/CRaC/openjdk-builds/releases/latest)" \
    && asset="$(echo $release | sed -e 's/\r//g' | sed -e 's/\x09//g' | tr '\n' ' ' | jq '.assets[] | select(.name | test("openjdk-[0-9]+-crac\\+[0-9]+_linux-x64\\.tar\\.gz"))')" \
    && id="$(echo $asset | jq .id)" \
    && name="$(echo $asset | jq -r .name)" \
    && curl -LJOH 'Accept: application/octet-stream' "https://api.github.com/repos/CRaC/openjdk-builds/releases/assets/$id" >&2 \
    && tar xzf "$name" \
    && mv ${name%%.tar.gz} $JAVA_HOME \
    && rm "$name"

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
COPY --from=crac-checkpoint /azul-crac-jdk /azul-crac-jdk

# Copy layers
COPY cr /home/app/cr
COPY --from=crac-checkpoint /home/app/spring-boot-crac-demo.jar /home/app/spring-boot-crac-demo.jar
COPY src/scripts/run.sh /home/app/run.sh

ENTRYPOINT ["/home/app/run.sh"]
