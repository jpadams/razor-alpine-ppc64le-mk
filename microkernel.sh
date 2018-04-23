# Uncomment the next line
# to make the root password be thincrust
# By default the root password is emptied
#rootpw --iscrypted $1$uw6MV$m6VtUWPed4SqgoW6fKfTZ/

#
# Partition Information. Change this as necessary
# This information is used by appliance-tools but
# not by the livecd tools.
#
#part / --size 1024 --fstype ext4 --ondisk sda

#
# Repositories
#
#handled by /etc/apk/repositories

#
# Add all the packages after the base packages
#
#%packages --excludedocs --nobase
#bash - can be added, but do we need it?
#apk add bash
#kernel - not in 'main' repo, but do we need it?
#grub2 - 'grub' is in 'main' repo, but do we need it?
#apk add grub
#e2fsprogs - not in 'main' repo, but do we need it?
#passwd - not in 'main' repo, but do we need it?
#policycoreutils - not in 'main' repo, but do we need it?
#chkconfig - handled by 'rc-update add mk'?
#rootfiles - not in 'main' repo, but do we need it?
#yum - we use 'apk' package manager on Alpine instead. Already installed on 'Vanilla' Alpine Linux.
#vim-minimal - 'vim' is in 'main' repo, but do we need it? 'vi' already there.
#acpid - not in 'main' repo, but do we need it? Probably not for ppc64le?
#tar - pre-installed on 'Vanilla' Alpine Linux v3.7 iso
# RAZOR-145 Add dmidecode for facter support
#dmidecode - Probably not for ppc64le?
#apk add dmidecode
# Additional dependency for facter support
#virt-what - not in 'main' repo, but do we need it? Probably not for ppc64le?

# Only needed because livecd-tools runs /usr/bin/firewall-offline-cmd
# unconditionally; patch submitted upstream. Remove once released version
# with it is available
#firewalld - not on Alpine. 'iptables' is in repo, but do we need it?
apk add iptables

# SSH access
apk add openssh-client
apk add openssh-server

#NetworkManager - networking already in place on 'vanilla'

# Used to update code at runtime
apk add unzip

# Enable stripping
apk add binutils

# We need a ruby env and all of facter's dependencies fulfilled
#rubygems 'ruby' in main repo, includes 'gem' command
apk add ruby
#facter - not in 'main' repo, but gem is available
gem install facter
apk add net-tools

#
# Packages to Remove
#
#-prelink
#-setserial
apk del ed

# Remove the authconfig pieces
#-authconfig
#-passwd

# Remove the kbd bits
apk del kbd
#-usermode

# file system stuff
#-kpartx
#-dmraid
apk del mdadm
apk del lvm2
apk del e2fsprogs
apk del e2fsprogs-libs

# grub
apk del freetype
#-grub2
apk del grub
#-grub2-tools
#-grubby
#-os-prober

# selinux toolchain of policycoreutils, libsemanage, ustr
#-policycoreutils
#-checkpolicy
#-selinux-policy*
#-libselinux-python
#-libselinux
#%end

# Install the microkernel agent
#%include mk-install.ks

# Try to minimize the image a bit
#%post
# ensure we don't have the same random seed on every image, which
# could be bad for security at a later point...
#echo " * purge existing random seed to avoid identical seeds everywhere"
#rm -f /var/lib/random-seed

# I can't tell if this should force a new SSH key, or force a fixed one,
# but for now we can ensure that we generate new keys when SSHD is finally
# fined up on the nodes...
#
# We also disable SSHd automatic startup in the final image.
echo " * disable sshd and purge existing SSH host keys"
rm -f /etc/ssh/ssh_host_*key{,.pub}
rc-update del sshd

#echo " * removing python precompiled *.pyc files"
#find /usr/lib64/python*/ -name *pyc -print0 | xargs -0 rm -f

# This seems to cause 'reboot' resulting in a shutdown on certain platforms
# See https://tickets.puppetlabs.com/browse/RAZOR-100
#echo " * disable the mei_me module"
#mkdir -p /etc/modprobe.d
#cat > /etc/modprobe.d/mei.conf <<EOMEI
#blacklist mei_me
#install mei_me /bin/true
#blacklist mei
#install mei /bin/true
#EOMEI
#no mei kernel module loaded in 'Vanilla'
#to check kernel mods run:
# apk add kmod
# kmod list

#n/a
#echo " * removing trusted CA certificates"
#truncate -s0 /usr/share/pki/ca-trust-source/ca-bundle.trust.crt
#update-ca-trust
#maybe remove /usr/share/ca-certificates/mozilla/*  ? 

#n/a/
#echo " * compressing cracklib dictionary"
#gzip -9 /usr/share/cracklib/pw_dict.pwd

#n/a
#echo " * setting up journald and tty2"
#echo "SystemMaxUse=15M" >> /etc/systemd/journald.conf
#echo "ForwardToSyslog=no" >> /etc/systemd/journald.conf
#echo "ForwardToConsole=yes" >> /etc/systemd/journald.conf
#echo "TTYPath=/dev/tty2" >> /etc/systemd/journald.conf

# 100MB of locale archive is kind unnecessary; we only do en_US.utf8
# this will clear out everything we don't need; 100MB => 2.1MB.
echo " * minimizing locale-archive binary / memory size"
localedef --list-archive | grep -iv 'en_US' | xargs localedef -v --delete-from-archive
mv /usr/lib/locale/locale-archive /usr/lib/locale/locale-archive.tmpl
/usr/sbin/build-locale-archive

# remove things only needed during the build process
echo " * purging packages needed only during build"
#yum -C -y --setopt="clean_requirements_on_remove=1" erase \
#    syslinux mtools acl ebtables firewalld libselinux-python \
#    python-decorator dracut hardlink kpartx passwd
apk del syslinux mtools acl ebtables iptables

#n/a
#echo " * purging all other locale data"
#rm -rf /usr/share/locale/*

#n/a package cache not enabled by default on 'Vanilla'
#echo " * cleaning up yum cache, etc"
#   yum clean all

#echo " * truncating various logfiles"
#for log in yum.log dracut.log lastlog yum.log; do
#    truncate -c -s 0 /var/log/${log}
#done

#echo " * removing /boot, since that lives on the ISO side"
# PROB KEEP THIS?
#rm -rf /boot/*
#%end

#%post --nochroot
echo " * disquieting the microkernel boot process"
sed -i -e's/ rhgb//g' -e's/ quiet//g' $LIVE_ROOT/isolinux/isolinux.cfg
#%end
