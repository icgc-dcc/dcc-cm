# ICGC DCC - Portal Demo


ICGC DCC Portal Demo is a docker container that allows to configure and run a standalone version of the [ICGC DCC Portal.](https://dcc.icgc.org/)

**NOTE:** A portal demo container should be used to demo purposes only and is not intended for production environments.

## Download

A portal demo container could be downloaded from the [Docker Hub](https://hub.docker.com/r/icgcdcc/dcc-portal-demo/).

Docker pull command:

```shell
docker pull icgcdcc/dcc-portal-demo
```

## Import data

Data which is required to power the portal is stored outside of the container making it reusable and reducing size of the container. The container expects that data directory is attached to the container as a volume to `/mnt/dcc_data` directory. Make sure it has enough hard drive space and the production dataset is quite large: 

 - DCC data release ~ 70GB
 - Elasticsearch indices ~ 40GB

 To download the production dataset, unpack it and load into an Elasticsearch engine use the following command:
 
```shell
docker run -v </path/to/mount/point>:/mnt/dcc_data -it --rm icgcdcc/dcc-portal-demo import
``` 

Once the data import is finished terminate the container.

#### Partial data import

Production dataset is quite large thus it might be problematic to run it in a single container. There is a possibility to load a single cancer project.

To load a single data project the following command could be used:

```shell
docker run -v </path/to/mount/point>:/mnt/dcc_data -it --rm icgcdcc/dcc-portal-demo import -p <project_name>
```
where `<project_name>` is a code name of the project to load. For example `PACA-CA`.

With this command a smaller amount of data will be downloaded and loaded into the Elasticsearch engine.

**Note:** Because of how the Elasticsearch index archive is created it is not possible to download only content related to the project requested. The whole index archive will be downloaded, however only documents required by the project will be actually indexed.

#### Manual data download

Sometime users might experience difficulties with data downloads because of various reasons. It is possible to manually download the required data and place it to appropriate location in the DCC data directory. After the data is downloaded it is possible to skip the download step during the data import process.

To download data manually following steps should be performed. Here we assume that the DCC data directory is located in `/mnt/dcc_data` directory.

 - create temporary download directory

```shell
mkdir /mnt/dcc_data/tmp
```
 - download the archives

```shell
wget --no-check-certificate -O /mnt/dcc_data/repository.tar.gz https://download.icgc.org/exports/repository.tar.gz
wget --no-check-certificate -O /mnt/dcc_data/data.open.tar https://download.icgc.org/exports/data.open.tar

# Or the following command instead of the previous one if only one project should be imported
wget --no-check-certificate -O /mnt/dcc_data/data.open.tar https://download.icgc.org/exports/data.open.tar?project=<project_code>
wget --no-check-certificate -O /mnt/dcc_data/release.tar https://download.icgc.org/exports/release.tar
```

**Note:** `wget` command does not recognize our SSL certificate as a valid one thus `--no-check-certificate` flag should be used.

After the data is downloaded use the `-s` flag with the `import` command to skip data download.

```shell
docker run -v </path/to/mount/point>:/mnt/dcc_data -it --rm icgcdcc/dcc-portal-demo import -s
```

or the next command in case of one project import

```shell
docker run -v </path/to/mount/point>:/mnt/dcc_data -it --rm icgcdcc/dcc-portal-demo import -p <project_name> -s
```

After the data is successfully imported it can be deleted from the `/mnt/dcc_data/tmp` directory.

Run
---

To start a container after the data import step has been successfully execute the following command should be used:

```shell
docker run -v </path/to/mount/point>:/mnt/dcc_data -p 8080:8080 -p 9090:9090 -it --rm icgcdcc/dcc-portal-demo start <public_ip_address_of_the_docker_host>
```
`<public_ip_address_of_the_docker_host>` should be replaced with IP or DNS name of the docker host so the DCC portal will be able to create valid redirect download URLs.

Wait until a line like the following appears in the portal log file `/opt/dcc/dcc-portal-server/logs/dcc-portal-server.log`, which indicates that the portal has successfully started.

```
o.i.d.p.s.ServerMain - Started ServerMain in 67.365 seconds (JVM running for 73.763)
```
