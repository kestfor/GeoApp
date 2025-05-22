FROM openjdk:21-oracle

COPY ./src ./src
COPY ./build.gradle ./build.gradle
COPY ./gradlew.bat ./gradlew.bat
COPY ./gradlew ./gradlew
COPY ./gradle ./gradle
COPY ./settings.gradle ./settings.gradle

RUN ./gradlew build

WORKDIR /build/libs/

EXPOSE 50080
CMD ["java", "-jar", "ms_users-0.0.1.jar"]
