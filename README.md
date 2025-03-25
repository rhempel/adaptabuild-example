## What is `adaptabuild`?

The `adaptabuild` system is really three components that work together
to make setting up an Embedded Systems Development environment much less
complex, no matter which OS your host computer runs - Linux, Windows,
or MacOS.

The three components are:

1. A Docker/Podman image (~2.2 GB) based on Ubuntu:22.04-LTS that has
   everything needed to develop, test, debug, and document an ARM Cortex
   project from the Linux command line.

2. A VSCode Devcontainer that is build from the Docker/Podman image
   that has all the plugins needed to develop, test, debug, and
   document an ARM Cortex project. That means VSCode *is* the
   IDE - you can single step your code, look at MCU registers,
   read/write memory, etc.

3. An optional build system based on `make` that lets you focus on
   your project, not learn yet another new and more complex build
   system. You can still choose to use `cmake`, `meson`, `Zephyr` or
   any other tools to build your project.

## Why You Might Consider Using `adaptabuild`

The `adaptabuild` system is designed with one thing in mind. Simplifying
the lives of embedded systems developers. We do this by minimizing the
number of manual steps required to get started, and by allowing developers
to customize their devcontainers as needed to suit their workflow.

You and your team can work in a standardized environment that you have
complete control over - no more wasting time figuring out why the build
fails on Evan's machine and works on Rebecca's.

When you check your work in to `git`, the *same* Docker/Podman base image
can be used to build your project using whatever pipeline manager your
CI system uses.

The source for the Docker image and VSCode devcontainer are freely available
so you can tune the contents if necessary. "Infrastructure as code" is one
of the North Star design goals for this project. Nobody wants to spend time
hand-tweaking development environments, but you do have that option if you
need it.

## Who Is This Guide For?

This guide assumes that you are either already an embedded systems
developer, or a learner that has at least some programming experience
with an IDE. This is not a step-by-step guide for learning embedded
systems programming, or a tutorial on how to use the debugger in
VSCode, or how to use Docker.

There are two reasons for this. First, any instructions or screenshots
can become outdated quickly, so I'm pointing at official install pages
for third party code. Second, it's very difficult to make a guide that
is both broad enough and deep enough - so I'm shooting for the middle and
assuming that you have the ability to fill in the gaps.

If you are willing to invest about 30 minutes in trying `adaptabuild` I would
be happy to have any feedback on potential improvements or success stories
you are able to share. Open an issue on this project page and I'll do
my best to answer.

## Currently Supported Boards and Host Debuggers

| Board       | st-link | OpenOCD | Segger |
| ----------- | ------- | ------- | ------ |
| STM32G031xx |   yes   |         |        |
| STM32F051R8 |   yes   |         |        |
| STM32H7A3ZI |   yes   |         |        |
| STM32L452RE |   yes   |         |        |
| pico2040    |         |  yes    |        |
| nRF52832    |         |  yes    |        |

## Installation Process

You will need to perform 4 tasks (details in the next section) to get started:

1. Install the prerequisite software packages (Docker Desktop, VSCode, git)
1. Clone one `git` repository containing the Docker base image creator and 
   the Devcontainer creator
2. Build the Docker base image (one command line and a 5-10 minute wait)
3. Build the VSCode Devcontainer (open a folder and a 3-5 minute wait)

Once that's done, the devcontainer post-build script will automagically
clone *this* repository and you will be ready to debug an example program.

### Install Prerequisite Software

> [!TIP]
> Users behind a corporate firewall *may* need to temporarily turn
> off the firewall to complete the setup of the Docker base image and
> the VSCode devcontainer. 

No matter which operating system you do your work on, you will need to
have the following programs installed on your system. I won't go into the
install details - please follow the directions on the install page for
each product.

#### Docker

Follow the links below to the official Docker Desktop installation guide for
your operating system. Stick with any defaults the installer offers.

- [Install Docker Desktop for Windows][Docker Install Windows]
- [Install Docker Desktop for MacOS][Docker Install MacOS]
  
Linux users should install the `docker` package for your distro. Using
Docker Desktop on Linux actually adds *another* Linux VM instead of
using the underlying support that your Linux machine already gives you.

If you insist on using Docker Desktop on Linux ...

- [Install Docker Dektop for Linux][Docker Install Linux] - Read the Important Info!

#### Microsoft VSCode

Follow the links below to the offical Microsoft VSCode installation guide
for your operating system. Stick with any defaults the installer offers.

- [Install VSCode for Windows, MacOS, Linux][Install VSCode]
- [Install the official Docker plugin for VSCode][Install Docker Plugin]

You don't need to install any additional VSCode plugins on your host operating
system - the `.devcontainer` file will install them *in the container* without
changing your host VSCode setup.

