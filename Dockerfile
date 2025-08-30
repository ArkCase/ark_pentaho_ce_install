###########################################################################################################
#
# How to build:
#
# docker build -t arkcase/pentaho-ce-install:latest .
#
###########################################################################################################

ARG PUBLIC_REGISTRY="public.ecr.aws"
ARG VER="9.4.0.0"
ARG JAVA="11"
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_SESSION_TOKEN
ARG AWS_REGION="us-east-1"

ARG ARTIFACT_VER="${VER}-343"
ARG S3_BUCKET="armedia-container-artifacts"
ARG S3_PATH="arkcase/pentaho/${ARTIFACT_VER}/community/"
ARG MARIADB_DRIVER="3.1.2"
ARG MARIADB_DRIVER_SRC="org.mariadb.jdbc:mariadb-java-client:${MARIADB_DRIVER}"
ARG MSSQL_DRIVER="12.2.0.jre11"
ARG MSSQL_DRIVER_SRC="com.microsoft.sqlserver:mssql-jdbc:${MSSQL_DRIVER}"
ARG MYSQL_DRIVER="8.2.0"
ARG MYSQL_DRIVER_SRC="com.mysql.mysql-connector-j:${MYSQL_DRIVER}"
ARG ORACLE_DRIVER="21.9.0.0"
ARG ORACLE_DRIVER_SRC="com.oracle.database.jdbc:ojdbc11:${ORACLE_DRIVER}"
ARG POSTGRES_DRIVER="42.5.4"
ARG POSTGRES_DRIVER_SRC="org.postgresql:postgresql:${POSTGRES_DRIVER}"

ARG ARKCASE_MVN_REPO="https://nexus.armedia.com/repository/arkcase"
ARG MYSQL_LEGACY_DRIVER="1.0.0"
ARG MYSQL_LEGACY_DRIVER_SRC="com.armedia.mysql:mysql-legacy-driver:${MYSQL_LEGACY_DRIVER}"
ARG ARKCASE_PREAUTH_SPRING="5"
ARG ARKCASE_PREAUTH_VERSION="1.4.0"
ARG ARKCASE_PREAUTH_SRC="com.armedia.arkcase.preauth:arkcase-preauth-springsec-v${ARKCASE_PREAUTH_SPRING}:${ARKCASE_PREAUTH_VERSION}:jar:bundled"
ARG NEO4J_PLUGIN_VER="5.0.9"
ARG NEO4J_PLUGIN_URL="https://github.com/knowbi/knowbi-pentaho-pdi-neo4j-output/releases/download/${NEO4J_PLUGIN_VER}/Neo4JOutput-${NEO4J_PLUGIN_VER}.zip"
ARG TCNATIVE_VER="1.2.35"
ARG TCNATIVE_URL="https://archive.apache.org/dist/tomcat/tomcat-connectors/native/${TCNATIVE_VER}/source/tomcat-native-${TCNATIVE_VER}-src.tar.gz"

ARG BASE_REGISTRY="${PUBLIC_REGISTRY}"
ARG BASE_REPO="arkcase/base-java"
ARG BASE_VER="8"
ARG BASE_VER_PFX=""
ARG BASE_IMG="${BASE_REGISTRY}/${BASE_REPO}:${BASE_VER_PFX}${BASE_VER}"

FROM amazon/aws-cli:latest AS src

ARG PUBLIC_REGISTRY
ARG BASE_REPO
ARG BASE_VER
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_SESSION_TOKEN
ARG AWS_REGION
ARG S3_BUCKET
ARG S3_PATH

RUN mkdir -p "/artifacts" && \
    aws s3 cp "s3://${S3_BUCKET}/${S3_PATH}" "/artifacts" --recursive --include "*" && \
    yum -y install unzip && \
    mkdir -p "/install" "/install/pentaho" "/install/pentaho-pdi" && \
    unzip "/artifacts/pentaho-server-ce-${VER}.zip" -d "/install/pentaho" && \
    unzip "/artifacts/pdi-ce-${PENTAHO_PDI}.zip" -d "/install/pentaho-pdi"
