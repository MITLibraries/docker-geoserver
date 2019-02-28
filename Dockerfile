FROM openjdk:8

ENV GEOSERVER_VERSION 2.14.2
ENV GEOSERVER_VERSION_MM 2.14
ENV GEOSERVER_HOME /usr/local/geoserver
ENV GEOSERVER_DATA_DIR /var/geoserver/data

RUN apt-get update && apt-get install -y gettext
RUN mkdir -p ${GEOSERVER_HOME}
RUN mkdir -p /var/geoserver

RUN cd /tmp && \
    curl -L -O http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/geoserver-${GEOSERVER_VERSION}-bin.zip && \
    unzip geoserver-${GEOSERVER_VERSION}-bin.zip && \
    mv geoserver-${GEOSERVER_VERSION}/* ${GEOSERVER_HOME}

RUN mv ${GEOSERVER_HOME}/data_dir ${GEOSERVER_DATA_DIR}
RUN cd /tmp && \
    curl -OL https://build.geoserver.org/geoserver/${GEOSERVER_VERSION_MM}.x/community-latest/geoserver-${GEOSERVER_VERSION_MM}-SNAPSHOT-s3-geotiff-plugin.zip && \
    unzip -o -d ${GEOSERVER_HOME}/webapps/geoserver/WEB-INF/lib/ geoserver-${GEOSERVER_VERSION_MM}-SNAPSHOT-s3-geotiff-plugin.zip

COPY data ${GEOSERVER_DATA_DIR}
COPY entrypoint.sh /usr/local/bin/

VOLUME ["${GEOSERVER_DATA_DIR}"]

ENV GEOSERVER_PASSWORD geoserver

EXPOSE 8080
ENTRYPOINT ["entrypoint.sh"]
CMD ["sh", "-c", "${GEOSERVER_HOME}/bin/startup.sh"]
