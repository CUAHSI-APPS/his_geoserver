# GeoServer 2.14.1
# Oracle JRE 1.8
# Tomcat 7


FROM ubuntu:18.04


MAINTAINER Kenneth Lippold kjlippold@gmail.com


# Create gsapp user ----------------------------------------------------------------------------------------#

RUN useradd gsapp
RUN usermod -u 1111 gsapp


# Apt setup ----------------------------------------------------------------------------------------------#

RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y wget sudo ssh unzip vim
RUN apt-get install -y software-properties-common
RUN apt-get install -y python-pip python-dev nginx supervisor
RUN apt-get install -y acl


# Install Java -------------------------------------------------------------------------------------------#

RUN apt-get install -y openjdk-8-jdk

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64


# Install JAI and JAI Image I/O --------------------------------------------------------------------------#

WORKDIR /tmp
RUN wget http://download.java.net/media/jai/builds/release/1_1_3/jai-1_1_3-lib-linux-amd64.tar.gz && \
    wget http://download.java.net/media/jai-imageio/builds/release/1.1/jai_imageio-1_1-lib-linux-amd64.tar.gz && \
    gunzip -c jai-1_1_3-lib-linux-amd64.tar.gz | tar xf - && \
    gunzip -c jai_imageio-1_1-lib-linux-amd64.tar.gz | tar xf - && \
    mv /tmp/jai-1_1_3/COPYRIGHT-jai.txt $JAVA_HOME/jre && \
    mv /tmp/jai-1_1_3/UNINSTALL-jai $JAVA_HOME/jre && \
    mv /tmp/jai-1_1_3/LICENSE-jai.txt $JAVA_HOME/jre && \
    mv /tmp/jai-1_1_3/DISTRIBUTIONREADME-jai.txt $JAVA_HOME/jre && \
    mv /tmp/jai-1_1_3/THIRDPARTYLICENSEREADME-jai.txt $JAVA_HOME/jre && \
    mv /tmp/jai-1_1_3/lib/jai_core.jar $JAVA_HOME/jre/lib/ext/ && \
    mv /tmp/jai-1_1_3/lib/jai_codec.jar $JAVA_HOME/jre/lib/ext/ && \
    mv /tmp/jai-1_1_3/lib/mlibwrapper_jai.jar $JAVA_HOME/jre/lib/ext/ && \
    mv /tmp/jai-1_1_3/lib/libmlib_jai.so $JAVA_HOME/jre/lib/amd64/ && \
    mv /tmp/jai_imageio-1_1/COPYRIGHT-jai_imageio.txt $JAVA_HOME/jre && \
    mv /tmp/jai_imageio-1_1/UNINSTALL-jai_imageio $JAVA_HOME/jre && \
    mv /tmp/jai_imageio-1_1/LICENSE-jai_imageio.txt $JAVA_HOME/jre && \
    mv /tmp/jai_imageio-1_1/DISTRIBUTIONREADME-jai_imageio.txt $JAVA_HOME/jre && \
    mv /tmp/jai_imageio-1_1/THIRDPARTYLICENSEREADME-jai_imageio.txt $JAVA_HOME/jre && \
    mv /tmp/jai_imageio-1_1/lib/jai_imageio.jar $JAVA_HOME/jre/lib/ext/ && \
    mv /tmp/jai_imageio-1_1/lib/clibwrapper_jiio.jar $JAVA_HOME/jre/lib/ext/ && \
    mv /tmp/jai_imageio-1_1/lib/libclib_jiio.so $JAVA_HOME/jre/lib/amd64/ && \
    rm /tmp/jai-1_1_3-lib-linux-amd64.tar.gz && \
    rm -r /tmp/jai-1_1_3 && \
    rm /tmp/jai_imageio-1_1-lib-linux-amd64.tar.gz && \
    rm -r /tmp/jai_imageio-1_1


# Install the Unlimited Strength Jurisdiction Policy files -----------------------------------------------#

COPY java-policy-files/local_policy.jar $JAVA_HOME/jre/lib/security/local_policy.jar
COPY java-policy-files/US_export_policy.jar $JAVA_HOME/jre/lib/security/US_export_policy.jar


# Setup Tomcat, GeoServer Cluster, and NGINX Load Balance ------------------------------------------------#

ENV GEOSERVER_HOME /var/geoserver
ENV CATALINA_HOME /var/tomcat
ENV GEOSERVER_DATA_DIR /var/geoserver/data
ENV MAX_NODES 4
ENV ENABLED_NODES 1
ENV REST_NODES 1
ENV MAX_MEMORY 1024
ENV MIN_MEMORY 1024
ENV GDAL_DATA /usr/local/lib/gdal-data
ENV LD_LIBRARY_PATH /usr/local/lib
ENV GDAL_SKIP JP2ECW

