#!/bin/sh
echo "Welcome to GeoServer $GEOSERVER_VERSION"


## install release data directory if needed before starting tomcat
if [ ! -f "$GEOSERVER_REQUIRE_FILE" ]; then
    echo "Initialize $GEOSERVER_DATA_DIR from data directory included in geoserver.war"
    cp -r $CATALINA_HOME/webapps/geoserver/data/* $GEOSERVER_DATA_DIR
fi

## Update GeoServer data directory
echo "Configure $GEOSERVER_DATA_DIR with custom GeoWeb configuration"
cp -r $ADDITIONAL_DATA_DIR/* $GEOSERVER_DATA_DIR
/usr/bin/chmod 0640 $GEOSERVER_DATA_DIR/security/usergroup/default/*.xml
rm -rf $GEOSERVER_DATA_DIR/demo/* && \
  rm -rf $GEOSERVER_DATA_DIR/workspaces/* && \
  rm -rf $GEOSERVER_DATA_DIR/www/* && \
  rm -rf $GEOSERVER_DATA_DIR/coverages/* && \
  rm -rf $GEOSERVER_DATA_DIR/data/* && \
  rm -rf $GEOSERVER_DATA_DIR/layergroups/* && \
  rm -rf $GEOSERVER_DATA_DIR/gwx-layers/*

## install GeoServer extensions before starting the tomcat
/opt/install-extensions.sh

# copy additional geoserver libs before starting the tomcat
# we also count whether at least one file with the extensions exists
count=`ls -1 $ADDITIONAL_LIBS_DIR/*.jar 2>/dev/null | wc -l`
if [ -d "$ADDITIONAL_LIBS_DIR" ] && [ $count != 0 ]; then
    cp $ADDITIONAL_LIBS_DIR/*.jar $CATALINA_HOME/webapps/geoserver/WEB-INF/lib/
fi

# copy additional fonts before starting the tomcat
# we also count whether at least one file with the fonts exists
count=`ls -1 *.ttf 2>/dev/null | wc -l`
if [ -d "$ADDITIONAL_FONTS_DIR" ] && [ $count != 0 ]; then
    cp $ADDITIONAL_FONTS_DIR/*.ttf /usr/share/fonts/truetype/
fi

# configure CORS (inspired by https://github.com/oscarfonts/docker-geoserver)
# if enabled, this will add the filter definitions
# to the end of the web.xml
# (this will only happen if our filter has not yet been added before)
if [ "${CORS_ENABLED}" = "true" ]; then
  if ! grep -q DockerGeoServerCorsFilter "$CATALINA_HOME/webapps/geoserver/WEB-INF/web.xml"; then
    echo "Enable CORS for $CATALINA_HOME/webapps/geoserver/WEB-INF/web.xml"
    sed -i "\:</web-app>:i\\
    <filter>\n\
      <filter-name>DockerGeoServerCorsFilter</filter-name>\n\
      <filter-class>org.apache.catalina.filters.CorsFilter</filter-class>\n\
      <init-param>\n\
          <param-name>cors.allowed.origins</param-name>\n\
          <param-value>${CORS_ALLOWED_ORIGINS}</param-value>\n\
      </init-param>\n\
      <init-param>\n\
          <param-name>cors.allowed.methods</param-name>\n\
          <param-value>${CORS_ALLOWED_METHODS}</param-value>\n\
      </init-param>\n\
      <init-param>\n\
        <param-name>cors.allowed.headers</param-name>\n\
        <param-value>${CORS_ALLOWED_HEADERS}</param-value>\n\
      </init-param>\n\
    </filter>\n\
    <filter-mapping>\n\
      <filter-name>DockerGeoServerCorsFilter</filter-name>\n\
      <url-pattern>/*</url-pattern>\n\
    </filter-mapping>" "$CATALINA_HOME/webapps/geoserver/WEB-INF/web.xml";
  fi
fi

# start the tomcat
$CATALINA_HOME/bin/catalina.sh run
