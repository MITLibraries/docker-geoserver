FROM java:7
MAINTAINER Mike Graves <mgraves@mit.edu>

ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64
ENV GEOSERVER_VERSION 2.8.4
ENV GEOSERVER_HOME /usr/local/geoserver
ENV GEOSERVER_DATA_DIR /var/geoserver/data

RUN mkdir -p ${GEOSERVER_HOME}
RUN mkdir -p /var/geoserver

RUN cd /tmp && \
    curl -L -O http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/geoserver-${GEOSERVER_VERSION}-bin.zip && \
    unzip geoserver-${GEOSERVER_VERSION}-bin.zip && \
    mv geoserver-${GEOSERVER_VERSION}/* ${GEOSERVER_HOME}

RUN mv ${GEOSERVER_HOME}/data_dir ${GEOSERVER_DATA_DIR}

RUN cd /tmp && \
    curl -L -O http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/extensions/geoserver-${GEOSERVER_VERSION}-importer-plugin.zip && \
    unzip -o -d ${GEOSERVER_HOME}/webapps/geoserver/WEB-INF/lib/ geoserver-${GEOSERVER_VERSION}-importer-plugin.zip

VOLUME ["${GEOSERVER_DATA_DIR}"]

EXPOSE 8080
CMD ["sh", "-c", "${GEOSERVER_HOME}/bin/startup.sh"]
