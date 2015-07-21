
GeoServer
=========

Start with persistent storage:

    $ docker run --name geo-data -d mitlibraries/geoserver /bin/true
    $ docker run --name geoserver -d --volumes-from geo-data mitlibraries/geoserver
