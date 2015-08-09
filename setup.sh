#!/bin/sh
if [ "$1" != --force ]; then
    echo "Please read the setup script and confirm that it doesn't break your system."
    exit 1
fi

[ -z "$ROOT" ] && ROOT=

echo "==> Installing /sbin/rc, /etc/rc.conf, /etc/inittab"
install -Dm755 rc "$ROOT"/sbin/rc
if [ -f "$ROOT"/etc/rc.conf ]; then
    echo ":: Warning: '$ROOT/etc/rc.conf' already exists!"
    echo "   Moving it to '$ROOT/etc/rc.conf.backup'."
    mv "$ROOT"/etc/rc.conf "$ROOT"/etc/rc.conf.backup
fi
install -Dm644 rc.conf "$ROOT"/etc/rc.conf
install -Dm644 inittab "$ROOT"/etc/inittab

echo "==> Installing extras"
cd extra
install -Dm644 _minirc "$ROOT/usr/share/zsh/site-functions/_minirc"
install -Dm755 shutdown.sh "$ROOT/sbin/shutdown"

echo "==> Linking busybox to /sbin/{init,halt,poweroff,reboot}"
for i in init halt poweroff reboot; do
    ln -sf $(which busybox) "$ROOT"/sbin/$i
done

echo ":: Append 'init=/sbin/init' to your kernel line in your bootloader"
echo "   to replace your current init with minirc"

# Run "./setup.sh --force" to use the script
