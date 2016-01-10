#!/bin/sh
# set -ex


print () {
  color="$1"
  shift
  printf "\033[1;3%sm%s\033[00m\n" "$color" "$*"
}

copy_with_backup () {
  src=$1
  dest=$2
  mode=$3

  if [ -e "$dest" ]; then
    print 2 "==> '$dest' exists; creating a backup at $dest.bk..."
    mv "$dest" "$dest.bk"
  fi
  print 3 "==> Installing $src to $dest ($mode)"
  cp -r "$src" "$dest"

  chmod -R "$mode" "$dest"
}

which git > /dev/null || (echo "Please install git" && exit 1)
if [ -d "$ROOT" ]; then
  mkdir -p "$ROOT"
fi

if [ ! -d deps ]; then
  mkdir deps
  pushd deps > /dev/null

  if [ ! -f /usr/bin/sgetty ]; then
    git clone http://git.suckless.org/ubase > /dev/null
    exit
    pushd ubase > /dev/null
      print 3 "==> Installing ubase"
      make ubase-box
      mkdir -p "$ROOT"/usr/bin
      cp ubase-box "$ROOT"/usr/bin
      ln -s "$ROOT"/usr/bin/ubase-box "$ROOT"/usr/bin/sgetty
      ln -s "$ROOT"/usr/bin/ubase-box "$ROOT"/usr/bin/respawn
      ln -s "$ROOT"/usr/bin/ubase-box "$ROOT"/usr/bin/halt
      ln -s "$ROOT"/usr/bin/ubase-box "$ROOT"/usr/bin/killall5
    popd > /dev/null
  else
    print 2 "==> ubase seems to be installed ("$ROOT"/usr/bin/sgetty exists). If not, install by hand"
  fi

  if [ ! -f "$ROOT"/bin/sinit ]; then
    git clone http://git.suckless.org/sinit
    pushd sinit > /dev/null
      print 3 "==> Installing sinit"
      cp ../../sinit_config config.h
      make
      mkdir -p "$ROOT"/bin/
      cp sinit "$ROOT"/bin/sinit
    popd > /dev/null
  else
    printf 2 "==> sinit seems to be installed ("$ROOT"/bin/sinit exists). If not, install by hand"
  fi
  popd > /dev/null
fi

mkdir -p "$ROOT"/etc/
mkdir -p "$ROOT"/bin/

copy_with_backup rc.d "$ROOT"/etc/rc.d 755
copy_with_backup rc "$ROOT"/bin/rc 755
copy_with_backup rc.conf "$ROOT"/etc/rc.conf 644

print 3 "==> Installing extras"
pushd extra
  mkdir -p /usr/share/zsh/site-functions/
  copy_with_backup _rc "$ROOT"/usr/share/zsh/site-functions/ 644

install -Dm755 shutdown.sh "$ROOT/sbin/shutdown"

print 3 ":: Now link sinit to /sbin/init or append 'init=/sbin/sinit' in your kernel boot line to complete installation"
