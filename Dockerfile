###########################################################################################################
#
# How to build:
#
# docker build -t arkcase/pentaho-ce-install:latest .
#
###########################################################################################################

ARG PUBLIC_REGISTRY="public.ecr.aws"
ARG BASE_REPO="arkcase/base"
ARG BASE_TAG="8.7.0"
ARG VER="9.4.0.0-343"
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_SESSION_TOKEN
ARG AWS_REGION="us-east-1"
ARG S3_BUCKET="armedia-container-artifacts"
ARG S3_PATH="arkcase/pentaho/${VER}/enterprise/"
ARG MARIADB_DRIVER="3.1.2"
ARG MARIADB_DRIVER_URL="https://repo1.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client/${MARIADB_DRIVER}/mariadb-java-client-${MARIADB_DRIVER}.jar"
ARG MSSQL_DRIVER="12.2.0.jre11"
ARG MSSQL_DRIVER_URL="https://repo1.maven.org/maven2/com/microsoft/sqlserver/mssql-jdbc/${MSSQL_DRIVER}/mssql-jdbc-${MSSQL_DRIVER}.jar"
ARG MYSQL_DRIVER="8.0.32"
ARG MYSQL_DRIVER_URL="https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/${MYSQL_DRIVER}/mysql-connector-j-${MYSQL_DRIVER}.jar"
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

FROM amazon/aws-cli:latest as src

ARG PUBLIC_REGISTRY
ARG BASE_REPO
ARG BASE_TAG
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_SESSION_TOKEN
ARG AWS_REGION
ARG S3_BUCKET
ARG S3_PATH

# RUN mkdir -p "/artifacts" && \
#    aws s3 cp "s3://${S3_BUCKET}/${S3_PATH}" "/artifacts" --recursive --include "*"

FROM "${PUBLIC_REGISTRY}/${BASE_REPO}:${BASE_TAG}"

ENV JAVA_HOME=/usr/lib/jvm/jre-11-openjdk

ENV BASE_PATH="/home/pentaho/app/pentaho/pentaho-server" \
    PENTAHO_USER="pentaho" \
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
ARG ORACLE_DRIVER
ARG ORACLE_DRIVER_URL
ARG POSTGRES_DRIVER
ARG POSTGRES_DRIVER_URL
ARG ARKCASE_PREAUTH_SPRING
ARG ARKCASE_PREAUTH_VERSION
ARG ARKCASE_PREAUTH_URL
ARG PENTAHO_SERVER
ARG PENTAHO_SERVER_URL
ARG PENTAHO_PDI
ARG PENTAHO_PDI_URL

LABEL ORG="Armedia LLC" \
      APP="Pentaho EE" \
      VERSION="1.0" \
      IMAGE_SOURCE=https://github.com/ArkCase/ark_pentaho_ee \
      MAINTAINER="Armedia Devops Team <devops@armedia.com>"

RUN yum -y install \
        expect \
        java-11-openjdk \
        unzip \
    && \
    yum clean -y all && \
    mkdir -p "/home/pentaho" && \
    useradd --system --user-group "${PENTAHO_USER}" && \
    chmod 777 -R  "/home/${PENTAHO_USER}" && \
    chown -R "${PENTAHO_USER}:" "/home/${PENTAHO_USER}"

ENV PATH="${BASE_PATH}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Install Pentaho Server
#COPY "run-installer" "/home/pentaho/install/"
#RUN chmod a+rx "/home/pentaho/install/run-installer" && \
#    chown -R "${PENTAHO_USER}:" "/home/pentaho/install"

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

#    rm -rf /home/pentaho/install

#COPY --from=src "/artifacts/pentaho-server-ee-${PENTAHO_SERVER_EE}-dist.zip" "/artifacts/expect-script.exp" "/home/pentaho/install/"
#RUN cd "/home/pentaho/install" && \ 
#    ./run-installer "pentaho-server-ee-${PENTAHO_SERVER_EE}-dist.zip" "expect-script.exp"

