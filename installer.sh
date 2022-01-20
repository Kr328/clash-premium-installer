#!/bin/bash

cd "$(dirname "$0")" || exit

function assert() {
    if ! "$@"; then
        echo "'$*' failed"
        exit 1
    fi
}

function enforce_command() {
    if ! which "$1" > /dev/null 2>&1;then
        echo "Command '$1' not found"
        exit 1
    fi
}

function enforce_directory() {
    if [[ ! -d "$1" ]]; then
        echo "Directory '$1' not found"
        exit 1
    fi
}

function _remove_legacy_files() {
    enforce_command rm
    
    rm -rf /usr/lib/systemd/system/clash.service
    rm -rf /usr/lib/udev/rules.d/99-clash.rules
}

function _install_clash_premium() {
    echo "Clash unavailable in \$PATH."
    echo "Downloading form Github[https://github.com/Dreamacro/clash/releases/tag/premium]."
    
    enforce_command "wget"
    enforce_command "jq"
    enforce_command "grep"
    enforce_command "xargs"
    enforce_command "gzip"
    enforce_directory "/usr/bin"
    
    case "$(uname -m)" in
        "x86_64") arch="amd64";;
        "i386") arch="386";;
        "i686") arch="386";;
        "arm64") arch="arm64";;
        "armhf") arch="arm";;
        *) echo "Unknown architecture: $(uname -m)" && exit 1 ;;
    esac
    
    download_file_name=$(wget -O - "https://api.github.com/repos/Dreamacro/clash/releases/tags/premium" 2> /dev/null | jq ".assets[].name" | grep -m 1 "linux-$arch" | xargs)
    if [[ -z "$download_file_name" ]]; then
        echo -n "Unable to list clash files."
        exit 1
    fi
    
    echo "Filename: $download_file_name"
    
    tmp_dir="/tmp/clash_premium_installer"
    
    assert mkdir -p "$tmp_dir"
    
    assert wget "https://github.com/Dreamacro/clash/releases/download/premium/$download_file_name" -O "$tmp_dir/clash_premium.gz"
    
    assert gzip -d -f "$tmp_dir/clash_premium.gz"
    
    assert install -m 0755 "$tmp_dir/clash_premium" /usr/bin/clash
}

function _install() {
    enforce_command install
    enforce_command nft
    enforce_command ip
    
    enforce_directory "/etc/systemd/system"
    enforce_directory "/etc/udev/rules.d"
    
    if ! grep net_cls "/proc/cgroups" > /dev/null 2>&1 ;then
        echo "cgroup not support net_cls"
        exit 1
    fi
    
    if ! which clash ;then
        _install_clash_premium
    fi

    _remove_legacy_files

    assert systemctl disable --now clash
    
    assert install -d -m 0755 /etc/default/
    assert install -d -m 0755 /usr/lib/clash/
    assert install -d -m 0644 /srv/clash/
    
    assert install -m 0644 scripts/clash-default /etc/default/clash
    
    assert install -m 0755 scripts/bypass-proxy-pid /usr/bin/bypass-proxy-pid
    assert install -m 0755 scripts/bypass-proxy /usr/bin/bypass-proxy
    
    assert install -m 0700 scripts/clean-tun.sh /usr/lib/clash/clean-tun.sh
    assert install -m 0700 scripts/setup-tun.sh /usr/lib/clash/setup-tun.sh
    assert install -m 0700 scripts/setup-cgroup.sh /usr/lib/clash/setup-cgroup.sh
    
    assert install -m 0644 scripts/clash.service /etc/systemd/system/clash.service
    assert install -m 0644 scripts/99-clash.rules /etc/udev/rules.d/99-clash.rules
    
    echo "Install successfully"
    echo ""
    echo "Home directory at /srv/clash"
    echo ""
    echo "All dns traffic will be redirected to 1.0.0.1:53"
    echo "Please use clash core's 'tun.dns-hijack' to handle it"
    echo ""
    echo "Use 'systemctl start clash' to start"
    echo "Use 'systemctl enable clash' to enable auto-restart on boot"
    
    exit 0
}

function _uninstall() {
    enforce_command systemctl
    enforce_command rm
    
    systemctl stop clash
    systemctl disable clash
    
    rm -rf /usr/lib/clash
    rm -rf /usr/lib/systemd/system/clash.service
    rm -rf /usr/lib/udev/rules.d/99-clash.rules
    rm -rf /usr/bin/clash
    rm -rf /usr/bin/bypass-proxy-uid
    rm -rf /usr/bin/bypass-proxy
    rm -rf /etc/default/clash
    
    echo "Uninstall successfully"
    
    exit 0
}

function _help() {
    echo "Clash Premiun Installer"
    echo ""
    echo "Usage: ./installer.sh [option]"
    echo ""
    echo "Options:"
    echo "  install      - install clash premiun core"
    echo "  uninstall    - uninstall installed clash premiun core"
    echo ""
    
    exit 0
}

case "$1" in
    "install") _install;;
    "uninstall") _uninstall;;
    *) _help;
esac
