# My setup to get internet access

I have the following hardware in use:

  - [AVM Fritzbox 3370 with "Hynix" NAND flash memory](https://openwrt.org/toh/avm/fritz.box.wlan.3370) as a plain stupid VDSL modem
  - [TP-Link Archer C2600](https://openwrt.org/toh/tp-link/tp-link_archer_c2600_v1) as the gateway router running Unbound, WireGuard etc.
  - [Hetzner Cloud CX11 vServer](https://www.hetzner.com/de/cloud) to have a static IP and tunnel traffic via WireGuard to my mailserver located in my LAN

In the following, I show the steps taken to setup above devices. Adjust accordingly if you use other hardware:

  - ... as modem with [Lantiq SoC](https://openwrt.org/docs/techref/hardware/soc/soc.lantiq), preferably with an up-to-date [firmware](https://xdarklight.github.io/lantiq-xdsl-firmware-info/)
  - ... as the high-performing gateway router, see [OpenSSL](https://openwrt.org/docs/guide-user/perf_and_log/benchmark.openssl) and [VPN](https://openwrt.org/toh/views/toh_vpn_performance) benchmarks. Beware that wireguard doesn't make use of AES-NI due to its [protocols and primitives](https://www.wireguard.com/protocol/).

## Beware

I won't go into initial device flashing as this is already covered in the [official docs](https://openwrt.org/docs/start). **And, I assume that you check the integrity of all downloaded files with GnuPG, sha256sum etc. as you see fit.**

Commands run locally (on my laptop) are shown as:

```bash
local $ echo local_command
```

... whereas those run on my modem, router and vServer are shown as:

```bash
remote $ echo remote_command
```

## Further docs

Device-specific docs are stored in the subfolders `modem`, `router` and `vserver`.