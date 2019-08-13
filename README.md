# HIS GeoServer

This GeoServer instance is based on a version used by Tethys Platform (https://github.com/tethysplatform/tethys_docker/tree/master/geoserver). It has been modified to extend HydroShare data service capabilities by reading data from HydroShare IRODS vaults. A prebuilt docker image is available on Docker Hub at https://cloud.docker.com/u/kjlippold/repository/docker/kjlippold/his_geoserver.

## Getting Started

These instructions will help you install and run this GeoServer instance in a production environment.

### Prerequisites

##### Docker:
* [Install Docker Engine](https://docs.docker.com/install/)

### Installing
Run GeoServer Docker instance:
```
$ sudo docker run -d -p {host_port}:8181 -v {host_data_vault}:/irods_vault:ro --name his_geoserver kjlippold/his_geoserver:latest
```

Enter the GeoServer container:
```
$ sudo docker exec -it his_geoserver /bin/bash
```

Give GeoServer IRODS Vault access:
```
$ usermod -u {host_privileged_user_id} gsapp
```

Allow anonymous REST GET access (necessary for some apps):
```
$ sudo vi /var/geoserver/data/security/rest.properties
```

Add the following lines to the file:
```
/**;GET=IS_AUTHENTICATED_ANONYMOUSLY
/**;POST,DELETE,PUT=ADMIN
```

Save and close the file:
```
:wq
```

Exit the container:
```
$ exit
```

Restart GeoServer:
```
$ sudo docker restart his_geoserver
```

The default username and password are admin, geoserver. From the admin page of GeoServer ({hostname}/geoserver/web/), change the admin password. Change the contact settings. Then add a Proxy Base URL to Global Settings. (e.g. https://geoserver.hydroshare.org/geoserver). Finally, remove existing workspaces and create a new default workspace called "hydroshare".

## Built With

* [Docker](https://docs.docker.com) - Docker Engine
* [Apache Tomcat](http://tomcat.apache.org) - Java Servlet Container
* [Oracle JRE](https://www.oracle.com/technetwork/java/javase/overview/index.html) - Java Runtime Environment
* [GeoServer](http://geoserver.org) - Geospatial Data Services

## License

This project is licensed under the MIT License - see the [LICENSE.txt](LICENSE.txt) file for details