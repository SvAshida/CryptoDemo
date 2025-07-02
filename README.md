
# Docker 
## Pre-reqs
* [Install docker](https://docs.docker.com/engine/install/)
* [Run docker commands without `sudo`](https://docs.docker.com/engine/install/linux-postinstall/)
## Create data folders 
```bash
$ mkdir -p data/sp/checkpoints tplog lic
$ sudo chmod 777 -R data tplog
```

## KX License
Copy obtained KX License into the `lic` folder. Further info here: https://code.kx.com/insights/core/qpacker/qpacker.html#licenses
<!-- install -D file.txt /path/to/non/existing/dir/file.txt  -->
```bash
$ cp /path/to/k[4,c,x].lic lic/
```

## Pre-requisites
Update .env with your root directory for the repo

## Docker start
Log in to the [KX download portal](https://portal.dl.kx.com) and obtain a bearer token. 
```bash
$ docker login -u email -p token        ## enter obtained credentials
To start the environment (within scripts directory)
$ ./startDocker.sh
To turn off the environment (within scripts directory)
$ ./stopDocker.sh
```

## Bitmex and Bitfinex Feeds
```bash
To start feeds (within the scripts directory)
$ ./startFeeds.sh
To stop feeds (within the scripts directory)
$ ./stopFeeds.sh
```
Logs for the feeds can be found within the logs directory

## Dashboards 
A gateway process for dashboards is instantiated in the docker scripts at `5011, but the dashboards package will need to be downloaded and added to the directory
