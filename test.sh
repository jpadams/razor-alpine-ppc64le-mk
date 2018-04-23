apk add alpine-sdk build-base apk-tools alpine-conf busybox fakeroot syslinux xorriso mtools dosfstools grub-efi git

git clone git://git.alpinelinux.org/aports

apk update

PROFILENAME=mk

cat << EOF > ~/aports/scripts/mkimg.$PROFILENAME.sh
profile_$PROFILENAME() {
        profile_standard
        kernel_cmdline="unionfs_size=512M console=tty0 console=ttyS0,115200"
        syslinux_serial="0 115200"
        apks="\$apks ruby ruby-rake ruby-bundler 
                "
        apks="\$apks linux-firmware"
}
EOF

chmod +x mkimg.$PROFILENAME.sh

mkdir -p ~/iso

sh mkimage.sh --tag edge \
	--outdir ~/iso \
	--arch x86_64 \
	--repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
	--profile $PROFILENAME

