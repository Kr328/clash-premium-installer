# Clash Premiun Installer

Simple clash premiun core installer with full tun support for Linux.



### Usage

1. Install dependencies **git**, **nftables**, **iproute2**

2. Clone repository

   ```bash
   git clone https://github.com/Kr328/clash-premium-installer
   cd clash-premium-installer
   ```

3. Download clash core [link](https://github.com/Dreamacro/clash/releases/tag/premium)

4. Extract core and rename it to `./clash` (the clash core should in the 'clash-premium-installer' folder)

5. Edit `./scripts/clash.service` and set your `CLASH_URL` (note that subscribe address shouldn't have "&" symbol, if it have, you should convert it to a short url)

6. Run Installer

   ```bash
   ./installer.sh install
   ```