# Install Pentaho Interactive Reporting Plugin 
#COPY --from=src "/artifacts/pir-plugin-ee-${PIR_PLUGIN_EE}-dist.zip" "/artifacts/expect-script-pir.exp" "/home/pentaho/install/"
#RUN cd "/home/pentaho/install" && \
#    ./run-installer "pir-plugin-ee-${PIR_PLUGIN_EE}-dist.zip" "expect-script-pir.exp"

# Install Pentaho Analyzer Plugin
#COPY --from=src "/artifacts/paz-plugin-ee-${PAZ_PLUGIN_EE}-dist.zip" "/artifacts/expect-script-paz.exp" "/home/pentaho/install/"
#RUN cd "/home/pentaho/install" && \
#    ./run-installer "paz-plugin-ee-${PAZ_PLUGIN_EE}-dist.zip" "expect-script-paz.exp"

# Install Pentaho Dashboard Designer Plugin
#COPY --from=src /artifacts/pdd-plugin-ee-${PAZ_PLUGIN_EE}-dist.zip /artifacts/expect-script-pdd.exp /home/pentaho/install/
#RUN cd "/home/pentaho/install" && \
#    ./run-installer "pdd-plugin-ee-${PDD_PLUGIN_EE}-dist.zip" "expect-script-pdd.exp"

# Install Pentaho Data Integration Client  
#COPY --from=src "/artifacts/pdi-ee-client-${PDI_EE_CLIENT}-dist.zip" "/artifacts/expect-script-pdi.exp" "/home/pentaho/install/"
#RUN cd "/home/pentaho/install" && \
#    ./run-installer "pdi-ee-client-${PDI_EE_CLIENT}-dist.zip" "expect-script-pdi.exp"

# Add 3rd Party Jar files  
RUN set -x && curl -L "${MYSQL_DRIVER_URL}" -o "${BASE_PATH}/tomcat/lib/mysql-connector-j-${MYSQL_DRIVER}.jar" && \
    curl -L "${MARIADB_DRIVER_URL}" -o "${BASE_PATH}/tomcat/lib/mariadb-java-client-${MARIADB_DRIVER}.jar" && \
    curl -L "${MSSQL_DRIVER_URL}" -o "${BASE_PATH}/tomcat/lib/mssql-jdbc-${MSSQL_DRIVER}.jar" && \
    curl -L "${ORACLE_DRIVER_URL}" -o "${BASE_PATH}/tomcat/lib/ojdbc11-${ORACLE_DRIVER}.jar" && \
    curl -L "${POSTGRES_DRIVER_URL}" -o "${BASE_PATH}/tomcat/lib/postgresql-${POSTGRES_DRIVER}.jar" && \
    curl -L "${ARKCASE_PREAUTH_URL}" -o "${BASE_PATH}/tomcat/webapps/pentaho/WEB-INF/lib/arkcase-preauth-springsec-v${ARKCASE_PREAUTH_SPRING}-${ARKCASE_PREAUTH_VERSION}-bundled.jar"

# Customization from previous Dockerfile
RUN chmod -R 644 "${BASE_PATH}/tomcat/conf/server.xml" && \
    export MANTLE="${BASE_PATH}/tomcat/webapps/pentaho/mantle" && \
    cp -rf "${MANTLE}/home/properties" "${MANTLE}" && \
    cp -rf "${MANTLE}/home/content" "${MANTLE}" && \
    cp -rf "${MANTLE}/home/css" "${MANTLE}" && \
    cp -rf "${MANTLE}/home/js" "${MANTLE}" && \
    cp -rf "${MANTLE}/home/images" "${MANTLE}/images" && \
    cp -rf "${MANTLE}/browser/lib" "${MANTLE}" && \
    cp -rf "${MANTLE}/browser/css/browser.css" "${MANTLE}/css" && \
    cp -rf "${MANTLE}/browser"/* "${MANTLE}"

EXPOSE 8080
WORKDIR "${BASE_PATH}"
ENTRYPOINT [ "sleep", "infinity" ]
