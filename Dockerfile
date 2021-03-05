FROM maven:3.6.3-openjdk-11
COPY pom.xml /pom.xml
COPY src /src
CMD mvn spring-boot:start
