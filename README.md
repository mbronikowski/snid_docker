# SNID Docker

Another Docker wrapper for the [SuperNova IDentification](https://people.lam.fr/blondin.stephane/software/snid/) package by Stephane Blondin, inspired by [Robert Fisher's repository of the same name](https://github.com/rtfisher/snid_docker). This version aims to be as seamless in use as possible once set up, primarily by not moving the workflow into the container interactively. 

By default, the Dockerfile will build an image with [Super-SNID Templates](https://github.com/dkjmagill/QUB-SNID-Templates). If you would like to build with other templates instead, some adjustments will be necessary.

# Instructions

## Requirements

SNID Docker requires Docker and a working X11 client to run. We provide for Linux on AMD64/X86-64 architecture CPUs and MacOS devices with either Intel or Apple Silicon CPUs. 

For **Windows 10 and 11**, we recommend installing WSL and [running Docker from WSL](https://docs.docker.com/desktop/features/wsl/). Recent WSL builds [natively support X11 applications](https://learn.microsoft.com/en-us/windows/wsl/tutorials/gui-apps), so the installation instructions should be identical to following instructions for Linux from within WSL. However, this is untested by the authors.

1. **Docker**
Download and install [Docker](https://docs.docker.com/get-started/get-docker/). 

On **Linux**, you will also need to add your user to the docker group:
```sudo usermod -aG docker $USER```
After that, you will need to **completely log out and log back in, or reboot your machine**.

On shared computing resources, [rootless Docker](https://docs.docker.com/engine/security/rootless/), or containerization solutions, such as [Podman](https://podman.io/), will be required. Please follow the corresponding installation instructions for those. If using such solutions, you may need to adjust the contents of ```run_snid.sh``` to invoke the correct containerization platform.

2. **X server** 
 - Linux: Nearly all typical Linux distributions support X11 out of the box. If yours does not, contact your administrator.
 - MacOS: Download and install [XQuartz](https://www.xquartz.org). You will need to **completely reboot after installation before proceeding.**

## Installation

Download this repository with

```git clone https://github.com/mbronikowski/snid_docker```

and ```cd``` into the directory. On **AMD64/X86-64 processors** (Linux, Windows+WSL, older Apple computers), run:

```docker buildx build --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g) -t snid:5.0-supersnid --load .```

On newer **Apple Silicon** (M1, M2, M3 etc.) processors, instead run:

```docker buildx build --platform linux/amd64 --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g) -t snid:5.0-supersnid --load .```

Finally, just copy ```run_snid.sh``` into a directory listed in your $PATH or create an alias to it. Feel free to rename the script.

## Running and usage

The wrapper script should behave like a drop-in replacement for SNID, and work through ```/path/to/wrapper/run_snid.sh lightcurve.dat```, or if added to your ```$PATH```, through ```run_snid.sh lightcurve.dat```. All input options will be forwarded to SNID as provided, with one limitation listed below.

## Known limitations

Presently, the wrappers only permit running SNID in the current work directory, or its subfolders, **only with relative paths**. That is, ```run_snid.sh path/to/lightcurve1.dat path/to/lightcurve2.dat``` will work, but ```run_snid.sh /absolute/path/to/lightcurve.dat``` or ```run_snid.sh ../lightcurve.dat``` **will not**. 

The project was only tested on Linux for now.

# Attribution

The Dockerfile and wrapper scripts are published under a GPL 3.0 license, see LICENSE. The Dockerfile downloads GPL 3.0-licensed files for [SNID](https://people.lam.fr/blondin.stephane/software/snid/) and CC0 1.0 licensed files for [Super-SNID Templates](https://github.com/dkjmagill/QUB-SNID-Templates).

When using this code, please make sure to attribute these respective authors. We do not distribute their code or data products directly, and do not claim to be affiliated with them.
