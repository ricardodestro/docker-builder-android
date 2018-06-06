FROM macielbombonato/docker-androidsdk:latest

RUN mkdir ~/.gradle
RUN echo systemProp.sonar.host.url=http://localhost:9000 >> ~/.gradle/gradle.properties
RUN echo systemProp.sonar.login=SONAR_PLUBLICATION_KEY >> ~/.gradle/gradle.properties

RUN cat ~/.gradle/gradle.properties

CMD gradle build sonarqube --stacktrace