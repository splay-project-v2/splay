# Documentation of splay

## User documentation

You can find the user documentation on the old website project (need to be updated)

## Technical Documentation

### Previous version

The previous version of splay (v1.5) was unstable in the github repository, then the first thing to do was to stabilisase and clean the all project : 

- First, we create a organitaion on github with 6 repository (one is the main and the other correspond to each service)
- Secondly some service was duplicate (rails app and the cli_server) but didn't share the code, then we decide to merge the backend rails logical and the cli_server to build a single backend service (Json API) and recreacte a modern web interface interacted with it (previously in views rails). For more explination see the basic report and look on the old and new schemas of the project.
- In the same time, we works on the stability of the controller and try to not lose any value works (SplayNet by example). 
- Also, a big work has been done to clean all codes (for controller, the command line interface and little bit the daemon). For the controller, we used rubocop to help with bad indent (tab - not aligned) and also removed old useless comment, forget code, ... 
- TODO : Automatic testing (feature testing) with command line interface and also some units test on each services.

### New Features

Some new features has been intregrated into splay to create the version 2 of splay : 

- The new modern single page app (VueJs) with lot of new features (TODO : topo, lua editor, etc).
- A Clean Json API (backend)
- TODO : crash point, etc

### Technology used

