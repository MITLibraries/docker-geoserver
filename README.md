
# MIT Libraries GeoServer

This container is used as the GeoServer instance for [GeoWeb](https://github.com/MITLibraries/geoweb). It adds support for the S3 GeoTiff community plugin.

## Running the Container

Start the container with:

    $ docker run -p 8080:8080 mitlibraries/geoserver

By default the username is `admin` and the password is `geoserver`, but both of these can be set at runtime by using environment variables:

    $ docker run -e GEOSERVER_USER=myuser -e GEOSERVER_PASSWORD=mypassword -p 8080:8080 mitlibraries/geoserver

## Using with Minio

This container supports serving GeoTiffs from S3. You can also use [Minio](https://github.com/minio/minio) as a drop-in replacement for (or in addition) to S3. There are four environment variables used to configure Minio support that can be set at runtime:

envvar | default value | description
--- | --- | ---
`MINIO_URL` | `http://minio:9000/` | URL for the Minio server
`MINIO_ALIAS` | `minio` | This is used when adding an S3 GeoTiff coverage store as the protocol, for example `minio://mybucket/someraster.tiff`
`MINIO_USER` | `minio` | username
`MINIO_PASSWORD` | `miniopass` | password

In order to enable Minio support the GeoServer container needs to be configured to use the S3 settings:

    $ docker run -e JAVA_OPTS="-Ds3.properties.location=/var/geoserver/data/s3.properties" -p 8080:8080 mitlibraries/geoserver
