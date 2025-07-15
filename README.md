
# Docker 
## Pre-reqs
* [Install docker](https://docs.docker.com/engine/install/)
* [Run docker commands without `sudo`](https://docs.docker.com/engine/install/linux-postinstall/)
## Create data folders 
```bash
$ mkdir -p data lic
$ sudo chmod 777 -R data
```

## KX License
Copy obtained KX License into the `lic` folder. Further info here: https://code.kx.com/insights/core/qpacker/qpacker.html#licenses
<!-- install -D file.txt /path/to/non/existing/dir/file.txt  -->
```bash
$ cp /path/to/k[4,c,x].lic lic/
```

## Pre-requisites
Update docker/.env with your root directory for the repo

## Docker start
Log in to the [KX download portal](https://portal.dl.kx.com) and obtain a bearer token. 
```bash
$ docker login -u email -p token        ## enter obtained credentials
$ docker network create kx-net
To start the environment (within scripts directory)
$ ./startDocker.sh
These can be updated all at once or by category 
$ ./startDocker.sh framework 
This will deploy:
    - A portainer container to monitor containers 
    - Zookeeper to manage the kafka cluster
    - A kafka broker 
    - All Service components (GW,RC,AGG,KDBGW)
$ ./startDocker.sh bitmex 
$ ./startDocker.sh bitfinex 
These will deploy:
    - The SP to subscribe to the kafka feed and publish the raw data 
    - The RT to act as the message bus between the containers
    - The SP to generate orderbook updates
    - The SM & DAPS for the respective assembly
$ ./startDocker.sh feeds 
This will deploy:
    - The quote and trade feeds for both exchanges

To turn off the environment (within scripts directory)
$ ./stopDocker.sh
The same options are available from above to stop the required containers

```

## Dashboards 
A gateway process for dashboards is instantiated in the docker scripts at `5011, but the dashboards package will need to be downloaded and added to the directory
within the dashboards/ directory, a sample dashboard showing simple aggaregation can be found. Updates may need to be made to the connection handle 
If running locally
host: 127.0.0.1
port: 5011

## Adding Custom UDAs
In order to apply new UDAs, an example is provided within cfg/custom.api.q
After adding new analytics to this file, bounce the DA process in both docker assembly files to intialise the changes