RUN ls -l "/artifacts/" "/install" "/install"/* && sleep 10

FROM "${BASE_IMG}"

ENV BASE_DIR="/home/pentaho/app"
ENV PENTAHO_HOME="${BASE_DIR}/pentaho"
ENV PENTAHO_PDI_HOME="${BASE_DIR}/pentaho-pdi"
ENV PENTAHO_PDI_LIB="${PENTAHO_PDI_HOME}/data-integration/lib"
ENV PENTAHO_PDI_PLUGINS="${PENTAHO_PDI_HOME}/data-integration/plugins"
ENV PENTAHO_TOMCAT="${PENTAHO_HOME}/pentaho-server/tomcat"

ENV PENTAHO_USER="pentaho" \
    PENTAHO_PDI="pentaho-pdi"

ARG VER
ARG JAVA
ARG ARTIFACT_VER
ARG RESOURCE_PATH="artifacts"
ARG PENTAHO_SERVER_CE="${ARTIFACT_VER}"
ARG PIR_PLUGIN_CE="${ARTIFACT_VER}"
ARG PAZ_PLUGIN_CE="${ARTIFACT_VER}"
ARG PDD_PLUGIN_CE="${ARTIFACT_VER}"
ARG PDI_CE_CLIENT="${ARTIFACT_VER}"
ARG MARIADB_DRIVER_SRC
ARG MSSQL_DRIVER_SRC
ARG MYSQL_DRIVER_SRC
ARG MYSQL_LEGACY_DRIVER_SRC
ARG ORACLE_DRIVER_SRC
ARG POSTGRES_DRIVER_SRC
ARG ARKCASE_PREAUTH_SRC
ARG NEO4J_PLUGIN_URL
ARG TCNATIVE_URL

LABEL ORG="Armedia LLC" \
      APP="Pentaho CE" \
      VERSION="1.0" \
      IMAGE_SOURCE=https://github.com/ArkCase/ark_pentaho_ce \
      MAINTAINER="Armedia Devops Team <devops@armedia.com>"

RUN set-java "${JAVA}" && \
    yum -y install \
        apr-devel \
        expect \
        gcc \
        make \
        openssl-devel \
        redhat-rpm-config \
        unzip \
      && \
    yum clean -y all && \
    mkdir -p "/home/pentaho" && \
    useradd --system --user-group "${PENTAHO_USER}" && \
    chmod 777 -R  "/home/${PENTAHO_USER}" && \
    chown -R "${PENTAHO_USER}:" "/home/${PENTAHO_USER}"

USER "${PENTAHO_USER}"

RUN mkdir -p "/home/${PENTAHO_USER}/app"
COPY --from=src "/install"/* "/home/${PENTAHO_USER}/app/"
RUN chown -R "${PENTAHO_USER}:" "/home/${PENTAHO_USER}/app"

# Add 3rd Party Jar files  
RUN set -x && \
    rm -fv \
        "${PENTAHO_TOMCAT}/lib"/mysql-connector-java-*.jar \
        "${PENTAHO_TOMCAT}/lib"/postgresql-*.jar \
      && \
    mvn-get "${MYSQL_DRIVER_SRC}" "${PENTAHO_TOMCAT}/lib" && \
    mvn-get "${MARIADB_DRIVER_SRC}" "${PENTAHO_TOMCAT}/lib" && \
    mvn-get "${MSSQL_DRIVER_SRC}" "${PENTAHO_TOMCAT}/lib" && \
    mvn-get "${ORACLE_DRIVER_SRC}" "${PENTAHO_TOMCAT}/lib" && \
    mvn-get "${POSTGRES_DRIVER_SRC}" "${PENTAHO_TOMCAT}/lib" && \
    mvn-get "${MYSQL_LEGACY_DRIVER_SRC}" "${ARKCASE_MVN_REPO}" "${PENTAHO_TOMCAT}/lib" && \
    mvn-get "${ARKCASE_PREAUTH_SRC}" "${ARKCASE_MVN_REPO}" "${PENTAHO_TOMCAT}/webapps/pentaho/WEB-INF/lib" && \
    rm -fv \
        "${PENTAHO_PDI_LIB}"/mysql-connector-java-*.jar \
        "${PENTAHO_PDI_LIB}"/postgresql-*.jar \
     && \
    ln -vf \
        "${PENTAHO_TOMCAT}/lib"/mysql-connector-j-*.jar \
        "${PENTAHO_TOMCAT}/lib"/mysql-legacy-driver-*.jar \
        "${PENTAHO_TOMCAT}/lib"/mariadb-java-client-*.jar \
        "${PENTAHO_TOMCAT}/lib"/mssql-jdbc-*.jar \
        "${PENTAHO_TOMCAT}/lib"/ojdbc11-*.jar \
        "${PENTAHO_TOMCAT}/lib"/postgresql-*.jar \
        "${PENTAHO_PDI_LIB}"

# Customization from previous Dockerfile
RUN chmod -R 644 "${PENTAHO_TOMCAT}/conf/server.xml" && \
    export MANTLE="${PENTAHO_TOMCAT}/webapps/pentaho/mantle" && \
    cp -rf "${MANTLE}/home/properties" "${MANTLE}" && \
    cp -rf "${MANTLE}/home/content" "${MANTLE}" && \
    cp -rf "${MANTLE}/home/css" "${MANTLE}" && \
    cp -rf "${MANTLE}/home/js" "${MANTLE}" && \
    cp -rf "${MANTLE}/home/images" "${MANTLE}/images" && \
    cp -rf "${MANTLE}/browser/lib" "${MANTLE}" && \
    cp -rf "${MANTLE}/browser/css/browser.css" "${MANTLE}/css" && \
    cp -rf "${MANTLE}/browser"/* "${MANTLE}"

# Add the Neo4j Plugin
RUN curl -L "${NEO4J_PLUGIN_URL}" -o "${PENTAHO_PDI_PLUGINS}/neo4j.zip" && \
    unzip -d "${PENTAHO_PDI_PLUGINS}" "${PENTAHO_PDI_PLUGINS}/neo4j.zip" && \
    rm -fv "${PENTAHO_PDI_PLUGINS}/neo4j.zip"

# Build the Tomcat native APR connector
RUN cd "${PENTAHO_TOMCAT}" && \
    curl -L "${TCNATIVE_URL}" | tar -xzvf - && \
    cd tomcat-native-*-src/native && \
    ./configure --prefix="${PENTAHO_TOMCAT}" && \
    make && \
    make install && \
    rm -rf tomcat-native-*-src

EXPOSE 8080
WORKDIR "${PENTAHO_HOME}"
ENTRYPOINT [ "sleep", "infinity" ]
