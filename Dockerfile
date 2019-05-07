# Base image used for both building and running
FROM openjdk:8-jre-alpine AS base

ENV GEOSERVER_VERSION 2.14.3
ENV GEOSERVER_VERSION_MM 2.14
ENV GEOSERVER_HOME /geoserver-${GEOSERVER_VERSION}
ENV GEOSERVER_DATA_DIR /var/geoserver/data

RUN mkdir -p ${GEOSERVER_HOME}
RUN mkdir -p ${GEOSERVER_DATA_DIR}


# Build image
FROM base AS build

RUN apk add --no-cache curl
RUN curl -OL https://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/geoserver-${GEOSERVER_VERSION}-bin.zip && \
    unzip geoserver-${GEOSERVER_VERSION}-bin.zip
RUN curl -OL https://build.geoserver.org/geoserver/${GEOSERVER_VERSION_MM}.x/community-latest/geoserver-${GEOSERVER_VERSION_MM}-SNAPSHOT-s3-geotiff-plugin.zip && \
    unzip -o -d ${GEOSERVER_HOME}/webapps/geoserver/WEB-INF/lib/ geoserver-${GEOSERVER_VERSION_MM}-SNAPSHOT-s3-geotiff-plugin.zip
RUN cd ${GEOSERVER_HOME}/data_dir/ && \
    rm -rf coverages/* data/* demo layergroups/* workspaces www
COPY data ${GEOSERVER_HOME}/data_dir/


# Run image
FROM base

RUN apk add --no-cache gettext ttf-dejavu
COPY --from=build ${GEOSERVER_HOME} ${GEOSERVER_HOME}
COPY entrypoint.sh /usr/local/bin/

ENV GEOSERVER_USER admin
ENV GEOSERVER_PASSWORD geoserver
ENV MINIO_URL http://minio:9000/
ENV MINIO_ALIAS minio
ENV MINIO_USER minio
ENV MINIO_PASSWORD miniopass

VOLUME ["${GEOSERVER_DATA_DIR}"]
EXPOSE 8080
ENTRYPOINT ["entrypoint.sh"]
CMD ["sh", "-c", "${GEOSERVER_HOME}/bin/startup.sh"]
