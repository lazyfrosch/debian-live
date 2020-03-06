# See https://willhaley.com/blog/custom-debian-live-environment/

.PHONY: image scratch

all: chroot image debian-live.iso

chroot:
	sudo rm -rf chroot.tmp
	sudo debootstrap --variant=minbase buster chroot.tmp https://deb.debian.org/debian
	./update-chroot.sh chroot.tmp
	mv chroot.tmp chroot

image: chroot
	rm -rf image
	mkdir -p image/live
	touch image/DEBIAN_CUSTOM
	cp chroot/boot/initrd.img* image/initrd
	cp chroot/boot/vmlinuz* image/vmlinuz
	sudo mksquashfs chroot image/live/filesystem.squashfs -e boot

scratch: image
	rm -rf $@
	mkdir $@
	grub-mkstandalone \
      --format=i386-pc \
      --output=$@/core.img \
      --install-modules="linux normal iso9660 biosdisk memdisk search tar ls" \
      --modules="linux normal iso9660 biosdisk search" \
      --locales="" \
      --fonts="" \
      "boot/grub/grub.cfg=grub.cfg"
	cat /usr/lib/grub/i386-pc/cdboot.img $@/core.img > $@/bios.img

debian-live.iso: scratch
	xorriso \
      -as mkisofs \
      -iso-level 3 \
      -full-iso9660-filenames \
      -volid "DEBIAN_CUSTOM" \
      --grub2-boot-info \
      --grub2-mbr /usr/lib/grub/i386-pc/boot_hybrid.img \
      -eltorito-boot \
        boot/grub/bios.img \
        -no-emul-boot \
        -boot-load-size 4 \
        -boot-info-table \
        --eltorito-catalog boot/grub/boot.cat \
      -output debian-custom.iso \
      -graft-points \
        image \
        /boot/grub/bios.img=scratch/bios.img

clean:
	sudo rm -rf chroot.tmp chroot image *.iso
