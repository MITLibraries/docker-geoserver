FROM ubuntu:22.04

# Based on github.com/geoserver/docker, but for now, we cannot use that image
# because
#  1. there are too many typos in the ARG and ENV statements (related to trialing slashes)
#  2. there is an issue with the S3 GeoTIFF module in GeoServer > 2.18
# When those issues are resolved, we can replace the first line above with the line below
# FROM docker.osgeo.org/geoserver:2.21.1

# Local values for building the container
ARG TOMCAT_VERSION=9.0.65
ARG GS_VERSION=2.18.6
ARG GS_VERSION_MAJOR=2.18
ARG GS_DATA_PATH=./geoserver_data
ARG ADDITIONAL_LIBS_PATH=./additional_libs
ARG ADDITIONAL_FONTS_PATH=./additional_fonts
ARG CORS_ENABLED=true
ARG CORS_ALLOWED_ORIGINS=*
ARG CORS_ALLOWED_METHODS=GET,POST,PUT,DELETE,HEAD,OPTIONS
ARG CORS_ALLOWED_HEADERS=*
ARG STABLE_PLUGIN_URL=https://sourceforge.net/projects/geoserver/files/GeoServer/${GS_VERSION}/extensions

# Environment variables in the running container
ENV CATALINA_HOME=/opt/apache-tomcat-${TOMCAT_VERSION}
ENV GEOSERVER_VERSION=$GS_VERSION
ENV GEOSERVER_DATA_DIR=/opt/geoserver_data
ENV GEOSERVER_REQUIRE_FILE=$GEOSERVER_DATA_DIR/global.xml
ENV GEOSERVER_LIB_DIR=$CATALINA_HOME/webapps/geoserver/WEB-INF/lib
ENV EXTRA_JAVA_OPTS="-Xms256m -Xmx1g"
ENV CORS_ENABLED=$CORS_ENABLED
ENV CORS_ALLOWED_ORIGINS=$CORS_ALLOWED_ORIGINS
ENV CORS_ALLOWED_METHODS=$CORS_ALLOWED_METHODS
ENV CORS_ALLOWED_HEADERS=$CORS_ALLOWED_HEADERS
ENV DEBIAN_FRONTEND=noninteractive
ENV INSTALL_EXTENSIONS=false
ENV STABLE_EXTENSIONS=''
ENV STABLE_PLUGIN_URL=$STABLE_PLUGIN_URL
ENV ADDITIONAL_LIBS_DIR=/opt/additional_libs
ENV ADDITIONAL_FONTS_DIR=/opt/additional_fonts

# Extra MIT Libraries ENV
ENV GEOSERVER_CSRF_DISABLED=true
ENV JAVA_OPTS="-Ds3.properties.location=${GEOSERVER_DATA_DIR}/s3.properties"
ENV GEOTIFF_SOURCE=$ADDITIONAL_LIBS_PATH/geoserver-${GS_VERSION_MAJOR}-SNAPSHOT-s3-geotiff-plugin
ENV ADDITIONAL_DATA_DIR=/opt/additional_data

# see https://docs.geoserver.org/stable/en/user/production/container.html
ENV CATALINA_OPTS="${EXTRA_JAVA_OPTS} \
    ${JAVA_OPTS} \
    -Djava.awt.headless=true -server \
    -Dfile.encoding=UTF-8 \
    -Djavax.servlet.request.encoding=UTF-8 \
    -Djavax.servlet.response.encoding=UTF-8 \
    -D-XX:SoftRefLRUPolicyMSPerMB=36000 \
    -Xbootclasspath/a:${CATALINA_HOME}/lib/marlin.jar \
    -Dsun.java2d.renderer=org.marlin.pisces.PiscesRenderingEngine \
    -Dorg.geotools.coverage.jaiext.enabled=true"

# init
RUN apt update && \
    apt -y upgrade && \
    apt install -y --no-install-recommends openssl unzip gdal-bin wget curl openjdk-11-jdk gettext && \
    apt clean && \
    rm -rf /var/cache/apt/* && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/
RUN wget -q https://dlcdn.apache.org/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    tar xf apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    rm apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    rm -rf /opt/apache-tomcat-${TOMCAT_VERSION}/webapps/ROOT && \
    rm -rf /opt/apache-tomcat-${TOMCAT_VERSION}/webapps/docs && \
    rm -rf /opt/apache-tomcat-${TOMCAT_VERSION}/webapps/examples

WORKDIR /tmp

# install geoserver
RUN wget -q -O /tmp/geoserver.zip https://downloads.sourceforge.net/project/geoserver/GeoServer/$GEOSERVER_VERSION/geoserver-$GEOSERVER_VERSION-war.zip && \
    unzip geoserver.zip geoserver.war -d $CATALINA_HOME/webapps && \
    mkdir -p $CATALINA_HOME/webapps/geoserver && \
    unzip -q $CATALINA_HOME/webapps/geoserver.war -d $CATALINA_HOME/webapps/geoserver && \
    rm $CATALINA_HOME/webapps/geoserver.war && \
    mv $CATALINA_HOME/webapps/geoserver/WEB-INF/lib/marlin-0.9.3.jar $CATALINA_HOME/lib/marlin.jar && \
    mkdir -p $GEOSERVER_DATA_DIR


# MIT Libraries specific fixes
COPY $GEOTIFF_SOURCE/*.jar ${ADDITIONAL_LIBS_DIR}/
COPY $ADDITIONAL_FONTS_PATH ${ADDITIONAL_FONTS_DIR}/
COPY $GS_DATA_PATH ${ADDITIONAL_DATA_DIR}/

# cleanup
RUN apt purge -y && \
    apt autoremove --purge -y && \
    rm -rf /tmp/*

# copy scripts
COPY --chmod=0755 *.sh /opt/

ENTRYPOINT /opt/startup.sh

WORKDIR /opt

EXPOSE 8080
