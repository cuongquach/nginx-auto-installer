# Shell script Linux - "nginx-auto-installer"

## Requirements

- Script 'nginx-auto-installer'.
- Privileges to run 'nginx-auto-installer' like root.
- Git command on system.
- Installing dependency packages.

## Installation

**+ Linux**

- First we will install dependencies package.

```sh
$ yum install perl-ExtUtils-Embed pam-devel -y
```

- Then we will clone 'nginx-auto-installer' source to begin installing nginx web server.

```sh
$ git clone https://github.com/cuongquach/nginx-auto-installer.git nginx-auto-installer
$ cd nginx-auto-installer
$ chmod +x install.sh
$ ./install.sh
```

## Author
**Name** : Quach Chi Cuong

**Website** : https://cuongquach.com/
