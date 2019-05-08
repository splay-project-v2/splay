# SPLAY v2

This is the official main github repository of the Splay project version 2. The version 1 (unstable) can be found [here](https://github.com/splay-project/splay).

## Overview

SPLAY simplifies the prototyping and development of large-scale distributed applications and overlay networks. SPLAY covers the complete chain of distributed system design, development and testing: from coding and local runs to controlled deployment, experiment control and monitoring.
SPLAY allows developers to specify their distributed applications in a concise way using a specialized language based on Lua, a highly-efficient embeddable scripting language. SPLAY applications execute in a safe environment with restricted access to local resources (file system, network, memory) and can be instantiated on a large variety of testbeds composed a large set of nodes with a single command.
SPLAY is the outcome of research and development activities at the [Computer Science Department](http://www2.unine.ch/iiun) of the University of Neuchatel.

## Getting started

The main research paper that describes SPLAY, evaluates its performances and presents several typical experiments has been published in the proceedings of the 6th USENIX Symposium on Networked Systems Design and Implementation (NSDI'09).

SplayNet implements topology emulation features for SPLAY. It has been published in the Proceedings of the 14th ACM/IFIP/USENIX International Middleware Conference (MIDDLEWARE'13).

The SPLAY NSDI'09 paper is available as a [web page](https://www.usenix.org/legacy/event/nsdi09/tech/full_papers/leonini/leonini_html/) or as a [PDF](http://members.unine.ch/etienne.riviere/publications/LeoRivFel-NSDI-09.pdf).

The SplayNet MIDDLEWARE'13 is available as [PDF](http://members.unine.ch/valerio.schiavoni/publications/splaynet_middleware13.pdf).

A more recent version of SPLAY (Version 2) has been written with new technologies or more recent version. Also, the structure has been simplified and improved. Check the [docs](docs) to be more information 

### Architecture V2

![Schema of Splay](doc/final_report/figures/new_arch.png)

## HOW TO

First, this repository uses git submodules, then to get all sources, you need to launch `git submodule update --init --recursive` or when cloning `git clone --recurse-submodules`.

The 5 part are dockerized (need Docker and docker-compose), to build containers, run : `docker-compose build`
When build finish, you can launch the docker individually or with these 2 commands line :

```bash
docker-compose up -d web_app controller
docker-compose up -d --scale daemon=5
```

You can now access to the [web](https://github.com/splay-project-v2/web_app) application with the url [localhost:8080](localhost:8080). With this app you can submit for testing your distributed algorithm and check the result of these by the logs (available either on the web app or via daemon dockern services). 

The second way to use SPLAY is throut the [cli](https://github.com/splay-project-v2/cli) service, check the integration test scripts to get more info.

## Testing 

There are some integrations testing (need bash or similar) to see if the installation is correct (tested with Ubuntu 18.10 and MacOS).
Launch this command line in the main directory `bash integration_tests/all_tests.sh` (can take some times if you haven't build yet the docker images). 

Don't forget to clean your docker services/images after (with clean-all-dockers script by example)

Also there are some individual tests for some part/services of splay (daemon and backend mainly). Check the correspond repositories for more details.

## Timeline of the project

### Version 1

Check old repository, [here](https://github.com/splay-project/splay).

### Student Job (by Monroe Samuel && Voet Rémy (UCL))

- We have upgrade the version of languages and packages :
  - of ruby for splayweb and the controller from 1.8.6 to 2.5.3 .
  - of lua for the daemon and the rpc_client from 5.1 to 5.3 .
  - of rails for splayweb form 2.1.0 to 5.2.0

#### Improve TODO

- Allow job creation on SplayWeb : SplayWeb doesn't implement all the features present on the old website.
- CSS and JavaScript on SplayWeb.
- Some useful changes might have been done on the Splayd Controller, and weren't applied on our rework and update as we started everything again from some last commit in 2011. Therefore, some things might be missing and we encounter now and then little bugs such as a Daemon being refused by the Controller.
- Unify the user management, the way it is done now isn't very secure and really cumbersome to work with in Rails. (see Devise)

#### Major change Idea

During our rework on the whole Splay project, we thought about what was pleasant
and what was more unpleasant to us, and therefore imagined some ways
to transform this project using different architecture or technologies.

#### Lessen the DB usage

The fact that the DB is used as the main communication component feels
wrong, the Controller polling constantly the DB with `SELECT` on the
job table appear to us like something that shouldn't be done.

Maybe the CLIServer and SplayWeb should talk directly with the Controller
instead of just writing things on it. Of course it might still use the
DB for data retrieving.

#### Merge cli_server and splayweb

The SplayWeb is in fact redoing exactly what CLIServer is offering to CLIClient,
unifying the two of them by providing a JSON API within SplayWeb, besides the
front-end application, would avoid code duplication and centralize the logic.

### Master Thesis (by Monroe Samuel && Voet Rémy (UCL)) - Splay V2

Check the [docs](docs). 

## Authors

Original project:
- Pascal Felber
- Lorenzo Leonini (original author)
- Etienne Riviere
- Valerio Schiavoni
- José Valerio

Version 2 of SPLAY:
- Monroe Samuel
- Voet Rémy

## LICENSE

The source code of SPLAY is available under the General Public License (GPLv3) and published through this repository and the submodules of this.