#### `git`

Follow the links below to the official `git` installation guide for
your operating system. Stick with any defaults the installer offers.

- [Install Docker Desktop for Windows][Docker Install Windows]
- [Install Docker Desktop for MacOS][Docker Install MacOS]
  
Linux users should install the `git` package for your distro - it's
probbaly alerady installed.

### Clone the `docker-devcontiners` Repository

Using the git command line (or whatever GUI you choose), clone the following
repository to wherever you do your work:

#### Windows users (CMD or Powershell):

```cmd
cd some\path
git clone https://github.com/rhempel/docker-devcontainers.git
```

#### Linux or MacOS users:

```bash
cd some/path
git clone https://github.com/rhempel/docker-devcontainers.git
```

This repository has one folder for the Docker Base Images - there is
a [README.md with more details][Docker Base Images] on the design choices
if you are interested in learning more.

There are also one or more folders for devcontainers that can be
build from the Docker Base Images.

### Build the Ubuntu:22.04 Docker Base Image

Building the Docker base image is best done from the command line. You don't
need to be in any particular directory for this to work. The process takes
about 5 minutes on a typical development machine with a 50 Mbps internet
connection.

The path in the command line is the one where you cloned the `docker-devcontainers`
repository.

#### Windows users (CMD or Powershell):

```cmd
docker buildx build -t ubuntu-embedded:22.04 some\path\docker-devcontainers\docker-base-images\ubuntu-22.04-embedded
```

#### Linux or MacOS users:

```bash
docker buildx build -t ubuntu-embedded:22.04 some/path/docker-devcontainers/docker-base-images/ubuntu-22.04-embedded
```

This creates a Docker base image called `ubuntu-embedded:22.04`. Verify that the
base image was created by checking for an image called "ubuntu-embedded" with a
tag of "22.04" in Docker Desktop.

