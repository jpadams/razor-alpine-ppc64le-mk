# Alpine ppc64le Microkernel

This repository has the files/tools for building a Razor Microkernel based
on Alpine Linux for the ppc64le architecture. The resulting discovery image is used by the
[Razor server](https://github.com/puppetlabs/razor-server) to take
inventory of new machines.


# Getting Started

This section describes how to build an image on an
[Alpine Linux](http://alpinelinux.org/) system.

This will produce a tar file `microkernel.tar`. To deploy this on
an existing Razor server, extract it in the server's `repo_store_root` that
you set in `config.yaml`:

    > tar xf microkernel.tar -C $repo_store_root


To log into the microkernel, use the root password `thincrust`. Also
note that logging information will be sent to tty2.

## Getting in touch

* bug/issue tracker: [RAZOR project in JIRA](https://tickets.puppetlabs.com/browse/RAZOR)
* on IRC: `#puppet-razor` on [freenode](http://freenode.net/)
* mailing list: [puppet-razor@googlegroups.com](http://groups.google.com/group/puppet-razor)

## Razor Microkernel Client

The microkernel client has been broken out into several small, focused scripts
intended to perform one task, well.  They are designed to be fired off through
cron, or through a process scheduling supervisor.

The entry point is the binary:

 * `razor-submit-facts` will discover and send facts about the node to Razor
   - this will also act on the command returned during that action

### Razor Microkernel Client Configuration

Configuration is created by overlaying multiple sources, based on this
priority map -- lower numbers are "more important" and override higher
numbers.  The intent is that more dynamic sources of data override less
dynamic sources of data.

Sources are:

1. Kernel command line (as read from `/proc/cmdline`)
2. DHCP "next server" option (@todo danielp 2013-07-26: not implemented yet)
3. Static, on-disk configuration file (`/etc/razor-mk-client.json`)
4. A default DNS assumption that `razor` will point at your Razor server.

Any of these configuration options can be omitted with no ill effects.

In practice, the kernel command line is the place that almost all
configuration will come from.  This is set by the Razor server during boot,
automatically, to help clients that boot from it to rendezvous correctly.

The static, on-disk configuration file is not expected to be used in most
cases: this is provided as a convenience for users who, for some reason, want
to boot statically from local media rather than through the Razor server, but
still want to use the Razor MK image.  (eg: through a virtual CD device, etc.)

Configuration options are:

 * `ip` the IP address of the Razor server.
 * `server` the DNS name of the Razor server.

If supplied, the `ip` value is preferred to the `server` value for locating
the server.  Both are supported since correctly functioning DNS is not assured
during the early boot process; in general, you should strongly prefer to use the `server` value.

### Razor Microkernel Client Identification

We supply a "hardware ID" value to the Razor server to help identify the
specific hardware that is currently running: this is based on the MAC
addresses of network adapters found in the current system.

Presently that is limited only to adapters with a visible name matching
`/^eth/`, following the default naming convention for Linux wired
Ethernet adapters.

### Notes
(https://wiki.alpinelinux.org/wiki/Install_to_disk)
(http://dl-3.alpinelinux.org/alpine/v3.7/main/x86_64/)
http://dl-3.alpinelinux.org/alpine/v3.7/main/ppc64le/
https://wiki.alpinelinux.org/wiki/Alpine_Linux_package_management
https://wiki.gentoo.org/wiki/OpenRC_to_systemd_Cheatsheet
https://github.com/OpenRC/openrc/blob/master/service-script-guide.md
https://forum.alpinelinux.org/forum/general-discussion/run-script-boot
https://pkgs.alpinelinux.org/packages
