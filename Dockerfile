###########################################################################################################
#
# How to build:
#
# docker build -t arkcase/pentaho-ce-install:latest .
#
###########################################################################################################

ARG PUBLIC_REGISTRY="public.ecr.aws"
ARG BASE_REPO="arkcase/base"
ARG BASE_TAG="8-02"
ARG VER="9.4.0.0-343"
ARG BLD="02"
ARG MARIADB_DRIVER="3.1.2"
ARG MARIADB_DRIVER_URL="https://repo1.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client/${MARIADB_DRIVER}/mariadb-java-client-${MARIADB_DRIVER}.jar"
ARG MSSQL_DRIVER="12.2.0.jre11"
ARG MSSQL_DRIVER_URL="https://repo1.maven.org/maven2/com/microsoft/sqlserver/mssql-jdbc/${MSSQL_DRIVER}/mssql-jdbc-${MSSQL_DRIVER}.jar"
ARG MYSQL_DRIVER="8.0.32"
ARG MYSQL_DRIVER_URL="https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/${MYSQL_DRIVER}/mysql-connector-j-${MYSQL_DRIVER}.jar"
ARG MYSQL_LEGACY_DRIVER="1.0.0"
ARG MYSQL_LEGACY_DRIVER_URL="https://project.armedia.com/nexus/repository/arkcase/com/armedia/mysql/mysql-legacy-driver/${MYSQL_LEGACY_DRIVER}/mysql-legacy-driver-${MYSQL_LEGACY_DRIVER}.jar"
ARG ORACLE_DRIVER="21.9.0.0"
ARG ORACLE_DRIVER_URL="https://repo1.maven.org/maven2/com/oracle/database/jdbc/ojdbc11/${ORACLE_DRIVER}/ojdbc11-${ORACLE_DRIVER}.jar"
ARG POSTGRES_DRIVER="42.5.4"
ARG POSTGRES_DRIVER_URL="https://repo1.maven.org/maven2/org/postgresql/postgresql/${POSTGRES_DRIVER}/postgresql-${POSTGRES_DRIVER}.jar"
ARG ARKCASE_PREAUTH_SPRING="5"
ARG ARKCASE_PREAUTH_VERSION="1.1.2"
ARG ARKCASE_PREAUTH_URL="https://project.armedia.com/nexus/repository/arkcase/com/armedia/arkcase/preauth/arkcase-preauth-springsec-v${ARKCASE_PREAUTH_SPRING}/${ARKCASE_PREAUTH_VERSION}/arkcase-preauth-springsec-v${ARKCASE_PREAUTH_SPRING}-${ARKCASE_PREAUTH_VERSION}-bundled.jar"
ARG PENTAHO_SERVER="9.4.0.0-343"
ARG PENTAHO_SERVER_URL="https://privatefilesbucket-community-edition.s3.us-west-2.amazonaws.com/${PENTAHO_SERVER}/ce/server/pentaho-server-ce-${PENTAHO_SERVER}.zip"
ARG PENTAHO_PDI="${PENTAHO_SERVER}"
ARG PENTAHO_PDI_URL="https://privatefilesbucket-community-edition.s3.us-west-2.amazonaws.com/${PENTAHO_PDI}/ce/client-tools/pdi-ce-${PENTAHO_PDI}.zip"
ARG NEO4J_PLUGIN_VER="5.0.9"
ARG NEO4J_PLUGIN_URL="https://github.com/knowbi/knowbi-pentaho-pdi-neo4j-output/releases/download/${NEO4J_PLUGIN_VER}/Neo4JOutput-${NEO4J_PLUGIN_VER}.zip"
ARG TCNATIVE_VER="1.2.35"
ARG TCNATIVE_URL="https://archive.apache.org/dist/tomcat/tomcat-connectors/native/${TCNATIVE_VER}/source/tomcat-native-${TCNATIVE_VER}-src.tar.gz"

FROM "${PUBLIC_REGISTRY}/${BASE_REPO}:${BASE_TAG}"

ENV JAVA_HOME=/usr/lib/jvm/jre-11-openjdk

ENV BASE_DIR="/home/pentaho/app"
ENV PENTAHO_HOME="${BASE_DIR}/pentaho"
ENV PENTAHO_PDI_HOME="${BASE_DIR}/pentaho-pdi"
ENV PENTAHO_PDI_LIB="${PENTAHO_PDI_HOME}/data-integration/lib"
ENV PENTAHO_PDI_PLUGINS="${PENTAHO_PDI_HOME}/data-integration/plugins"
ENV PENTAHO_TOMCAT="${PENTAHO_HOME}/pentaho-server/tomcat"

ENV PENTAHO_USER="pentaho" \
    PENTAHO_PDI="pentaho-pdi"

