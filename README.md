# rc - simple BSD-ish init system

The script `rc` is a minimalistic init script made for use with
[sinit](http://git.suckless.org/sinit).
It picks up where sinit leaves off, which is to say it sets the hostname,
starts udev, starts some daemons (though doesn't ensure they stay running) and

Later, in the user space, you can use it to list currently running daemons and
individually start or stop them.

It was developed for arch linux to get rid of systemd's init, but it can
probably run on other distributions as well.

## Installing

### Dependencies:

* [sinit](http://git.suckless.org/sinit)
* [ubase](http://git.suckless.org/ubase) (for `killall5` implementation)
* optionally eudev or systemd (for udev)

sinit and ubase are downloaded, built and installed into sane places upon
running `setup.sh`.

### Procedure

* Read `setup.sh`. Really.
* `ROOT=test ./setup.sh`
* Check `test/` to make sure everything looks okay.
* `sudo ./setup.sh` (and follow its instructions)
* Check and edit `/etc/rc.conf`
* Reboot

See sections "Managing Services" and "Further configuration".

## Shutdown & Reboot

You need to use busybox's version of the reboot command by either typing in
`busybox reboot` or by linking busybox to `/bin/reboot` and executing it.
The same goes for `halt` and `poweroff`.

You can alternatively send the signals TERM for reboot, USR1 for halt or USR2
for poweroff to the process 1.


## Managing services

A service is defined as any file present in `/etc/rc.d/`. Any of these services
may be enabled by adding their name to the space-separated list called `ENABLED`
in `/etc/rc.conf`. The name may be prefixed with '@' to start that service in
the background.

## Writing services

Services are intentionally simple. They simply export four functions that map
to the four main functions one may perform on a service. They export:

1. `start`: Which serves to get the service into a running state
2. `stop`: Which serves to stop the service
3. `restart`: Which serves to restart the service (and often will just call start and stop)
4. `poll`: Which determines if the service is currently running

`start`, `stop`, `restart` do not have a defined return value. `poll` should
return 0 if the service is currently running, and 1 in the case that it is not.


## Further configuration


### udev

   You need to decide what to use to set up the devices and load the modules.
   minirc supports busybox's mdev, systemd's udev, and a fork of udev, eudev,
   by default.  You can change the udev system by writing `UDEV=busybox`,
   `UDEV=systemd`, or `UDEV=eudev` respectively into `/etc/rc.conf`.

   eudev and systemd's udev work out of the box, so they are recommended.  To
   set up mdev, you can use [this](https://github.com/slashbeast/mdev-like-a-boss)
   as a reference:

### Local startup script

   rc will run `/etc/rc.local` on boot if the file exists and has the executable
   bit set. This allows the user to run commands in addition to the basic
   startup that rc provides. This is a good place to load modules if udev does
   not detect that they should be loaded on boot.


## Usage of the user space program

Run `rc --help` for information.  **Never run `rc init` except during the boot
process, when called by busybox init.**



## About

rc is a fork of [minirc](http://github.com/hut/minirc).

minirc is, at the time of forking, written by Roman Zimbelmann and Sam Stuewe
and is available under the GPL v2 license.

Parts of the function on_boot() and the start/stop function of iptables were
taken from archlinux initscripts (http://www.archlinux.org).  minirc's authors
were unable to determine the author or authors of those parts. I have made no
such attempt to find the authors.

For information on rc's license, please see LICENSE in the source repository.
