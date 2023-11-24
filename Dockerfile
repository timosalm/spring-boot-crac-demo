FROM azul/zulu-openjdk:17.0.9-jdk-crac as builder
WORKDIR application
COPY ./mvnw ./mvnw.cmd ./pom.xml .
COPY ./.mvn ./.mvn
COPY ./src ./src
RUN ./mvnw package

FROM azul/zulu-openjdk:17.0.9-jdk-crac

#RUN apk add --no-cache jattach --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/

WORKDIR application
COPY --from=builder application/target/*.jar ./app.jar

COPY ./entrypoint.sh .
#RUN mkdir /home/app/public

ENTRYPOINT ["/application/entrypoint.sh"]