ARG VER
ARG RESOURCE_PATH="artifacts"
ARG PENTAHO_SERVER_EE="${VER}"
ARG PIR_PLUGIN_EE="${VER}"
ARG PAZ_PLUGIN_EE="${VER}"
ARG PDD_PLUGIN_EE="${VER}"
ARG PDI_EE_CLIENT="${VER}"
ARG MARIADB_DRIVER
ARG MARIADB_DRIVER_URL
ARG MSSQL_DRIVER
ARG MSSQL_DRIVER_URL
ARG MYSQL_DRIVER
ARG MYSQL_DRIVER_URL
ARG MYSQL_LEGACY_DRIVER
ARG MYSQL_LEGACY_DRIVER_URL
ARG ORACLE_DRIVER
ARG ORACLE_DRIVER_URL
ARG POSTGRES_DRIVER
ARG POSTGRES_DRIVER_URL
ARG ARKCASE_PREAUTH_SPRING
ARG ARKCASE_PREAUTH_VERSION
ARG ARKCASE_PREAUTH_URL
ARG NEO4J_PLUGIN_URL
ARG PENTAHO_SERVER
ARG PENTAHO_SERVER_URL
ARG PENTAHO_PDI
ARG PENTAHO_PDI_URL
ARG TCNATIVE_URL

LABEL ORG="Armedia LLC" \
      APP="Pentaho EE" \
      VERSION="1.0" \
      IMAGE_SOURCE=https://github.com/ArkCase/ark_pentaho_ee \
      MAINTAINER="Armedia Devops Team <devops@armedia.com>"

RUN yum -y install \
        apr-devel \
        expect \
        gcc \
        java-11-openjdk \
        java-11-devel \
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

RUN mkdir -p "/home/${PENTAHO_USER}/install" && \
    mkdir -p "/home/${PENTAHO_USER}/app/pentaho" && \
    set -x && \
    curl -L "${PENTAHO_SERVER_URL}" -o "/home/${PENTAHO_USER}/install/pentaho-server-ce-${PENTAHO_SERVER}.zip" && \
    unzip -q "/home/${PENTAHO_USER}/install/pentaho-server-ce-${PENTAHO_SERVER}.zip" -d "/home/${PENTAHO_USER}/app/pentaho/" && \
    mkdir -p "/home/${PENTAHO_USER}/app/pentaho-pdi" && \
    set -x && \
    curl -L "${PENTAHO_PDI_URL}" -o "/home/${PENTAHO_USER}/install/pdi-ce-${PENTAHO_PDI}.zip" && \
    unzip -q "/home/${PENTAHO_USER}/install/pdi-ce-${PENTAHO_PDI}.zip" -d "/home/${PENTAHO_USER}/app/pentaho-pdi/" && \
    rm -rf "/home/${PENTAHO_USER}/install"

# Add 3rd Party Jar files  
RUN set -x && \
    rm -fv \
        "${PENTAHO_TOMCAT}/lib"/mysql-connector-java-*.jar \
        "${PENTAHO_TOMCAT}/lib"/postgresql-*.jar \
     && \
    curl -L --fail "${MYSQL_DRIVER_URL}" -o "${PENTAHO_TOMCAT}/lib/mysql-connector-j-${MYSQL_DRIVER}.jar" && \
    curl -L --fail "${MYSQL_LEGACY_DRIVER_URL}" -o "${PENTAHO_TOMCAT}/lib/mysql-legacy-driver-${MYSQL_LEGACY_DRIVER}.jar" && \
    curl -L --fail "${MARIADB_DRIVER_URL}" -o "${PENTAHO_TOMCAT}/lib/mariadb-java-client-${MARIADB_DRIVER}.jar" && \
    curl -L --fail "${MSSQL_DRIVER_URL}" -o "${PENTAHO_TOMCAT}/lib/mssql-jdbc-${MSSQL_DRIVER}.jar" && \
    curl -L --fail "${ORACLE_DRIVER_URL}" -o "${PENTAHO_TOMCAT}/lib/ojdbc11-${ORACLE_DRIVER}.jar" && \
    curl -L --fail "${POSTGRES_DRIVER_URL}" -o "${PENTAHO_TOMCAT}/lib/postgresql-${POSTGRES_DRIVER}.jar" && \
    curl -L --fail "${ARKCASE_PREAUTH_URL}" -o "${PENTAHO_TOMCAT}/webapps/pentaho/WEB-INF/lib/arkcase-preauth-springsec-v${ARKCASE_PREAUTH_SPRING}-${ARKCASE_PREAUTH_VERSION}-bundled.jar" && \
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
RUN curl -L "${NEO4J_PLUGIN_URL}"  -o "${PENTAHO_PDI_PLUGINS}/neo4j.zip" && \
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
