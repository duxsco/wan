# Router

On devices with large storage capacity, packages can be installed after flashing OpenWrt using `opkg` or over the web interface (aka `luci`). In contrast to my modem setup, I don't have the requirement of keeping the image as small as possible. Nevertheless, I still prefer building my own image with OpenWrt's [Image Builder](https://openwrt.org/docs/guide-user/additional-software/imagebuilder), especially with the requirement of replacing DNSMasq with Unbound and enabling WPA3.

```bash
local $ ls -1
openwrt-19.07.7-ipq806x-generic-tplink_c2600-squashfs-sysupgrade.bin
openwrt-imagebuilder-19.07.7-ipq806x-generic.Linux-x86_64.tar.xz
sha256sums
sha256sums.asc
```

Above files are downloaded from [openwrt.org](https://downloads.openwrt.org/releases/19.07.7/targets/ipq806x/generic/).

## Official sysupgrade .bin

Flash the official sysupgrade .bin:

```bash
remote $ sha256sum /tmp/openwrt-19.07.7-ipq806x-generic-tplink_c2600-squashfs-sysupgrade.bin | grep dc715e50d992f9d1e418fff7c7e9dd3707c9dc52730dca50cd3b4c49af15bc26
remote $ sysupgrade -n -v /tmp/openwrt-19.07.7-ipq806x-generic-tplink_c2600-squashfs-sysupgrade.bin
Commencing upgrade. Closing all shell sessions.
Connection to 192.168.0.1 closed by remote host.
Connection to 192.168.0.1 closed.
```

..., ssh into your modem after reboot with `ssh root@192.168.1.1` and list packages without any dependencies:

```bash
remote $ opkg list-installed | awk '{print $1}' | while read I; do if [ $(opkg whatdepends "$I" | wc -l) -eq 3 ]; then echo "$I"; fi; done
ath10k-firmware-qca99x0-ct
base-files
busybox
dnsmasq
dropbear
ip6tables
iwinfo
kmod-ata-ahci
kmod-ata-ahci-platform
kmod-ath10k-ct
kmod-gpio-button-hotplug
kmod-ipt-offload
kmod-leds-gpio
kmod-usb-ledtrig-usbport
kmod-usb-ohci
kmod-usb-phy-qcom-dwc3
kmod-usb2
kmod-usb3
logd
luci
mtd
odhcp6c
odhcpd-ipv6only
ppp
ppp-mod-pppoe
swconfig
uboot-envtools
uci
urandom-seed
urngd
wpad-basic
```

## Image Builder sysupgrade .bin w/o modifications

Use OpenWrt's [Image Builder](https://openwrt.org/docs/guide-user/additional-software/imagebuilder) ...:

```bash
local $ tar xvf openwrt-imagebuilder-19.07.7-ipq806x-generic.Linux-x86_64.tar.xz; echo $?
local $ cd openwrt-imagebuilder-19.07.7-ipq806x-generic.Linux-x86_64/
local $ make help
local $ make image PROFILE="tplink_c2600"; echo $?
local $ scp bin/targets/ipq806x/generic/openwrt-19.07.7-ipq806x-generic-tplink_c2600-squashfs-sysupgrade.bin root@192.168.1.1:/tmp/
local $ grep "openwrt-19.07.7-ipq806x-generic-tplink_c2600-squashfs-sysupgrade.bin" bin/targets/ipq806x/generic/sha256sums | sed 's#*# /tmp/#' | ssh root@192.168.1.1 "dd of=/tmp/sha256.txt"
```

..., flash your modem:

```bash
remote $ sha256sum -c /tmp/sha256.txt 
/tmp/openwrt-19.07.7-ipq806x-generic-tplink_c2600-squashfs-sysupgrade.bin: OK
remote $ sysupgrade -n -v /tmp/openwrt-19.07.7-ipq806x-generic-tplink_c2600-squashfs-sysupgrade.bin
Commencing upgrade. Closing all shell sessions.
Connection to 192.168.1.1 closed by remote host.
Connection to 192.168.1.1 closed.
```

... and create the package list without dependencies again:

```bash
remote $ opkg list-installed | awk '{print $1}' | while read I; do if [ $(opkg whatdepends "$I" | wc -l) -eq 3 ]; then echo "$I"; fi; done
ath10k-firmware-qca99x0-ct
base-files
busybox
dnsmasq
dropbear
firewall
ip6tables
kmod-ata-ahci
kmod-ata-ahci-platform
kmod-ath10k-ct
kmod-gpio-button-hotplug
kmod-ipt-offload
kmod-leds-gpio
kmod-usb-ledtrig-usbport
kmod-usb-ohci
kmod-usb-phy-qcom-dwc3
kmod-usb2
kmod-usb3
logd
mtd
odhcp6c
odhcpd-ipv6only
opkg
ppp
ppp-mod-pppoe
swconfig
uboot-envtools
uci
urandom-seed
urngd
wpad-basic
```

## Minimalistic sysupgrade .bin

**Now, you have an overview of what packages above two images come with.**

I build my image using the [package list from the official OpenWrt image](#official-sysupgrade-bin) with some customisations:

  - Replace `wpad-basic` with `wpad-openssl` for [WPA3 support](https://openwrt.org/docs/guide-user/network/wifi/basic#encryption_modes).
  - Replace `dnsmasq` with `luci-app-unbound` for DNS. As [dnsmasq also takes care of DHCP on IPv4](https://openwrt.org/docs/guide-user/base-system/dhcp), I need to replace `odhcpd-ipv6only` with `odhcpd` to have DHCP and DHCPv6.
  - Install `luci-app-wireguard` for VPN.

While building the image with OpenWrt's [Image Builder](https://openwrt.org/docs/guide-user/additional-software/imagebuilder), you have to explicitly exclude/include packages from the [standard set](#image-builder-sysupgrade-bin-wo-modifications). I create my image with above customisations as follows:

```bash
local $ tar xvf openwrt-imagebuilder-19.07.7-ipq806x-generic.Linux-x86_64.tar.xz; echo $?
local $ cd openwrt-imagebuilder-19.07.7-ipq806x-generic.Linux-x86_64/
local $ make help
local $ make image PROFILE="tplink_c2600" PACKAGES="iwinfo luci -wpad-basic wpad-openssl -dnsmasq luci-app-unbound -odhcpd-ipv6only odhcpd luci-app-wireguard"; echo $?
local $ scp bin/targets/ipq806x/generic/openwrt-19.07.7-ipq806x-generic-tplink_c2600-squashfs-sysupgrade.bin root@192.168.1.1:/tmp/
local $ grep "openwrt-19.07.7-ipq806x-generic-tplink_c2600-squashfs-sysupgrade.bin" bin/targets/ipq806x/generic/sha256sums | sed 's#*# /tmp/#' | ssh root@192.168.1.1 "dd of=/tmp/sha256.txt"
```

You can get some info on a certain package at `https://openwrt.org/packages/pkgdata/<PACKAGE_NAME>` (e.g. https://openwrt.org/packages/pkgdata/urngd) or via [package table](https://openwrt.org/packages/table/start).

Flash the image:

```bash
remote $ sha256sum -c /tmp/sha256.txt
/tmp/openwrt-19.07.7-ipq806x-generic-tplink_c2600-squashfs-sysupgrade.bin: OK
remote $ sysupgrade -n -v /tmp/openwrt-19.07.7-ipq806x-generic-tplink_c2600-squashfs-sysupgrade.bin
Commencing upgrade. Closing all shell sessions.
Connection to 192.168.1.1 closed by remote host.
Connection to 192.168.1.1 closed.
```

And, here is my custom package list without dependencies:

```bash
remote $ opkg list-installed | awk '{print $1}' | while read I; do if [ $(opkg whatdepends "$I" | wc -l) -eq 3 ]; then echo "$I"; fi; done
ath10k-firmware-qca99x0-ct
base-files
busybox
dropbear
ip6tables
iwinfo
kmod-ata-ahci
kmod-ata-ahci-platform
kmod-ath10k-ct
kmod-gpio-button-hotplug
kmod-ipt-offload
kmod-leds-gpio
kmod-usb-ledtrig-usbport
kmod-usb-ohci
kmod-usb-phy-qcom-dwc3
kmod-usb2
kmod-usb3
logd
luci
luci-app-unbound
luci-app-wireguard
mtd
odhcp6c
odhcpd
ppp
ppp-mod-pppoe
swconfig
uboot-envtools
uci
urandom-seed
urngd
wpad-openssl
```