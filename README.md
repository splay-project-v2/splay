# SPLAY 
This is the official github repository of the Splay project.

## Overview
SPLAY simplifies the prototyping and development of large-scale distributed applications and overlay networks. SPLAY covers the complete chain of distributed system design, development and testing: from coding and local runs to controlled deployment, experiment control and monitoring.
SPLAY allows developers to specify their distributed applications in a concise way using a specialized language based on Lua, a highly-efficient embeddable scripting language. SPLAY applications execute in a safe environment with restricted access to local resources (file system, network, memory) and can be instantiated on a large variety of testbeds composed a large set of nodes with a single command.
SPLAY is the outcome of research and development activities at the [Computer Science Department](http://www2.unine.ch/iiun) of the University of Neuchatel.

## Getting started
The source code of SPLAY is available under the General Public License (GPLv3) and published through this repository.

The main research paper that describes SPLAY, evaluates its performances and presents several typical experiments has been published in the proceedings of the 6th USENIX Symposium on Networked Systems Design and Implementation (NSDI'09).

SplayNet implements topology emulation features for SPLAY. It has been published in the Proceedings of the 14th ACM/IFIP/USENIX International Middleware Conference (MIDDLEWARE'13). 

The SPLAY NSDI'09 paper is available as a [web page](https://www.usenix.org/legacy/event/nsdi09/tech/full_papers/leonini/leonini_html/) or as a [PDF](http://members.unine.ch/etienne.riviere/publications/LeoRivFel-NSDI-09.pdf).

The SplayNet MIDDLEWARE'13 is available as [PDF](http://members.unine.ch/valerio.schiavoni/publications/splaynet_middleware13.pdf).

# Update By Monroe Samuel && Voet Rémy (UCL)

- We have upgrade the version :
    - of ruby for splayweb and the controller from 1.8.6 to 2.5.1 .
    - of lua for the daemon and the rpc_client from 5.1 to 5.3 .
    - of rails for splayweb form 2.1.0 to 5.2.0

## Current Model

There 6 main parts : daemon, controller, Db (MySql5.5), cli_server, cli_client and splayweb.

![Schema of Splay](doc/schema.png)


## HOW TO LAUNCH

The 5 part are dockerized (need Docker), to build containers, run : `docker-compose build`
When build finish, you can launch every mandatory part :
```
docker-compose up -d cli_server
docker-compose up -d splayweb
```
Then you can launch some daemon which accept jobs later : `docker-compose scale daemon=5`

To submit job, you can use the splayweb (not finish) or use cli_client contenaire :
`docker run -it splay_terminal`
and you can now excecute some lua scripts on this terminal.

To tests the all stuff run `test_cyclon` (Will kill/remove all your docker images)

## Improve TODO



## Major change Idea