#!/bin/bash

cd "`dirname $0`"

function assert() {
    "$@"

    if [ "$?" != 0 ]; then
    echo "Execute $@ failure"
    exit 1
    fi
}

function assert_command() {
    if ! which "$1" > /dev/null 2>&1;then
    echo "Command $1 not found"
    exit 1
    fi
}

function _install() {
    assert_command install
    assert_command nft
    assert_command ip

    if [ ! -d "/usr/lib/udev/rules.d" ];then
    echo "udev not found"
    exit 1
    fi

    if [ ! -d "/usr/lib/systemd/system" ];then
    echo "systemd not found"
    exit 1
    fi

    if ! grep net_cls "/proc/cgroups" 2> /dev/null > /dev/null ;then
    echo "cgroup not support net_cls"
    exit 1
    fi

    if [ ! -f "./clash" ];then
    echo "Clash core not found."
    echo "Please download it from https://github.com/Dreamacro/clash/releases/tag/premium, and rename to ./clash"
    fi
    
    assert install -d -m 0755 /etc/default/
    assert install -d -m 0755 /usr/lib/clash/
    assert install -d -m 0644 /srv/clash/

    assert install -m 0755 ./clash /usr/bin/clash
    
    assert install -m 0644 scripts/clash-default /etc/default/clash

    assert install -m 0755 scripts/bypass-proxy-pid /usr/bin/bypass-proxy-pid
    assert install -m 0755 scripts/bypass-proxy /usr/bin/bypass-proxy

    assert install -m 0700 scripts/clean-tun.sh /usr/lib/clash/clean-tun.sh
    assert install -m 0700 scripts/setup-tun.sh /usr/lib/clash/setup-tun.sh
    assert install -m 0700 scripts/setup-cgroup.sh /usr/lib/clash/setup-cgroup.sh

    assert install -m 0700 scripts/start-clash.sh /srv/clash/start-clash.sh
    assert install -m 0700 scripts/stop-clash.sh /srv/clash/stop-clash.sh
    assert install -m 0644 scripts/append.yaml /srv/clash/append.yaml

    assert install -m 0644 scripts/clash.service /usr/lib/systemd/system/clash.service
    assert install -m 0644 scripts/99-clash.rules /usr/lib/udev/rules.d/99-clash.rules

    echo "Install successfully"
    echo ""
    echo "Home directory at /srv/clash"
    echo ""
    echo "If you do not set clash subscribe link or want to change clash subscribe link"
    echo "Please edit '/usr/lib/systemd/system/clash.service' . When finished please run 'systemctl daemon-reload' "
    # echo "All dns traffic will be redirected to 1.0.0.1:53"
    # echo "Please use clash core's 'tun.dns-hijack' to handle it"
    echo ""
    echo "Use 'systemctl start clash' to start"
    echo "Use 'systemctl enable clash' to enable auto-restart on boot"

    exit 0
}

function _uninstall() {
    assert_command systemctl
    assert_command rm

    systemctl stop clash
    systemctl disable clash

    rm -rf /usr/lib/clash
    rm -rf /usr/lib/systemd/system/clash.service
    rm -rf /usr/lib/udev/rules.d/99-clash.rules
    rm -rf /usr/bin/clash
    rm -rf /usr/bin/bypass-proxy-uid
    rm -rf /usr/bin/bypass-proxy
    rm -rf /etc/default/clash
    rm -rf /srv/clash/start-clash.sh
    rm -rf /srv/clash/stop-clash.sh
    rm -rf /srv/clash/append.yaml

    echo "Uninstall successfully"

    exit 0
}

function _help() {
    echo "Clash Premiun Installer(Please run as root!)"
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