COPY apache-files/apache-tomcat-7.tar.gz /tmp/
COPY geoserver* /tmp/
COPY generated/* /tmp/

RUN pip install --upgrade pip && \
    hash -r pip && \
    pip install -r requirements.txt && \
    rm requirements.txt && \
    tar zxf apache-tomcat-7.tar.gz && \
    mv apache-tomcat-7.0.68 $CATALINA_HOME && \
    rm apache-tomcat-7.tar.gz && \
    mkdir -p $GEOSERVER_HOME/data/ && \
    mkdir -p $GEOSERVER_HOME/tmp_data/ && \
    mkdir -p $GEOSERVER_HOME/node/ && \
    mkdir -p $GEOSERVER_HOME/node/conf/ && \
    mkdir -p $GEOSERVER_HOME/node/logs/ && \
    mkdir -p $GEOSERVER_HOME/node/temp/ && \
    mkdir -p $GEOSERVER_HOME/node/work/ && \
    mkdir -p $GEOSERVER_HOME/node/webapps/geoserver && \
    cp $CATALINA_HOME/conf/web.xml $GEOSERVER_HOME/node/conf/ && \
    mv geoserver.war $GEOSERVER_HOME/node/webapps/geoserver/ && \
    cd $GEOSERVER_HOME/node/webapps/geoserver && \
    jar -xvf geoserver.war && \
    rm geoserver.war && \
    cd /tmp && \
    cp gs-css-styling-plugin-2.14.1/gs-css-styling-plugin-2.14.1.zip $GEOSERVER_HOME/node/webapps/geoserver/WEB-INF/lib && \
    cp gs-control-flow-plugin-2.14.1/gs-control-flow-plugin-2.14.1.zip $GEOSERVER_HOME/node/webapps/geoserver/WEB-INF/lib && \
    cp gs-gdal-plugin-2.14.1/gs-gdal-plugin-2.14.1.zip $GEOSERVER_HOME/node/webapps/geoserver/WEB-INF/lib && \
    cp gs-image-pyramid-plugin-20.1/gs-image-pyramid-plugin-20.1.zip $GEOSERVER_HOME/node/webapps/geoserver/WEB-INF/lib && \
    ls && \
    cp gs-jms-cluster-plugin-2.14.1/gs-jms-cluster-plugin-2.14.1.zip $GEOSERVER_HOME/node/webapps/geoserver/WEB-INF/lib && \
    cp gs-netcdf-plugin-2.14.1/gs-netcdf-plugin-2.14.1.zip $GEOSERVER_HOME/node/webapps/geoserver/WEB-INF/lib && \
    cp gs-netcdf-out-plugin-2.14.1/gs-netcdf-out-plugin-2.14.1.zip $GEOSERVER_HOME/node/webapps/geoserver/WEB-INF/lib && \
    mv geoserver-gdal192-Ubuntu12-gcc4.6.3-x86_64.tar.gz /usr/local/lib && \
    mv geoserver-gdal-data.zip /usr/local/lib && \
    cd $GEOSERVER_HOME/node/webapps/geoserver/WEB-INF/lib && \
    unzip -o gs-css-styling-plugin-2.14.1.zip && \
    unzip -o gs-control-flow-plugin-2.14.1.zip && \
    unzip -o gs-gdal-plugin-2.14.1.zip && \
    unzip -o gs-image-pyramid-plugin-20.1.zip && \
    unzip -o gs-jms-cluster-plugin-2.14.1.zip && \
    unzip -o gs-netcdf-plugin-2.14.1.zip && \
    unzip -o gs-netcdf-out-plugin-2.14.1.zip && \
    rm gs-css-styling-plugin-2.14.1.zip && \
    rm gs-control-flow-plugin-2.14.1.zip && \
    rm gs-gdal-plugin-2.14.1.zip && \
    rm gs-image-pyramid-plugin-20.1.zip && \
    rm gs-jms-cluster-plugin-2.14.1.zip && \
    rm gs-netcdf-plugin-2.14.1.zip && \
    rm gs-netcdf-out-plugin-2.14.1.zip && \
    cd /usr/local/lib && \
    unzip -o geoserver-gdal-data.zip && \
    tar xf geoserver-gdal192-Ubuntu12-gcc4.6.3-x86_64.tar.gz && \
    rm geoserver-gdal-data.zip && \
    rm geoserver-gdal192-Ubuntu12-gcc4.6.3-x86_64.tar.gz && \
    cd /tmp && \
    mv $GEOSERVER_HOME/node/webapps/geoserver/data/* $GEOSERVER_HOME/tmp_data/ && \
    python gen_build_time_dynamic_files.py && \
    rm -rf $GEOSERVER_HOME/node && \
    rm template_catalina.sh && \
    rm template_server.xml && \
    rm template_web.xml && \
    rm gen_build_time_dynamic_files.py

WORKDIR $GEOSERVER_HOME


# Add startup script -------------------------------------------------------------------------------------#

COPY startup.sh $GEOSERVER_HOME/
RUN chmod +x $GEOSERVER_HOME/startup.sh


# Expose Ports -------------------------------------------------------------------------------------------#

EXPOSE 8181 8081 8082 8083 8084


# Add VOLUMEs to for inspection, datastorage, and backup -------------------------------------------------#

VOLUME  ["/var/log/supervisor", "/var/geoserver/data", "/var/geoserver", "/etc"]


# Startup ------------------------------------------------------------------------------------------------#

CMD $GEOSERVER_HOME/startup.sh
