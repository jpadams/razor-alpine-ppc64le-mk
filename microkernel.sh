apk update
apk add mkinitfs
apk add git
apk add bash
# Uncomment the next line
# to make the root password be thincrust
# By default the root password is emptied
#rootpw --iscrypted $1$uw6MV$m6VtUWPed4SqgoW6fKfTZ/

# SSH access
apk add openssh-client
apk add openssh-server

# Used to update code at runtime
apk add unzip

# Enable stripping
apk add binutils

# We need a ruby env and all of facter's dependencies fulfilled
#rubygems 'ruby' in main repo, includes 'gem' command
apk add ruby
apk add ruby-rake
apk add ruby-bundler
gem install rspec --no-ri --no-rdoc
gem install facter --no-ri --no-rdoc
apk add net-tools

#
# Packages to Remove
#

apk del ed

# Remove the kbd bits
apk del kbd
#-usermode

# file system stuff
apk del mdadm
apk del lvm2
apk del e2fsprogs
apk del e2fsprogs-libs

# grub
apk del freetype
apk del grub

# Install the microkernel agent
MY_DIR=$(dirname $(readlink -f $0))
$MY_DIR/mk-install.sh

# I can't tell if this should force a new SSH key, or force a fixed one,
# but for now we can ensure that we generate new keys when SSHD is finally
# fined up on the nodes...
#
# We also disable SSHd automatic startup in the final image.
echo " * disable sshd and purge existing SSH host keys"
rm -f /etc/ssh/ssh_host_*key{,.pub}
rc-update del sshd

# remove things only needed during the build process
echo " * purging packages needed only during build"
#yum -C -y --setopt="clean_requirements_on_remove=1" erase \
#    syslinux mtools acl ebtables firewalld libselinux-python \
#    python-decorator dracut hardlink kpartx passwd
apk del syslinux mtools acl ebtables iptables ruby-rake ruby-bundler git bash
gem uninstall rspec

#echo " * removing /boot, since that lives on the ISO side"
# PROB KEEP THIS?
#rm -rf /boot/*
#%end

# Revisit this. Not sure if n/a or what
#%post --nochroot
#echo " * disquieting the microkernel boot process"
#sed -i -e's/ rhgb//g' -e's/ quiet//g' $LIVE_ROOT/isolinux/isolinux.cfg
#%end