You can also use the command line (it's the same no matter which OS you use):

```bash
docker image list ubuntu-embedded
```

... producing something like this:

```
REPOSITORY        TAG       IMAGE ID       CREATED      SIZE
ubuntu-embedded   22.04     3107d190a49b   6 days ago   2.24GB
```

The image name and tag are used in the next step to select the correct base
image. You can add more tags if your workflow needs it, but don't
change this one.

> [!NOTE]
> Additional tags referring to the same image hash don't take up additional
> space - think of them as extra handles on the same object.

### Build the VSCode Devcontainer

> [!TIP]
> Users behind a corporate firewall *may* need to temporarily turn
> off the firewall to complete the setup of the VSCode devcontainer. 

This part is the same no matter which operating system you use - as long as your
installation of VSCode eabled opening folders with VSCode (which is the default)

1. Use your folder browser to navigate to where you cloned the `docker-devcontainers` repository
2. Right-click on the `adaptabuild-example-22.04` folder
3. Open using `VSCode` - wait for the Devcontainer dialog in the lower
   right and click "Reopen in Container" button

This should launch the VSCode application, which recognizes the `.devcontainer` folder
and begins the process of creating a devcontiner for automatically. This takes
about 5 minutes and uses the Docker base image from the previous step.

> [!NOTE]
> There are things that happen automatically when building the devcontainer - they
> are listed below.
> 
> 1. A Docker volume called `adaptabuild-volume` is created (if it does not already
>    exist) and it is mounted to the `~/projects` folder in your devcontainer.
> 2. Your local user's `.ssh` directory is mounted to the `~/.ssh` folder in your
>    devcontainer - and it gets the correct privileges.
> 3. Your local user's `.gitconfig` is combined with the devcontiner's `.gitconfig`
>    so that your host PC Git configuration travels with you to the devcontainer.
> 4. The post-build process will clone the `adaptabuild-example` project for you
>    and place it in `~/projects/adaptabuild-example`
> 5. Every time you launch the devcontainer, the latest updates are `git fetch`ed
>    from the `adaptabuild` project.

## Start Developing!

> [!NOTE]
> The first time you build the devcontainer, the `adapatabuild-volume` is created
> and the `adaptabuild-example` repo is cloned. After that we initialize all of
> the submodules, and this can take a few minutes to complete.
> 
> Every time you attach to the container after that, the latest commits are
> automatically fetched from the `adaptabuild-example` repository.

### Building firmware images and documentation

The `adaptabuild-example\.vscode\tasks.json` file has a few pre-defined tasks
that you can run to get you started:

- Terminal / Run Task / Clean All - Cleans all the build artifacts
- Terminal / Run Task / Build All - Cuilds all the targets in parallel
- Terminal / Run Task / Build xxx - Builds the xxx target
- Terminal / Run Task / Build adaptabuild doc - does what it says

## Debugging your application

The `adaptabuild-example\.vscode\launch.json` file has a few pre-defined debug launch
configurations. The ones we have tested most are for the STM32 Nucleo style
development boards.

> [!NOTE]
> Rather than get into a very complex procedure for passing the host USB adapter
> up to the devcontainer, we will instead take advantage of the fact that
> most debuggers support a GDB style stup and open up a network socket.
>
> The magic piece of `adaptabuild` is using that fact and greatly simplifying
> the connection process.
>
> For this guide, we assume you have plugged in one of the supported boards
> and `st-util` on the host. The command console should have indicated that your
> ST Nucleo or similar board has been detected and the debugger is listenting
> on port `4242`.
>
> I would be happy to add any additional launch configurations - I may ask
> for a board to be donated for testing.

To start debugging, just click on the VSCode Debug menu on the left, and choose
the launch confiuguration you are using. Then hit the green triangle. You should
see a dummy program `foo.c` come up in VSCode and then you can start stepping
through the code.

Yes, it's that easy! Remember, if you have any questions or suggestions for
improvements then [open an issue in this repo][Open An Issue].

## Common Problems

### The VSCode Plugins Don't Install

If your managed PC has a firewall or VPN configured, sometimes this interferes
with certificate retreival. Contact your system administrator and follow their
guidance on *temporarily* disabling whatever is blocking the certificate retreival.

Shut down the VSCode session, and navigate to the `adaptabuild-example-22.04` folder.

> [!NOTE]
> Delete (carefully) the `.vscode-server` folder.
>
> DO NOT delete the `.vscode` folder. If you do, you can `git restore` the folder

Now right-click on the `adaptabuild-example-22.04` folder in VSCode, wait for
the "DevContainers" dialog and click the "Reopen in Container" buttoin.

### `.ssh` Credential Permissions

The `.devcontainer` file defines how the Docker container is integrated with
VSCode. To make the experience as seamless as possible, we mount your `$HOME/.ssh`
folder in the container at `~/.ssh` automatically. This saves you the step of copying your
credentials all over the place.

However, the Linux `ssh` system is picky about file permisisons on your `~/.ssh`
and helpfully does nothing and gives you a warning if they are set up insecurely.

If the clone of the `adaptabuild-example` repo fails, check your permissions once it is
mounted. They should look like this:

```
foo@7e96091a1815:~/projects/adaptabuld-example$ ls -al ~/.ssh
total 32
drwx------ 1 foo  foo   512 Jun 27 14:50 .
drwxrwxrwx 1 root root  512 Jun 28 12:52 ..
-rw------- 1 foo  foo  1727 Nov 22  2023 config
-rw------- 1 foo  foo  3381 May 31  2023 xxx_rsa
-rw-r--r-- 1 foo  foo   744 May 31  2023 xxx_rsa.pub
-rw------- 1 foo  root  399 May 15 16:57 id_xxx
-rw-r--r-- 1 foo  root   94 May 15 16:57 id_xxx.pub
-rw------- 1 foo  root 1679 Jan  8  2017 id_rsa.xxx
-rw-r--r-- 1 foo  root  398 May 29  2014 id_rsa.xxx.pub
-rw------- 1 foo  root 5755 May 29 15:49 known_hosts
-rw------- 1 foo  foo  4236 Sep 12  2023 known_hosts.old
```

- The `.ssh` directory is owned by the `foo ` user
- The `.ssh` directory is only accessible to the owner `700 drwx------`
- All the files are read/write for the owner `600 -rw-------`
- All the `.pub` files are readable by everyone `644 -rw-r--r--`

You can run these commands to get things right if needed:

```
cd ~
sudo chown -R foo  .ssh
chmod 700 ~/.ssh
chmod 600 ~/.ssh/*
chmod 644 ~/.ssh/*.pub
```

### `.ssh/known-hosts` Contents

If you have never connected to the [GitHub host](https://github.com/)
instance before, chances are that your `.ssh\known_hosts` file will not have
a line for that server, and any `git` operations will either fail, or will prompt
for you to add the server to the `.ssh\known_hosts` file.

Of course, cloning this repo should automagically add the GitHub host
to your `.ssh\known_hosts` file.

[Docker Install Windows]: https://docs.docker.com/desktop/install/windows-install/
[Docker Install MacOS]: https://docs.docker.com/desktop/install/mac-install/
[Docker Install Linux]: https://docs.docker.com/desktop/install/linux-install/
[Install VSCode]: https://code.visualstudio.com/download
[Install Docker Plugin]: https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker
[Docker Base Images]: https://github.com/rhempel/docker-devcontainers/blob/main/docker-base-images/README.md
[Open An Issue]: https://github.com/rhempel/adaptabuild-example/issues
